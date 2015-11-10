@isTest
private class TestAssetRecordCreationButrtonCtl {

    static testMethod void runTest() {
       
       Account acc = TestClientUtility.createAccount();
       insert acc;
       
       //create test data
       Screens__c screen = TestClientUtility.createScreen(acc.Id);
       insert screen;
       
       Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
       insert wh;
       
       Product2 p = TestClientUtility.createProduct2();
       insert p;
       
       Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, null, p.Id);
	   insert a; 
	   
       //execute the controller methods
       PageReference pageRef = Page.AssetRecordCreationButrton;
       test.setCurrentPage(pageRef);
       
       apexPages.StandardController ctlr = new apexPages.StandardController(a);
       AssetRecordCreationButrtonCtl ctl = new AssetRecordCreationButrtonCtl(ctlr);
	   
	   ctl.curAsset = a;
	   
	   ApexPages.currentPage().getParameters().put('Id', a.Id) ;
       ApexPages.currentPage().getParameters().put('transfertype','Move') ;
       ctl.createAssetTransfer();
	   
	   ApexPages.currentPage().getParameters().put('transfertype','Return') ;
       ctl.createAssetTransfer();
       
       ApexPages.currentPage().getParameters().put('transfertype','Install') ;
       ctl.createAssetTransfer();
	   
	   ApexPages.currentPage().getParameters().put('transfertype','WarehouseTransfer') ;
       ctl.createAssetTransfer();
    }
}