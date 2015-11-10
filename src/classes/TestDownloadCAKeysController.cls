/*Test Class for DownloadCAKeysController Controller Class
Created By: Suyati Technologies*/

@IsTest
Public Class TestDownloadCAKeysController {
    
    @IsTest Static void insertTestRecords() {
        Circuits__c testCircuit = new Circuits__c(Name = 'TestCircuit', Circuit_Email__c = 'test@test.com', Country__c = 'testCountry');
        INSERT testCircuit;
        
        Account testAccount = new Account(Name = 'TestAccount', Circuit__c = testCircuit.Id, BillingCountry = 'India', Theatre_Name_Chinese__c = 'testThatre');
        INSERT testAccount;
        
        Screens__c testScreen = TestClientDmlUtil.createScreen(testAccount);
        Warehouse__c testWarehouse = TestClientDmlUtil.createWarehousewh(testAccount);
        
        Contact testContact = new Contact(LastName = 'testName', Circuit__c = testCircuit.ID);
        INSERT testContact;
        
        Product2 testProduct = new Product2(Name = 'testProduct', ConditionalAccess__c = true);
        INSERT testProduct;
               
        Asset testAsset = TestClientDmlUtil.createAsset(testScreen, testWarehouse, testAccount, testProduct);
        testAsset.Encryption_Key_01__C = 12345678;
        testAsset.Encryption_Key_02__C = 12345678;
        testAsset.Encryption_Key_03__C = 12345678;
        testAsset.Encryption_Key_04__C = 12345678;
        INSERT testAsset;
        
        CA_Key_Request__c testKeyRequest = new CA_Key_Request__c(Circuit__c = testCircuit.Id, License_Begin_Date__c = date.valueOf('2015-10-01'), License_End_Date__c = date.valueOf('2015-11-01'));       
        INSERT testKeyRequest;
        
        Key_Request_Asset__c testKeyRequestAsset = new Key_Request_Asset__c(Asset__c = testAsset.ID, Key_Request__c = testKeyRequest.ID);
        INSERT testKeyRequestAsset;
        
        License_Key__c testLicenseKey = new License_Key__c(Asset__c = testAsset.ID, License_Begin_Date__c = Date.Today(), License_End_Date__c = Date.Today()+50, License_Key_Request__c  = testKeyRequest.ID);
        INSERT testLicenseKey;

        License_Key__c testLicenseKey_2 = new License_Key__c(Asset__c = testAsset.ID, License_Begin_Date__c = Date.Today(), License_End_Date__c = Date.Today()+50, License_Key_Request__c  = testKeyRequest.ID);
        INSERT testLicenseKey_2;
        
        Attachment testAttachment = new Attachment(Name = 'testfile.zip', Body = Blob.valueOf('Unit Test Attachment Body'), ParentId = testLicenseKey.Id);
        INSERT testAttachment;

        Attachment testAttachment_2 = new Attachment(Name = 'testfile.zip', Body = Blob.valueOf('Unit Test Attachment Body'), ParentId = testLicenseKey_2.Id);
        INSERT testAttachment_2;
                
        Test.startTest();
        ApexPages.currentpage().getparameters().put('recID',testKeyRequest.ID);
        DownloadCAKeysController execute = new DownloadCAKeysController();
        DownloadCAKeysController.getAttachments(testKeyRequest.Id);
        execute.currentRecordId = testKeyRequest.Id;
        execute.zipContent = '12323hihf34454390';
        License_Key__c testKey1 = [SELECT Id FROM License_Key__c WHERE ID=: testLicenseKey.ID LIMIT 1];
        System.assertNotEquals(null, testKey1);
        Test.stopTest();
    }

}