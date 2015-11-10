@isTest
public class TestclsCheckAttachments{
    static testMethod void testMethod1() {
        Circuits__c testCircuit = new Circuits__c(
                                    Name = 'test',
                                    Circuit_Type__c = 'test',
                                    Country__c = 'testCountry'
                                    );
            INSERT testCircuit;

        CA_Key_Request__c testKeyRequest = new CA_Key_Request__c(
                                                Circuit__c = testCircuit.ID,
                                                License_Begin_Date__c = Date.Today(),
                                                License_End_Date__c = Date.Today()+50
                                                );
            INSERT testKeyRequest;

        CA_Key_Request__c testKeyRequest2 = new CA_Key_Request__c(
                                                Circuit__c = testCircuit.ID,
                                                License_Begin_Date__c = Date.Today(),
                                                License_End_Date__c = Date.Today()+50,
                                                Status__c = 'Keys Ready for Download'
                                                );
            INSERT testKeyRequest2;

        
        clsCheckAttachments objChkAttach = new clsCheckAttachments();
        clsCheckAttachments.chkAtt(testKeyRequest.ID);
        
        Boolean check = clsCheckAttachments.chkAtt(testKeyRequest2.ID);
        System.assertEquals(check,true);

   }

}