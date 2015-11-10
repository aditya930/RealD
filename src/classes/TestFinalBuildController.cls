@isTest
private class TestFinalBuildController {

    static testMethod void runTest() {
       //create test data
       Account acc = TestClientUtility.createAccount();
       insert acc;
       
       Screens__c screen = TestClientUtility.createScreen(acc.Id);
       insert screen;
       
       Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
       insert wh;
       
       Product2 p = TestClientUtility.createProduct2();
       insert p;
       
       Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, null, p.Id);
	   insert a; 
	   
	   
	   //execute the controller methods
       PageReference pageRef = Page.FinalProductBuild;
       test.setCurrentPage(pageRef);
       
       apexPages.StandardController ctlr = new apexPages.StandardController(a);
       finalProductBuildController ctl = new finalProductBuildController(ctlr);
       try{
          ctl.save();
       }
       catch(Exception e)
       {
       	  System.debug(e);
       }
    }
}