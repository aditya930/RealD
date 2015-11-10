@isTest
public class Test_NewReturnLogController {
    
    public static testMethod void test_NewReturnLogController() {

        //Insert Return Log
        Return_Log__c ret = new Return_Log__c (
         Serial_Number_Manual__c = '999999'
		, Serial_Not_Found_in_Salesforce__c = TRUE
		, Product__c= 'XLS');                                
        insert ret;
        
        //Retrieve the new Return Log
    ret = [Select Id, Name FROM Return_Log__c WHERE Id =:ret.Id];
        
        String retID = ret.Id;
    	System.debug(retID);

    	//NewReturnLogController cont = new NewReturnLogController();
        NewReturnLogController cont = new NewReturnLogController(new ApexPages.StandardController(new Return_Log__c()));
    
    	PageReference FlowContractPageRef = Page.NewReturnLog;
    	Test.setCurrentPage(FlowContractPageRef);

    	string var_ReturnLogRecordID=retId;
    	cont.getnewReturnLog();
    	cont.newRecordID();
    
    	System.test.startTest();
    	System.debug('ReturnLogID - Add ReturnLogID'); 
    	System.debug('ReturnLogID - Save');
    	System.test.stopTest();
        

}   
    
}