/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPackOutController {

        
    private static testmethod void runTest()
    {
    	//create an asset
    	Account a = TestClientDmlUtil.createAccount();
    	insert a;
    	
    	Screens__c scrn = TestClientDmlUtil.createScreen(a);
    	insert scrn;
    	
    	Warehouse__c w = TestClientDmlUtil.createWarehousewh(a);
    	insert w;
    	
    	Product2 p = TestClientDmlUtil.createProduct2();
    	insert p;
    	
    	Asset ast = TestClientDmlUtil.createAsset(scrn, w, a, p);
    	insert ast;
    	
    	//set the test page and Id
    	Test.setCurrentPage(Page.PackOutLabel);
    	ApexPages.currentPage().getParameters().put('Id', ast.Id);
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(ast);
    	
    	
    	//execute the controller method
    	PackOutController ctl = new PackOutController(sc);
    	
    	PackOutController.createPackout();
    	
    	//verify the results
    	System.assertEquals(ast.Id, [select Asset__c from Pack_Out__c where Asset__c = :ast.Id].Asset__c);
    	
    	PackOutController.createPackout();//exception block
    }
}