@isTest
private class TestCreateTIFCircuitTheatreScreenContact {

    static testMethod void runTest(){
	//
		map<String,Product_Shipment_RecordType_Map__c> prod = Product_Shipment_RecordType_Map__c.getAll();
		//[select Id, name from Product_Shipment_RecordType_Map__c limit 1];//new Product2(name = 'testprodx'
	                           
	                                   
	   //    insert prod;
	
	   TIF__c t = TestClientUtility.createTif(prod.values()[0].Name);
	   insert t;
	   
	   ApexPages.StandardController ac = new ApexPages.StandardController(t);
	   CreateTIFCircuitTheatreScreenContact ctl = new CreateTIFCircuitTheatreScreenContact(ac);
	   ctl.run();
    }
}