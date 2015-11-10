global with sharing class CurrentInventoryReportController {
	
	
	/*The table shows all Inventory__c records with Record Type “Current Inventory”
Columns are Warehouse__c
Rows are Product__c
Cells are Quantity__c
Rows and Columns should be grouped
The table should be split into two sections (can be two tables) – One where Product__r.ProductFamily = Cinema and the second where Product__r.ProductFamily = Mounts*/
    global class warehouseQuantity implements Comparable
    {
    	public Decimal whareHouseSortOrder{get;set;}
    	public string warehouse{get;set;}
    	public Integer quantity{get;set;}
    	
    	global Integer compareTo(Object compareTo) {
            
            warehouseQuantity compareToItem = (warehouseQuantity)compareTo;
            
            if (this.whareHouseSortOrder == compareToItem.whareHouseSortOrder)
                return 0;
            else if (this.whareHouseSortOrder > compareToItem.whareHouseSortOrder)
                return 1;
            else
                return -1;
        }
    }
    
    global class inventoryGrid  implements Comparable
    {
    	public string productName{get;set;}
    	public string productId{get;set;}
    	public list<warehouseQuantity> quantities{get;set;}
    	public Integer total{get;set;}
    	public Decimal sortOrder{get;set;}
    	
    	global Integer compareTo(Object compareTo) {
            
            inventoryGrid compareToItem = (inventoryGrid)compareTo;
            
            if (this.sortOrder == compareToItem.sortOrder)
                return 0;
            else if (this.sortOrder > compareToItem.sortOrder)
                return 1;
            else
                return -1;
        }
    }
    
    map<string, Warehouse__c> warehouses;
    public map<String,Decimal> pSortOrder = new map<String,Decimal>();
    public map<String,Decimal> wSortOrder = new map<String,Decimal>();
    public CurrentInventoryReportController()
    {
    	warehouses = new map<string, Warehouse__c>();
    	
    	for(Inventory__c w : [Select Id,Product__r.name, Product__r.SortOrder__c, Warehouse__r.Name, Warehouse__c, Warehouse__r.WarehouseSortOrder__c from Inventory__c order by Warehouse__r.WarehouseSortOrder__c])
    	{
    	  warehouses.put(w.Warehouse__r.Name, new Warehouse__c(id=w.Warehouse__c,name= w.Warehouse__r.Name, WarehouseSortOrder__c = w.Warehouse__r.WarehouseSortOrder__c));
    	  pSortOrder.put(w.Product__r.name, w.Product__r.SortOrder__c);
    	  wSortOrder.put(w.Warehouse__r.Name, w.Warehouse__r.WarehouseSortOrder__c);
    	}
    }
    
    public list<warehouseQuantity> getWarehouses()
    {
    	list<warehouseQuantity> wList = new list<warehouseQuantity>();
    	for(Warehouse__c w : warehouses.values())
    	{
    		warehouseQuantity q = new warehouseQuantity();
    		q.warehouse = w.name;
    		q.whareHouseSortOrder = w.WarehouseSortOrder__c;
    		wList.add(q);
    	}
    	wList.sort();
    	return wList;
    }
    
    public list<inventoryGrid> getInventory(string context)
    {
    	
    	list<inventoryGrid> iList = new list<inventoryGrid>();
    	map<string, list<warehouseQuantity>> productWarehouseQuantiyMap = new map<string, list<warehouseQuantity>>();
    	set<Product2> product= new set<Product2>();
    	
    	for(AggregateResult ar : [Select i.Warehouse__r.Name wName
    	                               , i.Warehouse__c
    	                               , i.Product__r.Name pName
    	                               , i.Product__c 
    	                               //, Warehouse__r.WarehouseSortOrder__c
    	                               //, Product__r.SortOrder__c
    	                               , sum(i.Quantity__c) qt
    	                            From Inventory__c i
    	                           where RecordType.Name = 'Current Inventory'
    	                             and Product__r.Family = :context
    	                           group by i.Warehouse__r.Name
	    	                              , i.Warehouse__c
	    	                              , i.Product__r.Name
	    	                              , i.Product__c
	    	                             // , Warehouse__r.WarehouseSortOrder__c
	    	                             // , Product__r.SortOrder__c
	    	                             ])
    	{
    		string pName = (string)ar.get('pName');
    		if(productWarehouseQuantiyMap.containsKey(pname))
    		{
    			list<warehouseQuantity> wl = productWarehouseQuantiyMap.get(pname);
    			warehouseQuantity wq = new warehouseQuantity();
    			wq.warehouse = (string)ar.get('wName');
    			wq.quantity = Integer.ValueOf( ar.get('qt'));
    			wq.whareHouseSortOrder = wSortOrder.get((string)ar.get('wName'));
    			wl.Add(wq);
    		}
    		else
    		{
    			list<warehouseQuantity> wl = new list<warehouseQuantity>();
    			warehouseQuantity wq = new warehouseQuantity();
    			wq.warehouse = (string)ar.get('wName');
    			wq.quantity = Integer.ValueOf( ar.get('qt'));
    			wq.whareHouseSortOrder = wSortOrder.get((string)ar.get('wName'));
    			wl.Add(wq);
    			productWarehouseQuantiyMap.put(pname, wl);
    		}
    	}
    	
    	list<Decimal> whSortOrder = new list<Decimal>();
    	whSortOrder.addAll(wSortOrder.values());
    	whSortOrder.sort();
    	
    	list<Decimal> prSortOrder = new list<Decimal>();
    	prSortOrder.addAll(pSortOrder.values());
    	prSortOrder.sort();
    	for(Decimal ps: prSortOrder)
    	{
    		
			for(String s : productWarehouseQuantiyMap.keySet())
			{
			   if(pSortOrder.get(s) != ps)
			     continue;
				inventoryGrid g = new inventoryGrid();
				g.productName = s;
				g.sortOrder = pSortOrder.get(s);
				g.quantities = new list<warehouseQuantity>();
				g.total = 0;
				
				for(Warehouse__c w : warehouses.values())
	    		{
		    		boolean found = false;
	    			system.debug('>>>>>w.WarehouseSortOrder__c::::>'+w.WarehouseSortOrder__c);
	    			for(warehouseQuantity wq : productWarehouseQuantiyMap.get(s))
	    			{
	    				if(w.Name == wq.warehouse)
	    				{
	    				  g.quantities.add(wq);
	    				  found = true;
	    				  g.total += wq.quantity;
	    				}
	    			}
	    			if(found == false)
	    			{
	    				warehouseQuantity wq = new warehouseQuantity();
	    				
	    				wq.warehouse = w.name;
	    				wq.quantity = 0;
	    				g.quantities.add(wq);
	    				
	    			}
	    		}
				g.quantities.sort();
	    		iList.add(g);
			}
    	}	
		//sort the warehouses		
    	//iList.sort();
    	return iList;
    }
    
    public list<inventoryGrid> getCenimaInventory()
    {
   	   return getinventory('Cinema');
    }
    
    public list<inventoryGrid> getMountInventory()
    {
    	
    	return getinventory('Mounts');
    }
    
    public pageReference cloneCurrentInventory()
    {
	    try{
	    	list<Inventory__c> MonthEndInventory = new list<Inventory__c>();
	    	RecordType MonthEndRecordType = [Select Id from RecordType where Name = 'Month End Inventory' and SObjectType = 'Inventory__c'];
	    	
	    	for(Inventory__c i : [Select Product__c, Warehouse__c, Quantity__c from Inventory__c where RecordType.Name = 'Current Inventory'])
	    	{
	    		MonthEndInventory.add( new Inventory__c(Product__c = i.Product__c
	    		                                      , Warehouse__c = i.Warehouse__c
	    		                                      , Quantity__c = i.Quantity__c
	    		                                      , Date__c = System.today()
	    		                                      , RecordTypeId = MonthEndRecordType.Id));
	    	}
	    	
	    	if(MonthEndInventory.size() > 0)
	    	  insert MonthEndInventory;
	    }
	    catch(Exception e)
	    {
	    	ApexPages.addMessages(e);
	    	return null;
	    }
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Month End Inventory Records Created Successfully'));
    	return null;
    }
    
    static testMethod void testThisClass()
    {
    	Account acc = TestClientUtility.createAccount();
        acc.ShippingStreet = '123';
		acc.ShippingCity = 'abc';
		acc.ShippingState = 'CA';
		acc.ShippingPostalCode = '90210';
		acc.ShippingCountry = 'USA';
		
		insert acc;
    	
    	Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
	    wh.name = 'RealD Finished Goods';
	    wh.Street_Address__c = '123';
		wh.City__c = 'xyz';
		wh.State__c = 'NY';
		wh.Postal_Code__c = '11101';
		wh.Country__c = 'USA';
		wh.Include_in_Inventory__c = true;
		wh.WarehouseSortOrder__c = 99;
		insert wh;
		
		Warehouse__c wh2 = TestClientUtility.createWarehouse(acc.Id);
	    wh2.name = 'RealD Finished Goodies';
	    wh2.Street_Address__c = '123';
		wh2.City__c = 'xyz';
		wh2.State__c = 'NY';
		wh2.Postal_Code__c = '11101';
		wh2.Country__c = 'USA';
		wh2.Include_in_Inventory__c = true;
		wh2.WarehouseSortOrder__c = 97;
		insert wh2;
	    
	    Product2 prod = TestClientUtility.createProduct2();
        prod.Serialized__c = true;
	    prod.Family = 'Mounts';
	    prod.SortOrder__c = 98;
        insert prod;
        
	    Inventory__c i = TestClientUtility.createInventory(wh2.Id, prod.Id);
	    RecordType rt = [Select Id from RecordType where Name = 'Current Inventory'];
	    i.RecordTypeId = rt.Id;
	    i.Product__c = prod.Id;
	    insert i;
	    
	    Product2 prod2 = TestClientUtility.createProduct2();
        prod2.Serialized__c = true;
	    prod2.Family = 'Cinema';
	    prod2.SortOrder__c = 99;
        insert prod2;
        
        Product2 prod3 = TestClientUtility.createProduct2();
        prod3.Serialized__c = true;
	    prod3.Family = 'Cinema';
	    prod3.SortOrder__c = 97;
        insert prod3;
        
	    Inventory__c i2 = TestClientUtility.createInventory(wh.Id, prod.Id);
	    i2.RecordTypeId = rt.Id;
	    i2.Product__c = prod2.Id;
	    insert i2;
	    
	    Inventory__c i3= TestClientUtility.createInventory(wh.Id, prod3.Id);
	    i3.RecordTypeId = rt.Id;
	    i3.Product__c = prod3.Id;
	    insert i3;
	    
	    CurrentInventoryReportController ctl = new CurrentInventoryReportController();
	    
	    ctl.cloneCurrentInventory();
	    ctl.getCenimaInventory();
	    ctl.getMountInventory();
	    ctl.getWarehouses();
    }
}