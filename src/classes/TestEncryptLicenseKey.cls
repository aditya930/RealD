@isTest
private class TestEncryptLicenseKey {
    
    static testMethod void runTest() {
        
        Circuits__c cr = new Circuits__c();
        cr.Circuit_Email__c = 'testabc@reald.com.test';
        cr.Circuit_Type__c = 'x';
        cr.City__c = 'Denver';
        cr.Country__c = 'US';
        
        insert cr;
        
        Account a = TestClientDmlUtil.createAccount();
        a.ShippingPostalCode = '11111';
        a.ShippingStreet = '222222';
        a.ShippingCity = 'Denver';
        a.ShippingState = 'Co';
        a.ShippingCountry = 'US';
        a.Circuit__c = cr.Id;
        insert a;
        
        Product2 p = TestClientDmlUtil.createProduct2();
        
        Screens__c s = TestClientDmlUtil.createScreen(a);
        
        Warehouse__c w = TestClientDmlUtil.createWarehousewh(a);
        
        //create the asset to generate the Encruption Keys
        Asset asset = TestClientDmlUtil.createAsset(s, w, a, p);
        asset.Encryption_Key_01__C = 12345678;
        asset.Encryption_Key_02__C = 12345678;
        asset.Encryption_Key_03__C = 12345678;
        asset.Encryption_Key_04__C = 12345678;
        
        insert asset;
        
        //change the Unique Id triggering the key generation
        asset.Unique_ID__c = TestClientDmlUtil.generate16BitId();
        
        update asset;
        
        Contact c = TestClientDmlUtil.createContact(a);
        
        insert c;
        
        Shipment__c shipment = TestClientDmlUtil.createShipment(asset, c);
        
        insert shipment;
        
        /*License_Key__c lk = TestClientDmlUtil.createLicenseKey(asset, c,c);
        
        insert lk;*/
        
        List<License_Key__c> lk1 = TestClientDmlUtil.createLicenseKey1(asset, c,c,shipment);
        
        insert lk1;
        
        Attachment att = [select Id
                            from Attachment
                           where ParentId = :lk1[0].Id];
        //verify the results
        System.assertNotEquals(null, att.Id);
        
        /*Set <Id> setTestLicKey = new Set<Id>();
        setTestLicKey.add(lk.id);

        EncryptionWrapper.emailEncryptedKeyFile(EncryptionWrapper.isEncryptionEmailReady(setTestLicKey));*/
        EncryptionWrapper wrap = new EncryptionWrapper();
        Date d  = date.parse('12/27/2012');
        EncryptionWrapper.buildDatetimeString(d);   
        
        d  = date.parse('01/01/2012');
        EncryptionWrapper.buildDatetimeString(d);
       
    }
  

}