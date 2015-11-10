@isTest
private class TestCreateTiffShipmentObjects {

    static testMethod void runTest(){
	//
	    //create test data                       
	    Product2 p = TestClientUtility.createProduct2() ;
	    p.name = 'XL';
        p.Generic_Name__c = 'XL';
                                   
        insert p;
	   
	    Circuits__c cir = TestClientUtility.createCircuit();
	    //new Circuits__c(Name = 'x',Circuit_Type__c = 'Cinema', Country__c = 'USA');
        insert cir;
        
        Account acc = TestClientUtility.createAccount();
        acc.Circuit__c = cir.Id;
	    insert acc;
        
        Screens__c screen = TestClientUtility.createScreen(acc.Id);
        insert screen;
        
	    Product_Shipment_RecordType_Map__c prod = new Product_Shipment_RecordType_Map__c();
	    
	    prod.Name  ='XL';
	    prod.RecordType_Name__c = 'XL';   
	    try{                      
	   	 insert prod;
	    }
	    catch(Exception e){}
		
		TIF__c tif = TestClientUtility.createTif(p.Name);
		
	   insert tif;
	   
	   ApexPages.StandardController ac = new ApexPages.StandardController(tif);
	   CreateTIFShipmentObjects ctl = new CreateTIFShipmentObjects(ac);
	   ctl.run();
	   
	   tif.Product__c = 'Unknown';
	   update tif;
	   
	   CreateTIFShipmentObjects ctl2 = new CreateTIFShipmentObjects(ac);
	   ctl2.run();
	   
	   tif.Form_Status__c = 'x';
	   tif.Product__c = 'XL';
	   update tif;
	   
	   CreateTIFShipmentObjects ctl3 = new CreateTIFShipmentObjects(ac);
	   ctl3.run();
	   
	   tif.Theatre__c = null;
	   tif.Product__c = 'XL';
	   tif.Form_Status__c = 'Reviewed';
	   tif.Circuit__c = cir.Id;
	   update tif;
	   
	   CreateTIFShipmentObjects ctl4 = new CreateTIFShipmentObjects(ac);
	   ctl4.run();
	   
	   tif.Theatre__c = acc.Id;
	   update tif;
	   
	   CreateTIFShipmentObjects ctl5 = new CreateTIFShipmentObjects(ac);
	   ctl5.run();
	   
	   
	   tif.Screen__c = screen.Id;
	   update tif;
	   
	   CreateTIFShipmentObjects ctl6 = new CreateTIFShipmentObjects(ac);
	   ctl6.run();
	   
    }
}