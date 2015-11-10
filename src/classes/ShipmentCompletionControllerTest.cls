@isTest
public class ShipmentCompletionControllerTest{
     static testMethod void testMethod1(){
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
                                BillingCountry = 'testCountry'
                                );
        INSERT testAccount;

        Contact testContact = new Contact(
                                LastName = 'testName',
                                Circuit__c = testCircuit.ID
                                );

        INSERT testContact;

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

        Warehouse__c testWarehouse = new Warehouse__c(
                                Name = 'test',
                                Account__c = testAccount.ID,
                                Warehouse_Type__c = 'RealD Distribution'
                                );

        INSERT testWarehouse;

        Product2 testProduct = new Product2(
                                Name = 'testProduct'
                                );

        INSERT testProduct;

        
        Shipment_Line_Item__c testLineItem = new Shipment_Line_Item__c(
                                Shipment__c = testShipment.ID,
                                SourceWarehouse__c = testWarehouse.ID,
                                Product__c = testProduct.ID,
                                Quantity__c = 1,
                                Line_Status__c  = 'Scheduled'
                                );
        INSERT testLineItem;

        //ShipmentSearch.currentpage().getParameters.put('id',testWarehouse.ID);
        PageReference pageref = Page.ShipmentCompletion;
        Test.setCurrentPage(pageref);
        
        ShipmentCompletionController shipController = new ShipmentCompletionController();
        ApexPages.currentpage().getparameters().put('id',testWarehouse.ID);
        
        shipController = new ShipmentCompletionController();
        String startDate = Datetime.now().format('yyyy-MM-dd');
        String endDate = Datetime.now().format('yyyy-MM-dd');
        ApexPages.currentpage().getparameters().put('dFrom',startDate);
        ApexPages.currentpage().getparameters().put('dTo',endDate);
        
        shipController = new ShipmentCompletionController();
        ApexPages.currentpage().getparameters().put('id','');
        shipController = new ShipmentCompletionController();
        shipController.save();
        shipController.getWarehouseIds();
        ShipmentCompletionController.LineItemWrapper li = new ShipmentCompletionController.LineItemWrapper(testLineItem);
       

    }
}