@isTest
private class TestShipmentEditController {

    static testMethod void runTest() {
        // Create test Data
        Account acc = TestClientUtility.createAccount();
        acc.ShippingStreet = '123';
		acc.ShippingCity = 'abc';
		acc.ShippingState = 'CA';
		acc.ShippingPostalCode = '90210';
		acc.ShippingCountry = 'USA';
		
		insert acc;
		
		Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
	    wh.name = 'RealD Finished Goods';
	    wh.Street_Address__c = '123';
		wh.City__c = 'xyz';
		wh.State__c = 'NY';
		wh.Postal_Code__c = '11101';
		wh.Country__c = 'USA';
		
	    insert wh;
	    
	    Case c = TestClientUtility.createCase();
        insert c;
       
        Product2 prod = TestClientUtility.createProduct2();
        insert prod;
	    
	    Circuits__c cir = TestClientUtility.createCircuit();
        insert cir;
        
       
        Screens__c screen = TestClientUtility.createScreen(acc.Id);
        insert screen;
       
        Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, wh.Id, prod.Id);
	    insert a;
       
        Contact con = TestClientUtility.createContact(acc.Id);
                                
        con.Circuit__c = cir.id;
       
        insert con;
       
        Shipment__c ship = TestClientUtility.createShipment(acc.Id, cir.Id, con.Id, screen.Id, wh.Id, wh.Id, prod.Id, a.Id, c.Id);
	    insert ship;
	    
	    ApexPages.StandardController sc = new ApexPages.StandardController(ship);
	    
	    PageReference pageRef = Page.ShipmentEdit;
		Test.setCurrentPageReference(pageRef);    
        
        ShipmentEditController ctl = new ShipmentEditController(sc);
        
        ctl.shipment.ShipTo__c = 'Theatre';
        ctl.updateAddress();
        System.assertEquals(ctl.shipment.Shipping_State_Province__c, 'CA');
        
        ctl.shipment.ShipTo__c = 'Warehouse';
        ctl.updateAddress();
        System.assertEquals(ctl.shipment.Shipping_State_Province__c, 'NY');
        
        acc.ShippingStreet = '12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
		acc.ShippingCity = '12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
		acc.ShippingState = 'CA';
		acc.ShippingPostalCode = '90210';
		acc.ShippingCountry = 'USA';
		update acc;
		
		ctl.shipment.ShipTo__c = 'Theatre';
        ctl.updateAddress();
        
        wh.Street_Address__c = '12312bbbbbbbbbbb\n12312bbbbbbbbbbb\n12312bbbbbbbbbbb\n12312bbbbbbbbbbb';
		wh.City__c = '12bbbbbbbbbbbbbbbbbbb';
		wh.State__c = 'NY';
		wh.Postal_Code__c = '11101';
		wh.Country__c = 'USA';
		update wh;
        
        ctl.shipment.ShipTo__c = 'Warehouse';
        ctl.updateAddress();
        
        acc.ShippingStreet = '12312bbbbbbbbbbb\n12312bbbbbbbbbbb\n12312bbbbbbbbbbb\n12312bbbbbbbbbbb';
		acc.ShippingCity = '12bbbbbbbbbbbb';
		acc.ShippingState = 'CAlifronai';
		acc.ShippingPostalCode = '90210';
		acc.ShippingCountry = 'USA';
		update acc;
		
		ctl.shipment.ShipTo__c = 'Theatre';
        ctl.updateAddress();
        
        wh.Street_Address__c = '12312bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
		wh.City__c = '12bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
		wh.State__c = 'NYC';
		wh.Postal_Code__c = '11101';
		wh.Country__c = 'USA';
		update wh;
		
        ctl.shipment.ShipTo__c = 'Warehouse';
        ctl.updateAddress();
        
        acc.ShippingStreet = null;
		update acc;
		
		ctl.shipment.ShipTo__c = 'Theatre';
        ctl.updateAddress();
        
        wh.Street_Address__c = null;
		update wh;
		
        ctl.shipment.ShipTo__c = 'Warehouse';
        ctl.updateAddress();
        
         ctl.shipment.ShipTo__c = 'Warehouse';
        ctl.shipment.Destination_Warehouse__c = null;
        ctl.updateAddress();
        
        ctl.shipment.Destination_Warehouse__c = wh.Id;
        
        ctl.shipment.Shipment_Type__c = null;
        ctl.save();
		  
		ctl.shipment.Shipment_Type__c = 'Replace';
		
		ctl.shipment.Circuit__c = null;
		ctl.save();
		
		ctl.shipment.Circuit__c = cir.Id; 
		ctl.shipment.Theatre__c = null;
        ctl.save();
		
		ctl.shipment.Theatre__c = acc.Id;
		
        ctl.shipment.Contact__c = null;
        ctl.save();
		
		ctl.shipment.Contact__c = con.Id;
		
	    ctl.shipment.ShippingStreet1__c = null;
        ctl.save();

		ctl.shipment.ShippingStreet1__c = '222';
		
		ctl.shipment.Shipping_City__c = null;
		ctl.save();
		
		ctl.shipment.Shipping_City__c = 'ddd';
		
		ctl.shipment.Shipping_State_Province__c = null;
		ctl.save();
		  
		ctl.shipment.Shipping_State_Province__c = 'CA';
		
		ctl.shipment.Shipping_Postal_Code__c = null;
		ctl.save();
		
		ctl.shipment.Shipping_Postal_Code__c = '1234';
		
		ctl.shipment.Shipping_Country__c = null;
		ctl.save();
		  
        ctl.shipment.Shipping_Country__c = 'USA';
        ctl.save();
        
	    
	    
	    
	    
    }
}