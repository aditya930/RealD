@isTest
private class TestBatch_ScreenAssetTransferRollUps {

    static testMethod void runTest() {
   
       Account acc = TestClientUtility.createAccount();
       insert acc;
       
       Account acc2 = TestClientUtility.createAccount();
       acc2.Name = 'test-2';
       insert acc2;
       
       //create test data
       Screens__c screen = TestClientUtility.createScreen(acc.Id);
       insert screen;
       
       Screens__c screen2 = TestClientUtility.createScreen(acc2.Id); 
       insert screen2;
       
       
       Account acc3 = TestClientUtility.createAccount();
       insert acc3;
       
       Account acc4 = TestClientUtility.createAccount();
       acc2.Name = 'test-4';
       insert acc4;
       
       //create test data
       Screens__c screen3 = TestClientUtility.createScreen(acc3.Id);
       insert screen3;
       
       Screens__c screen4 = TestClientUtility.createScreen(acc4.Id); 
       insert screen4;
     
       
       Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
       insert wh;
       
       Warehouse__c wh2 = TestClientUtility.createWarehouse(acc2.Id);
       insert wh2;
       
       Warehouse__c wh3 = TestClientUtility.createWarehouse(acc3.Id);
       insert wh3;
       
       Warehouse__c wh4 = TestClientUtility.createWarehouse(acc4.Id);
       insert wh4;
       
       Product2 p = TestClientUtility.createProduct2();
       p.Include_in_Cinema_Systems_Count__c = true;
       insert p;
       
       Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, wh.Id, p.Id);
       a.name = 'test123';
        a.SerialNumber = 'test123';
	   insert a;
       Asset a2 = TestClientUtility.createAsset(acc2.Id, screen2.Id, wh2.Id, p.Id);
        a2.Name = 'test1234';
        a2.SerialNumber = 'test1234';
	   insert a2;
       Asset a3 = TestClientUtility.createAsset(acc3.Id, screen3.Id, wh3.Id, p.Id);
        a3.Name = 'test12345';
        a3.SerialNumber = 'test12345';
	   insert a3;
       Asset a4 = TestClientUtility.createAsset(acc4.Id, screen4.Id, wh4.Id, p.Id);
        a4.Name = 'test123456';
        a4.SerialNumber = 'test123456';
	   insert a4;
       RecordType rt = [Select Id from RecordType where name = 'Move' and SObjectType = 'Asset_Transfer__c'];
       Asset_Transfer__c ast = TestClientUtility.createAssetTransfer(a.Id, screen.Id, screen2.Id, System.today(), System.today() );
       ast.RecordTypeId = rt.Id;
       insert ast;
    	
       Asset_Transfer__c ast2 = TestClientUtility.createAssetTransfer(a2.Id, screen2.Id, screen3.Id, System.today(), System.today() );
       insert ast2;
       
       Asset_Transfer__c ast3 = TestClientUtility.createAssetTransfer(a3.Id, screen3.Id, screen4.Id, System.today(), System.today() );
       insert ast3;
       Test.startTest();
         Batch_ScreenAssetTransferRollUps b = new Batch_ScreenAssetTransferRollUps();
         Database.executeBatch(b);
	   Test.stopTest();
         
        
    }
}