@isTest
private class TestCaseLastActivity {

    static testMethod void myUnitTest() {

       Case cse = TestClientUtility.createCase();
       cse.Type = 'RMA Request';
       cse.Status = 'New';
       
       insert cse; 
       
       Task tsk =TestClientUtility.createTask(null,cse.Id);
       
       insert tsk;
        

    }
}