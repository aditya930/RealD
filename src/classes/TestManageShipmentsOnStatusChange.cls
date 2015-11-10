@isTest
private class TestManageShipmentsOnStatusChange {

    static testMethod void runTest() {
        
       Case c = TestClientUtility.createCase();
       c.Type = 'RMA Rwquest';
       c.Status = 'New'; 
       insert c;
       
       Product2 prod = TestClientUtility.createProduct2();
       insert prod;
        
	   Account acc = TestClientUtility.createAccount();
	   insert acc;
	   
	   Circuits__c cir = TestClientUtility.createCircuit();
       insert cir;
        
       //create test data
       Screens__c screen = TestClientUtility.createScreen(acc.Id);
       insert screen;
       
       Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
       wh.Warehouse_Type__c = 'RealD Distribution';
       insert wh;
       
             
       Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, wh.Id, prod.Id);
	   insert a;
       
       Contact con = TestClientUtility.createContact(acc.Id);
       con.Circuit__c = cir.id;
       insert con;
       
       Shipment__c ship = TestClientUtility.createShipment(acc.Id, cir.Id, con.Id, screen.Id, wh.Id, wh.Id, prod.Id, a.Id, c.Id);
       //ship.Return_to_Warehouse__c = wh.Id;
	   ship.Shipping_Service_Type__c	='Domestic Ground';
	   ship.Scheduled_Ship_Date__c = System.today() + 5;
	   //ship.Return_Labels_Kit__c = 'testGenProdx';
	   insert ship;
	   
	   //ship.Mount__c = 'testGenProdx';
	   update ship;
	   
	   //ship.Ship_to_Warehouse__c = true;
	   //update ship;
	   /*
	   ship.Line_1_Serial_Number__c = '11';
	   ship.Line_2_Serial_Number__c = '22';
	   ship.Line_3_Serial_Number__c = '13';
	   ship.Line_4_Serial_Number__c = '14';
	   ship.Line_5_Serial_Number__c = '15';
	   
	   ship.Line_1_Product__c = prod.Id;
	   ship.Line_2_Product__c = prod.Id;
	   ship.Line_3_Product__c = prod.Id;
	   ship.Line_4_Product__c = prod.Id;
	   ship.Line_5_Product__c = prod.Id;
	   */
	   
	   ship.Status__c = 'Shipped';
	   update ship;
	   
	   
	   
    }
}