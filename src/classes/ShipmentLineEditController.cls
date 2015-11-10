public with sharing class ShipmentLineEditController {
	
	public Id shipmentWithScreen{get;set;}
	public Id shipmentId{get;set;}
	public ShipmentLineEditController(ApexPages.StandardController ctl)
	{
		Shipment_Line_Item__c sli = new Shipment_Line_Item__c();
		for( Shipment_Line_Item__c s : [Select Id, Shipment__c from Shipment_Line_Item__c where Id =  :ctl.getId()])
		  sli = s;
		
		
		if(sli.Id == null)
		   shipmentId = ((String)ApexPages.currentPage().getParameters().get('retURL')).substring(1,16);
		else
		  shipmentId = sli.Shipment__c;
		  
		for(Shipment_Line_Item__c s  :  [Select Shipment__c
                                           from Shipment_Line_Item__c
                                          where Shipment__r.Shipment_Type__c = 'New Install' 
                                            and Shipment__c = :shipmentId limit 1])
       {
       	   shipmentWithScreen = s.Shipment__c;
       	   break;
       }
	}
	
	public PageReference screenChange()
	{
		return null;
	}
	
	
    static testmethod void runTest()
    {
    	Case c = TestClientUtility.createCase();
       insert c;
       
       Product2 prod = TestClientUtility.createProduct2();
                                   
       insert prod;
        
	   Account acc =TestClientUtility.createAccount();
	                            
	   insert acc;
	   
	   Circuits__c cir = TestClientUtility.createCircuit();
       insert cir;
        
       
       Screens__c screen = TestClientUtility.createScreen(acc.Id);
       insert screen;
       
       Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
       insert wh;
             
       Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, wh.Id, prod.Id);
	   insert a;
       
       Contact con = TestClientUtility.createContact(acc.Id);
                                
       con.Circuit__c = cir.id;
       
       insert con;
       
       Shipment__c ship = TestClientUtility.createShipment(acc.Id, cir.Id, con.Id, screen.Id, wh.Id, wh.Id, prod.Id, a.Id, c.Id);
	   insert ship;
    	Shipment_Line_Item__c sli = TestClientUtility.createShipmentLineItem(ship.Id, prod.Id, wh.Id, screen.Id);
	   insert sli;
       
       ApexPages.StandardController ctl = new ApexPages.StandardController(sli);
       ShipmentLineEditController sc = new ShipmentLineEditController(ctl);
      
       PageReference p = Page.ShipmentLineEdit;
       p.getParameters().put('retURL', '/001/e');
       Test.setCurrentPage(p);
       
       sc.screenChange();
    }
	
	
}