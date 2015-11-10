@isTest
private class TestCancelShipment {

    static testMethod void renTest() {
       
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
	   
	   Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
            req1.setObjectId(ship.id);
        
     
        Approval.ProcessResult result = Approval.process(req1);
	   
	   //run tests
	   Test.setCurrentPage(Page.CancelShipment);
	   ApexPages.currentPage().getParameters().put('Id',ship.Id);
       ApexPages.StandardController ac = new ApexPages.StandardController(ship);
	   CancelShipmentController ctl = new CancelShipmentController(ac);
	   ctl.cancelShipment();
	   
	   ship.Status__c = 'Shipped';
	   update ship;
	   
	   ctl.cancelShipment();
	   
    }
}