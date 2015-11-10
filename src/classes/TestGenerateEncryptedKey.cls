@isTest
private class TestGenerateEncryptedKey {

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
		
		asset = [select Id
		              , Encryption_Key_01__c
		              , Encryption_Key_02__c
		              , Encryption_Key_03__c
		              , Encryption_Key_04__c
		          from Asset
		         where Id = :asset.Id];
		//verify the results
		System.assertNotEquals(null, asset.Encryption_Key_01__c);
		System.assertNotEquals(null, asset.Encryption_Key_02__c);
		System.assertNotEquals(null, asset.Encryption_Key_03__c);
		System.assertNotEquals(null, asset.Encryption_Key_04__c);
		
	}

}