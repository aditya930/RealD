@isTest
private class TestUpdateAssetTheatreAndScreen {

    static testMethod void runTest() {
    	
    	
    	Circuits__c cir = TestClientUtility.createCircuit();
    	cir.Circuit_Type__c = 'Cinema';
    	cir.Country__c = 'USA';
        insert cir;
        
       Account acc = TestClientUtility.createAccount();
       acc.Circuit__c = cir.Id;
       acc.billingCountry='USA';
       insert acc;
       
       //create test data
       Screens__c screen = TestClientUtility.createScreen(acc.Id);
       insert screen;
       
       Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
       insert wh;
       
       Product2 p = TestClientUtility.createProduct2();
       insert p;
       
       Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, wh.Id, p.Id);
	   insert a;
       
        Asset_Transfer__c ast = TestClientUtility.createAssetTransfer(a.Id, screen.Id, screen.Id, System.today(), System.today() );
        insert ast;
        
        ast.Update_Asset__c = true;
        update ast;
    	
    }
}