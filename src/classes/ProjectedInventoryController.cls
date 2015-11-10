/**
 * @Name: ProjectedInventoryController
 * @Author: Nathan Shinn
 * @Description:
 *		Controller for the ProjectedInventory Visualforce Page under the Projected Inventory Tab a dynamic table similar to the current inventory display.
 * 
 *		This table should show Inventory for a given warehouse (selected by a picklist) with Rows for each product (as with current inventory) and columns for dates.  
 *		Each corresponding cell will represent the quantity of Inventory for the given date based on the following logic:
 *		 
 *		For each Inventory Record for the selected Warehouse and for a given Date, Quantity =
 *		 
 *			Current Inventory
 *			 
 *			+ Inventory Records with the Record Type “Manufacturing Forecast”  (ID: 012g00000008UbN) 
 *			AND Date__c =< Selected Date 
 *			AND Date__c > TODAY
 *			
 *			+Shipment Line Records with Matching Product where Shipment__r.Destination_Warehouse__c = Selected Warehouse  
 *			AND Line_Status__c = “Shipped” 
 *			AND Shipment__r.Delivery_Due_Date__c =< Selected Date 
 *			AND Shipment__r.Delivery_Due_Date__c  > TODAY
 *			- Shipment Line Records with Matching Product where Source_Warehouse__c = Selected Warehouse 
 *			AND Line_Status__c = “Pending” OR Line_Status__c = “Scheduled” 
 *			AND Shipment__r.Scheduled_Ship_Date__c = <Selected Date
 *			AND Shipment__r.Scheduled_Ship_Date__c > TODAY
 *			- Shipment Line Records with Matching Product where
 *			Shipment__r.Destination_Warehouse__r.In_Transit_Warehouse__c = Selected Warehouse
 *			AND Line_Status__c = “Shipped”
 *			AND Shipment__r.Delivery_Due_Date__c =< Selected Date 
 *			AND Shipment__r.Delivery_Due_Date__c  > TODAY
 *		 
 *		 
 *		Date Selection:
 *		Users can select date range to display and date grouping via picklists on the page.
 *		 
 *		Picklist 1 Field Name: “Display by:”
 *		Options:
 *		Day
 *		Week
 *		Month
 *		 
 *		Day – Display all days within the selected range
 *		Week – Display Each Friday within the selected range only
 *		Month – Display the Last Day of each month within the selected range only
 *		 
 *		Picklist 2 Field Name: “Date Range”
 *		Options:
 *		Next 7 Days
 *		Next 14 Days
 *		Next 30 Days
 *		Next 60 Days
 *		Next 90 Days
 *		Next 180 Days
 *		 
 *		Each option should display projected quantity for each inventory record in the selected Warehouse for the given number of days starting today.
 *		 
 *		Thus, for “Next n Days”, Dates should display Today through Today + n days.
 *		 
 *		The picklists should be dependent on one another to prevent more than 30 columns from being displayed at a time.
 *		 
 *						Day		Week	Month
 *		Next 7 Days		ü		X		X
 *		Next 14 Days	ü		ü		X
 *		Next 30 Days	ü		ü		X 
 *		Next 60 Days	X		ü		ü 
 *		Next 90 Days	X		ü		ü
 *		Next 180 Days	X		X		ü
 *		 
 *		 
 *		Picklist 3 Field Name: “Warehouse”
 *		Options: Dynamically created picklist of warehouses linked to Current Inventory Records
 *		 
 *		Submit Button to confirm selection (to prevent the page from automatically trying to reload with each selection as the page is likely to take a bit of time 
 *		to refresh).
 *		Thus, depending on the selections made on the 3 picklists, the table displays calculated Inventory quantity projections for all products, using the same 
 *		format and sort order of the current inventory screens.  Only records for the selected warehouse are displayed and columns represent the appropriate dates 
 *		in the format:  MMM-DD (ie “Jan-15”).
 *		 
 *		Depending on the speed with which the page loads, it may be necessary to pop up a “Loading” overlay on the page while the table loads so users know it is 
 *		still building the table data.
 *	
 **/

global with sharing class ProjectedInventoryController {
	
	global Integer selectedDateRange{get;set;}
	global String selectedDisplayBy{get;set;}
	global Id selectedWarehouse{get;set;}
	public list<InventoryGrid> warehouseInventory{get;set;}
    public map<String, String> productTypeMap{get;set;}
    public map<String,Decimal> productSortOrder = new map<String,Decimal>();
    
    global ProjectedInventoryController()
	{
		selectedDisplayBy = 'Day';
		warehouseInventory = new list<InventoryGrid>();
    	productSortOrder = new map<string, Decimal>();
    	productTypeMap = new map<String,String>();
    	for(Product2 p : [Select Id,name, SortOrder__c, Family
    	                   from Product2 order by SortOrder__c])
    	{
    	  productSortOrder.put(p.name, p.SortOrder__c);
		  productTypeMap.put(p.Name, p.Family);
    	}
    }
    
    
	
	
	//======================================
	// UTILITY FUNCTIONS
	
	global list<SelectOption> getWarehouseOptions()
	{
		list<SelectOption> opts = new list<SelectOption>();
		map<Decimal,Warehouse__c> warehouseMap = new map<Decimal,Warehouse__c>();
		
		//load a map of unique warehouse associated to Inventory records
		for(Inventory__c ar : [select Warehouse__c, Warehouse__r.name, Warehouse__r.WarehouseSortOrder__c
		                            from Inventory__c 
		                           where RecordType.Name = 'Current Inventory'
		                           order by Warehouse__r.WarehouseSortOrder__c])
		{
			warehouseMap.put(ar.Warehouse__r.WarehouseSortOrder__c, new Warehouse__c(name=ar.Warehouse__r.name, Id=ar.Warehouse__c));
		}
		List<Decimal> sortOrderList = new List<Decimal>();
		sortOrderList.addAll(warehouseMap.keySet());
		sortOrderList.sort();
		//iterate through the warehouse map producing the warehouse list
        for(Decimal wh : sortOrderList)
        {
        	opts.add(new SelectOption(warehouseMap.get(wh).Id,warehouseMap.get(wh).name));  
        }		

		return opts;
	}
	
	global list<SelectOption> getDisplayByOptions()
	{
		list<SelectOption> opts 
		   = new list<SelectOption>{new SelectOption('','--None--')
		   						  , new SelectOption('Day','Day')
		   						  , new SelectOption('Week','Week')
		   						  , new SelectOption('Month','Month')};
		
       		

		return opts;
	}
	
	global list<SelectOption> getDateRangeOptions()
	{
		/* 
			The picklists should be dependent on one another to prevent more than 30 columns from being displayed at a time.
								Day		Week	Month
				Next 7 Days		ü		X		X
				Next 14 Days	ü		ü		X
				Next 30 Days	ü		ü		X
				Next 60 Days	X		ü		ü
				Next 90 Days	X		ü		ü
				Next 180 Days	X		X		ü
		 */
		list<SelectOption> opts = new list<SelectOption>{new SelectOption('','--Select Range--')};
		if(selectedDisplayBy == 'Day')
			return new list<SelectOption>{new SelectOption('','--Select Range--')
										, new SelectOption('7','Next 7 Days')
										, new SelectOption('14','Next 14 Days')
										, new SelectOption('30','Next 30 Days')};
		if(selectedDisplayBy == 'Week')
			return new list<SelectOption>{new SelectOption('','--Select Range--')
										, new SelectOption('14','Next 14 Days')
										, new SelectOption('30','Next 30 Days')
										, new SelectOption('60','Next 60 Days')
										, new SelectOption('90','Next 90 Days')};
		if(selectedDisplayBy == 'Month')
			return new list<SelectOption>{new SelectOption('','--Select Range--')
										, new SelectOption('60','Next 60 Days')
										, new SelectOption('90','Next 90 Days')
										, new SelectOption('180','Next 180 Days')};
		//return and empty set by default
		return opts;
	}
	
    global class ResultRow //implements Comparable
    {
    	global string Product{get;set;}
    	global Date TimeBucket{get;set;}
    	global Decimal Quantity{get;set;}
    	/*
    	global Integer compareTo(Object compareTo) {
            
            resultRow compareToItem = (resultRow)compareTo;
            
            if (this.TimeBucket == compareToItem.TimeBucket)
                return 0;
            else if (this.TimeBucket > compareToItem.TimeBucket)
                return 1;
            else
                return -1;
        }*/
    }
    
    
    global class InventoryGrid implements Comparable
    {
    	global string Product{get;set;}
    	global Decimal SortOrder{get;set;}
    	global Integer Total{get;set;}
    	global list<ResultRow> Quantities{get;set;}
    	
    	global Integer compareTo(Object compareTo) {
            
            inventoryGrid compareToItem = (InventoryGrid)compareTo;
            Integer other = compareToItem.sortOrder != null ? Integer.ValueOf(compareToItem.sortOrder) : 0;
            Integer thisOne = this.sortOrder != null ? Integer.ValueOf(this.sortOrder) : 0;
            return Integer.valueOf(thisOne - other);
            /*if (this.sortOrder == compareToItem.sortOrder)
                return 0;
            else if (this.sortOrder > compareToItem.sortOrder)
                return 1;
            else
                return -1;*/
        }
    }
    
    
    global list<string> getDailyTimeHeader()
    {
	    list<string> TimeHeaders = new list<string>();
		if(selectedDateRange != null)
		{
			Date selectedDate = System.today().addDays(selectedDateRange);
		    Date d = System.today(); 
		    
		    for(Integer i = 0; i < selectedDateRange; i++ )
			{
				Date dt = d.addDays(i);
				
				if(selectedDisplayBy == 'Month' && dt.day() != Date.daysInMonth(dt.year(), dt.month()))
				   continue;//skip everything but the last day of the month
				 
				 Datetime dtt = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
                 String dayOfWeek=dtt.format('EEEE');
				 if(selectedDisplayBy == 'Week' && 'Friday' != dayOfWeek)
				   continue;//skip everything but the last day of the week
				
				TimeHeaders.add(dtt.format('MMM-dd'));
				
			}
		}
		
		return TimeHeaders;
    }
    
	//======================================================================
	// Search Function
	global PageReference getDayResults()
	{
		 warehouseInventory = new list<InventoryGrid>();
		 transient list<InventoryGrid> grid = new list<InventoryGrid>();
		 if(selectedDateRange == null)
			 return null;
			 
		 transient map<String, Decimal> currentProductMap = new map<String, Decimal>();
		 Date selectedDate = System.today().addDays(selectedDateRange);
		 transient map<String, InventoryGrid> productMap = new map<String, InventoryGrid>();
		 transient set<String> dateSet = new set<String>();
		 
		 
		 //=================================================================
		 //Current Inventory
		 for(AggregateResult ar : [Select Product__r.Name, sum(Quantity__c) qty
			                         from Inventory__c
			                        where RecordType.Name = 'Current Inventory'
			                          and Warehouse__c = :selectedWarehouse
			                       group by Product__r.Name
			                       order by Product__r.Name])
		 {
		 	  string invDate = (System.today()).format();
		 	  currentProductMap.put(invDate +'^'+(String)ar.get('name'), (Decimal)ar.get('qty'));
		 	  
		 	  //Initialize the invintory grid
		 	  InventoryGrid ig = new InventoryGrid();
		 	  ig.Product = (String)ar.get('name');
		 	  ig.SortOrder = productSortOrder.get(ig.Product);
		 	  productMap.put((String)ar.get('name'), ig);
		 }
		 
		 
		 //============================================================================	 
		 //	+ Inventory Records with the Record Type “Manufacturing Forecast”  (ID: 012g00000008UbN) 
		 //	AND Date__c =< Selected Date 
		 //	AND Date__c > TODAY
		 for(AggregateResult ar : [Select Date__c, Product__r.Name, sum(Quantity__c) qty
			                         from Inventory__c
			                        where RecordType.name = 'Manufacturing Forecast'
			                          and Date__c <= :selectedDate
			                          and Date__c >= TODAY
			                          and Warehouse__c = :selectedWarehouse
			                       group by Date__c, Product__r.Name 
			                       order by Date__c, Product__r.Name]
			                       
			                       )
		 {
		 	  string invDate = (System.today()+1).format();
		 	  
		 	  if(((Date)ar.get('Date__c')) != null)
		 	  	invDate = ((Date)ar.get('Date__c')).format();
		 	  //get the current inventory for this product
		 	  //Decimal currentInventory = currentProductMap.get((System.today()).format()+'^'+(String)ar.get('name'));
		 	  if(currentProductMap.containsKey(invDate +'^'+(String)ar.get('name')))
		 	  {
			  	Decimal x = currentProductMap.get(invDate +'^'+(String)ar.get('name'));
			  	x += (Decimal)ar.get('qty');
			  	currentProductMap.put(invDate +'^'+(String)ar.get('name'), x);
		 	  }
		 	  else
		 	  	currentProductMap.put(invDate +'^'+(String)ar.get('name'), (Decimal)ar.get('qty'));
		 	  
		 	  //Initialize the invintory grid
		 	  InventoryGrid ig = new InventoryGrid();
		 	  ig.Product = (String)ar.get('name');
		 	  ig.SortOrder = productSortOrder.get(ig.Product);
		 	  productMap.put((String)ar.get('name'), ig);
		 }
		 
		 //============================================================================
		 //+Shipment Line Records with Matching Product where Shipment__r.Destination_Warehouse__c = Selected Warehouse  
		 //	AND Line_Status__c = “Shipped” 
		 //	AND Shipment__r.Delivery_Due_Date__c =< Selected Date 
		 //	AND Shipment__r.Delivery_Due_Date__c  > TODAY
		 transient map<string, Decimal>shipmentQuantityMap = new map<string, Decimal>();
		 for( AggregateResult ar : [  Select Shipment__r.Delivery_Due_Date__c, Product__r.Name, Product__r.Family, sum(Quantity__c) qty
		                         		from Shipment_Line_Item__c 
                                	   where Shipment__r.Destination_Warehouse__c = :selectedWarehouse
								  		 and Line_Status__c = 'Shipped'
								  		 and Shipment__r.Delivery_Due_Date__c<=:selectedDate
								 		 and Shipment__r.Delivery_Due_Date__c >= TODAY
								 		 and product__r.name in :productMap.keySet()
							    	   group by Shipment__r.Delivery_Due_Date__c,Product__r.Name, Product__r.Family])
		 {
		 	string invDate = ((Date)ar.get('Delivery_Due_Date__c')).format();
		 	string product = (String)ar.get('name');
		 	Decimal quantity = (Decimal)ar.get('qty');
		 	shipmentQuantityMap.put(invDate+'^'+product, quantity);
		 	
		 }
		 
		 //============================================================================
		 //- Shipment Line Records with Matching Product where Source_Warehouse__c = Selected Warehouse 
		 //	AND Line_Status__c = “Pending” OR Line_Status__c = “Scheduled” 
		 //	AND Shipment__r.Scheduled_Ship_Date__c = <Selected Date
		 //	AND Shipment__r.Scheduled_Ship_Date__c > TODAY
		 for( AggregateResult ar : [  Select Shipment__r.Scheduled_Ship_Date__c, Product__r.Name, sum(Quantity__c) qty
		                         		from Shipment_Line_Item__c
                                	   where SourceWarehouse__c = :selectedWarehouse
								  		 and Line_Status__c in ('Pending', 'Scheduled')
								  		 and Shipment__r.Scheduled_Ship_Date__c<=:selectedDate
								 		 and Shipment__r.Scheduled_Ship_Date__c >= TODAY
								 		 and product__r.name in :productMap.keySet()
							    	   group by Shipment__r.Scheduled_Ship_Date__c,Product__r.Name])
		 {
		 	string invDate = ((Date)ar.get('Scheduled_Ship_Date__c')).format();
		 	string product = (String)ar.get('name');
		 	Decimal quantity = ((Decimal)ar.get('qty'));
		 	
		 	if(shipmentQuantityMap.containsKey(invDate+'^'+product))
		 	{
		 		Decimal qty = shipmentQuantityMap.get(invDate+'^'+product);
		 		qty -= quantity;
		 		shipmentQuantityMap.put(invDate+'^'+product, qty);
		 	}
		 	else
		 	{
		 		shipmentQuantityMap.put(invDate+'^'+product, (quantity * (-1)));
		 	}
		 }
		 
		 //============================================================================
		 //- Shipment Line Records with Matching Product where
		 //	Shipment__r.Destination_Warehouse__r.In_Transit_Warehouse__c = Selected Warehouse
		 //	AND Line_Status__c = “Shipped”
		 //	AND Shipment__r.Delivery_Due_Date__c =< Selected Date 
		 //	AND Shipment__r.Delivery_Due_Date__c  > TODAY
		 for( AggregateResult ar : [  Select Shipment__r.Delivery_Due_Date__c, Product__r.Name, sum(Quantity__c) qty
		                         		from Shipment_Line_Item__c 
                                	   where Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c= :selectedWarehouse
								  		 and Line_Status__c = 'Shipped'
								  		 and Shipment__r.Delivery_Due_Date__c<=:selectedDate
								 		 and Shipment__r.Delivery_Due_Date__c >= TODAY
								 		 and product__r.name in :productMap.keySet()
							    	   group by Shipment__r.Delivery_Due_Date__c,Product__r.Name])
		 {
		 	string invDate = ((Date)ar.get('Delivery_Due_Date__c')).format();
		 	string product = (String)ar.get('name');
		 	Decimal quantity = ((Decimal)ar.get('qty'));
		 	
		 	if(shipmentQuantityMap.containsKey(invDate+'^'+product))
		 	{
		 		Decimal qty = shipmentQuantityMap.get(invDate+'^'+product);
		 		qty -= quantity;
		 		shipmentQuantityMap.put(invDate+'^'+product, qty);
		 	}
		 	else
		 	{
		 		shipmentQuantityMap.put(invDate+'^'+product, (quantity * (-1)));
		 	}
		 }
		 
		 //============================================================================
		 //Create the Results Grid
		 warehouseInventory.addAll(productMap.values());
		 warehouseInventory.sort();
		 //construct the return list
		 for(InventoryGrid ig : warehouseInventory)
		 {
			 Date dt = System.today();
			 ig.Quantities = new list<ResultRow>();
		     ig.Total = 0;
		     
		     Decimal shipmentOffset = 0;
		     Decimal inventoryOffset = 0;
		     
		     //load the daily quantities
		    for(Integer i = 0; i < selectedDateRange; i++ )
			{
				 Date d = dt.addDays(i);
				 
				 //record the shipment offset
				 Decimal sq = shipmentQuantityMap.get(d.format()+'^'+ig.Product);
				 if(sq != null)
				   shipmentOffset += sq;
				 //record the inventory quantity
				 Decimal iq = currentProductMap.get(d.format()+'^'+ig.Product);
				 if(iq != null)
				   inventoryOffset += iq;
				 
				 if(selectedDisplayBy == 'Month' && d.day() != Date.daysInMonth(d.year(), d.month()))
				   continue;//skip everything but the last day of the month
				 
				 Datetime dtt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
                 String dayOfWeek=dtt.format('EEEE');
				 if(selectedDisplayBy == 'Week' && 'Friday' != dayOfWeek)
				   continue;//skip everything but the last day of the week
				   
				 ResultRow rr = new ResultRow();
		 	     rr.TimeBucket = d;
		 	     rr.Product = ig.Product;
		 	     rr.Quantity = 0 + shipmentOffset + inventoryOffset;	
		 		 ig.Quantities.add(rr);
				 
				   
				 
		 	}
		 }
		 System.debug(':::::warehouseInventory Size::::>'+ warehouseInventory.size());
		 return null;
	}
	
	public list<InventoryGrid> getCenimaInventory()
	{
		list<InventoryGrid> grid = new list<InventoryGrid> ();
		warehouseInventory.sort();
		for(InventoryGrid ig : warehouseInventory)
		{
			if(productTypeMap.get(ig.Product) == 'Cinema')
			  grid.add(ig);
		}
		return grid;
	}
	
	public list<InventoryGrid> getMountInventory()
	{
		list<InventoryGrid> grid = new list<InventoryGrid> ();
		for(InventoryGrid ig : warehouseInventory)
		{
			if(productTypeMap.get(ig.Product) == 'Mounts')
			  grid.add(ig);
		}
		return grid;
	}
	
	@isTest
	static void testThisClass()
	{
		//create the base Inventory Records
		// Create test Data
        Account acc = TestClientUtility.createAccount();
        acc.ShippingStreet = '123';
		acc.ShippingCity = 'abc';
		acc.ShippingState = 'CA';
		acc.ShippingPostalCode = '90210';
		acc.ShippingCountry = 'USA';
		
		insert acc;
		Warehouse__c trasitWarehouse = TestClientUtility.createWarehouse(acc.Id);
	    trasitWarehouse.name = 'RealD Finished Goods';
	    trasitWarehouse.Street_Address__c = '123';
		trasitWarehouse.City__c = 'xyz';
		trasitWarehouse.State__c = 'NY';
		trasitWarehouse.Postal_Code__c = '11101';
		trasitWarehouse.Country__c = 'USA';
		trasitWarehouse.Include_in_Inventory__c = true;
		trasitWarehouse.WarehouseSortOrder__c = 98;
		trasitWarehouse.Warehouse_Type__c = 'In Transit';
		trasitWarehouse.Account__c = acc.Id;
		
	    insert trasitWarehouse;
	    
		Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
	    wh.name = 'RealD Finished Goods';
	    wh.Street_Address__c = '123';
		wh.City__c = 'xyz';
		wh.State__c = 'NY';
		wh.Postal_Code__c = '11101';
		wh.Country__c = 'USA';
		wh.Include_in_Inventory__c = true;
		wh.WarehouseSortOrder__c = 99;
		wh.InTransitWarehouse__c = trasitWarehouse.Id;
		wh.Account__c = acc.Id;
		
	    insert wh;
	    
	    Case c = TestClientUtility.createCase();
        insert c;
       
        Product2 prod = TestClientUtility.createProduct2();
        prod.Serialized__c = true;
        prod.Family = 'Cinema';
        insert prod;
        
        Product2 prod2 = TestClientUtility.createProduct2();
        prod2.Serialized__c = true;
        prod2.Family = 'Mounts';
        insert prod2;
	    
	    Circuits__c cir = TestClientUtility.createCircuit();
        insert cir;
        
       
        Screens__c screen = TestClientUtility.createScreen(acc.Id);
        insert screen;
       
        Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, wh.Id, prod.Id);
        a.SerialNumber = 'test123123123';
	    insert a;
       
        Contact con = TestClientUtility.createContact(acc.Id);
                                
        con.Circuit__c = cir.id;
       
        insert con;
	    
	    Inventory__c i = TestClientUtility.createInventory(wh.Id, prod.Id);
	    RecordType rt = [Select Id from RecordType where Name = 'Current Inventory'];
		i.Approved__c = TRUE;
	    i.RecordTypeId = rt.Id;
	    i.Quantity__c = 2;
	    insert i;
		
		
		//Create the Projected Inventory Records
		Inventory__c i2 = TestClientUtility.createInventory(wh.Id, prod2.Id);
	    RecordType rt2 = [Select Id from RecordType where Name = 'Manufacturing Forecast'];
		i2.Approved__c = TRUE;
	    i2.RecordTypeId = rt2.Id;
	    i2.Date__c = System.today() + 2;
	    i2.Quantity__c = 3;
	    i2.Warehouse__c = wh.Id;
	    insert i2;
	   
		
		
		//create the shipment off-sets
		Shipment__c ship = TestClientUtility.createShipment(acc.Id, cir.Id, con.Id, screen.Id, wh.Id, wh.Id, prod.Id, a.Id, c.Id);
        ship.Status__c = 'Shipped';
        ship.Scheduled_Ship_Date__c = System.today() + 1;
        ship.Delivery_Due_Date__c = System.today() + 1;
        ship.Destination_Warehouse__c = wh.Id;
	    insert ship;
	    
	    
	    Shipment_Line_Item__c sli = TestClientUtility.createShipmentLineItem(ship.Id, prod.Id, wh.Id, screen.Id);
	    sli.SerialNumber__c = 'test123123123';
	    sli.SourceWarehouse__c = wh.Id;
		sli.Line_Status__c  = 'Pending';
		sli.Quantity__c = 1;
	    insert sli;
	    
	    Shipment_Line_Item__c sli2 = TestClientUtility.createShipmentLineItem(ship.Id, prod.Id, wh.Id, screen.Id);
	    sli2.SerialNumber__c = 'test1231231234';
	    sli2.Line_Status__c = 'Shipped';
		sli2.Quantity__c = 1;
		insert sli2;
		
		Shipment_Line_Item__c sli3 = TestClientUtility.createShipmentLineItem(ship.Id, prod.Id, wh.Id, screen.Id);
	    sli3.SerialNumber__c = 'test123123123';
	    sli3.SourceWarehouse__c = wh.Id;
		sli3.Line_Status__c  = 'Pending';
		sli3.Quantity__c = 1;
	    insert sli3;
	    
	    Shipment_Line_Item__c sli4 = TestClientUtility.createShipmentLineItem(ship.Id, prod.Id, wh.Id, screen.Id);
	    sli4.SerialNumber__c = 'test1231231234';
	    sli4.Line_Status__c = 'Shipped';
		sli4.Quantity__c = 1;
		insert sli4;
		
		
		//Run the Controller Methods
		ProjectedInventoryController ctl = new ProjectedInventoryController();
		ctl.selectedDateRange = 14;
		ctl.selectedDisplayBy = 'Day';
		ctl.selectedWarehouse = wh.Id;
		ctl.getDailyTimeHeader();
		ctl.getDateRangeOptions();
		ctl.getDisplayByOptions();
		ctl.getDayResults();
		//grid.sort();
		ctl.getWarehouseOptions();
		ctl.getMountInventory();
		ctl.getCenimaInventory();
		
		ctl.selectedDateRange = 14;
		ctl.selectedDisplayBy = 'Week';
		ctl.getDailyTimeHeader();
		ctl.getDateRangeOptions();
		ctl.getDisplayByOptions();
		ctl.getDayResults();
		ctl.getWarehouseOptions();
		
		ctl.selectedDateRange = 90;
		ctl.selectedDisplayBy = 'Month';
		ctl.getDailyTimeHeader();
		ctl.getDisplayByOptions();
		ctl.getDateRangeOptions();
		ctl.getWarehouseOptions();
		
		ctl.selectedDateRange = 14;
		ctl.selectedDisplayBy = 'Day';
		ctl.selectedWarehouse = trasitWarehouse.Id;
		ctl.getDailyTimeHeader();
		ctl.getDateRangeOptions();
		ctl.getDisplayByOptions();
		ctl.getDayResults();
		ctl.getWarehouseOptions();
		
		
	}

}