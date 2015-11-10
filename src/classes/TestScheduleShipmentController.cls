@isTest
public class TestScheduleShipmentController{
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
       ship.Status__c = 'Pending';
       insert ship;
        
       Shipment_Line_Item__c sli = TestClientUtility.createShipmentLineItem(ship.Id, prod.Id, wh.Id, screen.Id);
       insert sli;
       
       ApexPages.StandardController ctl = new ApexPages.StandardController(ship);
       ScheduleShipmentController sc = new ScheduleShipmentController(ctl);
      
       PageReference p = Page.ScheduleShipment;
       p.getParameters().put('id', ship.Id);
       Test.setCurrentPage(p);
       
       sc.scheduleShipment();
       
       
       sc.scheduleShipment();
    }
}