global class ShipmentOverrideCtl {
	public boolean showChoice{get;set;}
	public Shipment__c shipment{get;set;}
	public ShipmentOverrideCtl(ApexPages.StandardController ctlr)
	{
		shipment = [Select Id, Scheduled_Ship_Date__c,Status__c, Screen__r.Number_of_Installed_Cinema_Systems__c
		              from Shipment__c 
		             where Id = :ctlr.getId() ];
		if(shipment.scheduled_Ship_Date__c != null && shipment.Screen__r.Number_of_Installed_Cinema_Systems__c >=1 && shipment.Status__c == 'Pending')
		  showChoice =  true;
		
		
	}
	
	
    static testMethod void runTest() {
    	
    	Product2 prod = new Product2(name = 'testprodx'
                                   ,Generic_Name__c = 'testGenProdx');
                                   
       insert prod;
        
	   Account acc = new Account(name='testAcc1'
	                            ,BillingCountry = 'USA');
	                            
	    insert acc;
        
       //create test data
       Screens__c screen = new Screens__c(Theater__c = acc.Id
                                         ,Name = 'testScreen 1');
       insert screen;
       
       Warehouse__c wh = new Warehouse__c(name = 'testwarehsouse1'
                                          ,Account__c = acc.Id
                                          ,Warehouse_Type__c = 'RealD Distribution');
       insert wh;
       
             
       Asset a = new Asset(Screen__c = screen.Id
		                 , Product2Id = prod.Id
		                 , Name = 'testx1'
		                 , Warehouse__c = wh.Id
		                 , accountId = acc.Id);
	   insert a;
       
       
       Shipment__c ship = new  Shipment__c(Actual_Ship_Date__c = System.now()
						                 //, Source_Warehouse__c = wh.id
						                 , Destination_Warehouse__c = wh.Id
						                 , Asset_1__c = a.Id
						                 , Screen__c =screen.Id
						                 , Status__c = 'Shipped'
						                 //, Mount__c = null
						                 //, Return_Labels_Kit__c = 'testGenProdx'
						                 );
	   insert ship;
	   
	   ApexPages.StandardController ac = new ApexPages.StandardController(ship);
    	ShipmentOverrideCtl c = new ShipmentOverrideCtl(ac);
    	
        
    }
    
}