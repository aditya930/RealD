@isTest
private class TestUpdateAssetTheatreAndScreenOnTrans {

    static testMethod void runTest() {
        Circuits__c cir = TestClientUtility.createCircuit();
        cir.Circuit_Type__c = 'Cinema';
        insert cir;
        
       Account acc = TestClientUtility.createAccount();
       acc.Circuit__c = cir.Id;
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
       
       RecordType rt = [Select Id from RecordType where name = 'Move' and SObjectType = 'Asset_Transfer__c'];
        Asset_Transfer__c ast = TestClientUtility.createAssetTransfer(a.Id, screen.Id, screen.Id, System.today(), System.today());
        ast.RecordTypeId = rt.Id;
        insert ast;
        
       //execute the controller methods
       PageReference pageRef = Page.UpdateScreenAssetTransferRollupsPage;
       test.setCurrentPage(pageRef);
       
       apexPages.StandardController ctlr = new apexPages.StandardController(screen);
       UpdateScreenAssetTransferRollups ctl = new UpdateScreenAssetTransferRollups(ctlr);
       
       
       //run tests for the asset transfer triggers
       ast.RecordTypeId = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Install').getRecordTypeId();
	   update ast;
	   
	   ast.RecordTypeId = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Move').getRecordTypeId();
	   update ast;
	   ctl.runUpdate();
	   ast.RecordTypeId = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Return').getRecordTypeId();
       update ast;
       
       ast.RecordTypeId = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Warehouse Transfer').getRecordTypeId();
	   ast.Destination_Warehouse__c = wh.Id;
	   update ast;
       
       Case c = TestClientUtility.createCase();
       c.Destination_Warehouse__c = wh.Id;
       c.Screen__c = screen.Id;
       c.assetId = a.Id;
       c.Waiting_for_Return__c = System.Today();
       c.Product_Received__c = System.Today();
       insert c;
       update c;
       
       
	   
    }
}