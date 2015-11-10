public with sharing class ShipmentLineItemDeleteOverride {
	
	public ShipmentLineItemDeleteOverride(ApexPages.StandardController ctl)
	{
		
	}
	public PageReference deleteShipmentLineItem()
	{
		  
		  try
		  {
			  Shipment_Line_Item__c li = [select Shipment__c, Shipment__r.Status__c from Shipment_Line_Item__c where Id = :ApexPages.currentPage().getParameters().get('id')];
		  	  
		  	  if(li.Shipment__r.Status__c == 'Pending')
			  {
			  	Id shipmentId = li.Shipment__c;
			    delete li;
			    return new PageReference('/'+shipmentId);
			  }
			  else {
			  	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only Lines on Pending Shipments can be Deleted.'));
			  }
		  }
		  catch(Exception e)
		  {
		  	ApexPages.addMessages(e);
		  }
		  
		  return null;
	}
	
	static testmethod void runTest()
    {
       //create test data
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
	   PageReference p = Page.ShipmentLineItemDeleteOverride;
	   p.getParameters().put('Id', sli.Id);
	   Test.setCurrentPage(p);
	   
       ShipmentLineItemDeleteOverride o = new ShipmentLineItemDeleteOverride(ctl);
       
       o.deleteShipmentLineItem();
        
       ship.Status__c = 'Pending';
	   update ship;
       
       o.deleteShipmentLineItem();
       
       p.getParameters().put('Id', 'thisIsBad');
       o.deleteShipmentLineItem();
       
    }

}