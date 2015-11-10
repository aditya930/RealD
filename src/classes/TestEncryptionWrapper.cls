public class TestEncryptionWrapper {
    
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
        
        insert p;
         
        Screens__c s = TestClientDmlUtil.createScreen(a);
        insert s;
        
        Warehouse__c w = TestClientDmlUtil.createWarehousewh(a);
        insert w;
        
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
        
        //used to set the email recipient
        Contact c = TestClientDmlUtil.createContact(a);
        insert c;
        
        //Executes a trigger that calles the encryption wrapper methods to generate the key file and email it.
        License_Key__c lk = TestClientDmlUtil.createLicenseKey(asset, c,c);
        insert lk;
        
        boolean x = EncryptionWrapper.isEncryptionEmailReady(lk.Id);
        
        lk = [Select Id, Shipment__c from License_Key__c where Id = :lk.Id];
        //EncryptionWrapper.sendEmail(lk.Id);
        
        //validates that the Shipment was created by the email routine executed on the License key trigger
        /*Shipment__c sh = [Select Id from Shipment__c where Id = :lk.Shipment__c];
        
        //execute the shipment, License key email
        sh.Send_License_Keys__c = true;
        update sh;*/
        
        //verify the results
        Attachment att = [select Id
                            from Attachment
                           where ParentId = :lk.Id];
        
        //Verify an attachent was created
        System.assertNotEquals(null, att.Id);
        
        DefaultShipmentProduct__c dsp = new DefaultShipmentProduct__c();
        dsp.DefaultCircuitID__c = cr.Id;
        dsp.DefaultScreenID__c = s.Id;
        dsp.DefaultShippingStreet__c = '11111';
        dsp.DefaultContactID__c = c.Id;
        dsp.ProductId__c = p.Id;
        dsp.ShippingServiceType__c = 'TEST';
        dsp.SourceWarehouseID__c = w.Id;
        dsp.ShipmentType__c = 'TEST';
        dsp.OrgWideEmailID__c = 'x';
        dsp.RecordTypeID__c = 'x';
        insert dsp;
        //test the date string generator with one and two digit date fields
        EncryptionWrapper wrap = new EncryptionWrapper();
        
        Date d  = date.parse('12/27/2012');
        EncryptionWrapper.buildDatetimeString(d);   
        
        d  = date.parse('01/01/2012');
        EncryptionWrapper.buildDatetimeString(d);
        //cover the integer range class
        //IntegerRange r = new IntegerRange();
        IntegerRange i = new IntegerRange(1);
        try{
            IntegerRange r = new IntegerRange(null);
        }catch(Exception e){}
        IntegerRange y = new IntegerRange(1,2);
        IntegerRange y2 = new IntegerRange(2,1);
        y.max();
        y.min();
        y.toAString();
        y.contains(1);
        y.contains(y2);
        y.overlaps(y2);
        
       
    }

}