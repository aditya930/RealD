/*Test Class for NewCAKeyRequestController Controller Class
Created By: Suyati Technologies*/
@isTest
public class TestNewCAKeyRequestController{
    
    static testMethod void testMethod1() {

        Circuits__c testCircuit = new Circuits__c(
                                Name = 'test',
                                Circuit_Type__c = 'test',
                                Country__c = 'testCountry'
                                );
        INSERT testCircuit;

        Account testAccount = new Account(
                                Name = 'testAcc',
                                Circuit__c = testCircuit.Id,
                                Theatre_Name_Chinese__c = 'testThatre',
                                Account_Type__c = 'Cinema',
                                BillingCity = 'testCity',
                                BillingState = 'testState',
                                BillingPostalCode = '44255',
                                BillingCountry = 'testCountry'
                                );
        INSERT testAccount;

        Contact testContact = new Contact(
                                LastName = 'testName',
                                Circuit__c = testCircuit.ID
                                );

        INSERT testContact;

        CA_Key_Request__c testKeyRequest = new CA_Key_Request__c(
                                            Circuit__c = testCircuit.ID,
                                            License_Begin_Date__c = Date.Today(),
                                            License_End_Date__c = Date.Today()+50
                                            );
        INSERT testKeyRequest;

        Product2 testProduct = new Product2(
                                Name = 'testProduct',
                                ConditionalAccess__c = true
                                );

        INSERT testProduct;

        Screens__c testScreen = TestClientDmlUtil.createScreen(testAccount);
                
        Warehouse__c testWarehouse = TestClientDmlUtil.createWarehousewh(testAccount);

        Asset testAsset = TestClientDmlUtil.createAsset(testScreen, testWarehouse, testAccount, testProduct);
        testAsset.Encryption_Key_01__C = 12345678;
        testAsset.Encryption_Key_02__C = 12345678;
        testAsset.Encryption_Key_03__C = 12345678;
        testAsset.Encryption_Key_04__C = 12345678;
        
        INSERT testAsset;
        

        Key_Request_Asset__c testKeyRequestAsset = new Key_Request_Asset__c(
                                                    Asset__c = testAsset.ID,
                                                    Key_Request__c = testKeyRequest.ID
                                                    );

        INSERT testKeyRequestAsset;

        License_Key__c testLicenseKey = new License_Key__c(
                                            Asset__c = testAsset.ID,
                                            License_Begin_Date__c = Date.Today(),
                                            License_End_Date__c = Date.Today()+50,
                                            License_Key_Request__c  = testKeyRequest.ID
                                            );

        INSERT testLicenseKey;

        Shipment__c testShipment = new Shipment__c(
                                
                                Scheduled_Ship_Date__c = DATE.TODAY(),
                                Shipment_Type__c = 'testType',
                                ShipTo__c = 'test',
                                Circuit__c = testCircuit.ID,
                                Theatre__c = testAccount.ID,
                                ShipToName__c = 'testName',
                                ShippingStreet1__c = 'testAddress',
                                Shipping_City__c = 'testCity',
                                Shipping_Country__c = 'testCountry',
                                Contact__c = testContact.ID,
                                Carrier__c = 'testCarrier',
                                Shipping_Service_Type__c = 'testService'
                                       
                                );

        INSERT testShipment;
        Shipment_Line_Item__c testLineItem = new Shipment_Line_Item__c(
                                Shipment__c = testShipment.ID,
                                SourceWarehouse__c = testWarehouse.ID,
                                Product__c = testProduct.ID,
                                Quantity__c = 1,
                                Line_Status__c  = 'Scheduled'
                                );
        INSERT testLineItem;

        

        PageReference pageref = Page.NewCAKeyRequest;
        Test.setCurrentPage(pageref);
        
        ApexPages.currentpage().getparameters().put('CircuitID',testCircuit.ID);
        ApexPages.currentpage().getparameters().put('id',testKeyRequest.ID);

        System.assertEquals('/apex/newcakeyrequest?CircuitID='+testCircuit.ID+'&id='+testKeyRequest.ID,pageRef.getUrl());
        
        ApexPages.StandardController testController = new ApexPages.StandardController(testKeyRequest);
        NewCAKeyRequestController keyRequestController = new NewCAKeyRequestController(testController);
        keyRequestController.dataNewAssets = testAsset.ID;
        keyRequestController.licenseBeginDate = String.valueof(Date.Today());
        keyRequestController.licenseEndDate = String.valueof(Date.Today()+50);
        keyRequestController.dataDeleteAssets = testAsset.ID;
        keyRequestController.populateAssetIds = testAsset.ID;
        NewCAKeyRequestController.currentShippingAssetsWrapper shipAsset = new NewCAKeyRequestController.currentShippingAssetsWrapper(testLineItem);
        NewCAKeyRequestController.installedAssetsWrapper installAsset = new NewCAKeyRequestController.installedAssetsWrapper(testAsset);
        installAsset.screenID  = testScreen.ID;
        installAsset.screenName = testScreen.Name;
        installAsset.keyStatus = 'New';
        installAsset.keyExpirationDate = Date.Today()+50;
        keyRequestController.save();
        keyRequestController.cancel();
        keyRequestController.keyRequestID = null;
        keyRequestController.save();
        /*keyRequestController.cancel();*/
        
    }
}