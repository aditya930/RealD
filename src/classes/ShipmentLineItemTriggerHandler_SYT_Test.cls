@isTest(SeeAllData=true)
private class ShipmentLineItemTriggerHandler_SYT_Test 
{
    static testMethod void TestWarehouseUpdation() 
    {
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
        wh.Include_in_Inventory__c = true;
        wh.WarehouseSortOrder__c = 99;
        wh.Account__c = acc.Id;

        insert wh;

        Case c = TestClientUtility.createCase();
        insert c;

        Product2 prod = TestClientUtility.createProduct2();
        prod.Serialized__c = true;
        insert prod;

        Circuits__c cir = TestClientUtility.createCircuit();
        insert cir;

        Screens__c screen = TestClientUtility.createScreen(acc.Id);
        insert screen;

        Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, wh.Id, prod.Id);
        a.SerialNumber = 'test123123123';
        insert a;

        Contact con = TestClientUtility.createContact(acc.Id);
        con.Circuit__c = cir.id;
        insert con;

        Shipment__c ship = TestClientUtility.createShipment(acc.Id, cir.Id, con.Id, screen.Id, wh.Id, wh.Id, prod.Id, a.Id, c.Id);
        ship.status__c = 'Pending';
        insert ship;

        Shipment_Line_Item__c sli = TestClientUtility.createShipmentLineItem(ship.Id, prod.Id, wh.Id, screen.Id);
        sli.SerialNumber__c = 'test123123123';
        insert sli;
        system.debug('1###'+sli.AssetTransferType__c);
        Inventory__c i = TestClientUtility.createInventory(wh.Id, prod.Id);
        RecordType rt = [Select Id from RecordType where Name = 'Current Inventory'];
        i.Approved__c = TRUE;
        i.RecordTypeId = rt.Id;
        insert i;

        //update sli;//Test shipment line item trigger -- commented by Suyati

        //Commented by Suyati
        /*sli.Line_Status__c = 'Shiped';
        update sli;*/

        Asset_Transfer__c at = TestClientUtility.createAssetTransfer(a.Id, screen.Id, screen.Id, System.today(), System.today());
        insert at;
        system.debug('2###'+sli.AssetTransferType__c);
        //update sli; -- Commented by Suyati

        sli.Line_Status__c = 'Shipped';//Test shipment line item trigger
        sli.CompleteShipment__c = true;
        sli.SerialNumber__c = 'test123123123';
        update sli;
        system.debug('3###'+sli.AssetTransferType__c);

        ship.status__c = 'Scheduled';
        database.update(ship, false);



        /**
        * Speciffic test case for Transfers
        *
        *  Shipment_Type__c = “RealD Warehouse Transfer”
        *   Update Inventory__c Records where:
        *   Inventory__r.RecordType.Name = “Current Inventory”
        *   Inventory__r.Product__c = Shipment_Line_Item__r.Product__c
        *   For Inventory__r.Warehouse__c  = Shipment_Line_Item__r.SourceWarehouse__c
        *   Decrease Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
        *   For Inventory__r.Warehouse__c  = Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c 
        *   Increase Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
        *   Link and update Asset records normally but set Asset.Warehouse__c to Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c
        *Do not create Asset Transfers
        */

        //create a transit Account
        Account accTrans = TestClientUtility.createAccount();
        accTrans.ShippingStreet = '123';
        accTrans.ShippingCity = 'abc';
        accTrans.ShippingState = 'CA';
        accTrans.ShippingPostalCode = '90210';
        accTrans.ShippingCountry = 'USA';
        insert accTrans;

        //create a destination and transfer warehouse
        Warehouse__c trasitWarehouse = TestClientUtility.createWarehouse(acc.Id);
        trasitWarehouse.name = 'RealD Finished Goods';
        trasitWarehouse.Street_Address__c = '123';
        trasitWarehouse.City__c = 'xyz';
        trasitWarehouse.State__c = 'NY';
        trasitWarehouse.Postal_Code__c = '11101';
        trasitWarehouse.Country__c = 'USA';
        trasitWarehouse.Include_in_Inventory__c = true;
        trasitWarehouse.WarehouseSortOrder__c = 98;
        trasitWarehouse.Warehouse_Type__c = 'In Transit';
        trasitWarehouse.Account__c = accTrans.Id;
        insert trasitWarehouse;

        //create a destination account
        Account accDest = TestClientUtility.createAccount();
        accDest.ShippingStreet = '123';
        accDest.ShippingCity = 'abc';
        accDest.ShippingState = 'CA';
        accDest.ShippingPostalCode = '90210';
        accDest.ShippingCountry = 'USA';
        insert accDest;

        //create a destination and transfer warehouse
        Warehouse__c destWarehouse = TestClientUtility.createWarehouse(acc.Id);
        destWarehouse.name = 'RealD Finished Goods';
        destWarehouse.Street_Address__c = '123';
        destWarehouse.City__c = 'xyz';
        destWarehouse.State__c = 'NY';
        destWarehouse.Postal_Code__c = '11101';
        destWarehouse.Country__c = 'USA';
        destWarehouse.Include_in_Inventory__c = true;
        destWarehouse.WarehouseSortOrder__c = 97;
        destWarehouse.InTransitWarehouse__c = trasitWarehouse.Id;
        destWarehouse.Account__c = accDest.Id;
        insert destWarehouse;

        Product2 prod2 = TestClientUtility.createProduct2();
        prod.Serialized__c = true;
        prod.Generic_Name__c = 'test';
        insert prod2;
        test.startTest();
        a.Screen__c = null; //remove the screen reference
        update a;

        Shipment__c Tship = TestClientUtility.createShipment(acc.Id, cir.Id, con.Id, screen.Id, wh.Id, destWarehouse.Id, prod2.Id, a.Id, c.Id);
        Tship.Shipment_Type__c = 'RealD Warehouse Transfer';
        Tship.status__c = 'Shipped';
        insert Tship;

        System.assertEquals('RealD Warehouse Transfer', [Select Shipment_Type__c from Shipment__c where Id = :Tship.Id].Shipment_Type__c);

        //create the inventory record for the Transfer warehouse
        Inventory__c transferInventory = TestClientUtility.createInventory(trasitWarehouse.Id, prod2.Id);
        transferInventory.RecordTypeId = rt.Id;
        transferInventory.Approved__c = TRUE;
        insert transferInventory;

        //create the inventory record for the destination warehouse
        Inventory__c sourceInventory = TestClientUtility.createInventory(wh.Id, prod2.Id);
        sourceInventory.RecordTypeId = rt.Id;
        sourceInventory.Approved__c = TRUE;
        insert sourceInventory;

        //create the inventory record for the destination warehouse
        Inventory__c destInventory = TestClientUtility.createInventory(destWarehouse.Id, prod2.Id);
        destInventory.RecordTypeId = rt.Id;
        destInventory.Approved__c = TRUE;
        insert destInventory;

        //Create the Inventory Line Item
        Shipment_Line_Item__c sli2 = TestClientUtility.createShipmentLineItem(Tship.Id, prod2.Id, wh.Id, screen.Id);

        //assert the initial results
        System.assertEquals(1, [Select Quantity__c from Inventory__c where Id = :sourceInventory.Id].Quantity__c);
        System.assertEquals(1, [Select Quantity__c from Inventory__c where Id = :transferInventory.Id].Quantity__c);
        sli2.Asset__c = a.Id;
        sli2.SerialNumber__c = 'test123123123';
        insert sli2;
        sli2.Line_Status__c = 'Shipped';
        sli2.CompleteShipment__c = true;
        update sli2;


        //assert the expected results
        System.assertEquals(0, [Select Quantity__c from Inventory__c where Id = :sourceInventory.Id].Quantity__c);
        System.assertEquals(2, [Select Quantity__c from Inventory__c where Id = :transferInventory.Id].Quantity__c);

        System.assertEquals(destWarehouse.InTransitWarehouse__c, [Select Warehouse__c from Asset where Id = :a.Id].Warehouse__c);
        System.assertEquals(accTrans.Id, [Select AccountId from Asset where Id = :a.Id].AccountId);

        /*
        list<Shipment_Line_Item__c> sli3 = new list<Shipment_Line_Item__c>();
        for(Shipment_Line_Item__c s : [select Id, Line_Status__c, Product__c from Shipment_Line_Item__c where Shipment__c = 'a0Kg00000000K9y'])
        {
        System.Debug('::::Product ->>> '+s.Product__c);
        s.Line_Status__c = 'Shipped';

        sli3.add(s);
        }
        Test.startTest();
        System.assertEquals(0, [Select Quantity__c from Inventory__c where Id = 'a0Vg00000005Vmj'].Quantity__c);
        update sli3;
        System.assertEquals(5, [Select Quantity__c from Inventory__c where Id = 'a0Vg00000005Vmj'].Quantity__c);
        Test.stopTest();
        */

        /*
        Update ShipmentLineItemTrigger
        When Line_Status__c = “Delivered” AND
        Shipment__r.Shipment_Type__c = “RealD Warehouse Transfer”
        •   Update Inventory__c Records where:
        ◦   Inventory__r.RecordType.Name = “Current Inventory”
        ◦   Inventory__r.Product__c = Shipment_Line_Item__r.Product__c
        ◦   For Inventory__r.Warehouse__c  = Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c
        ▪   Decrease Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
        ◦   For Inventory__r.Warehouse__c  = Shipment__r.Destination_Warehouse__c 
        ▪   Increase Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity 
        •   Link and update Asset records normally but set Asset.Warehouse__c to Shipment__r.Destination_Warehouse__c
        •   Create Asset Transfer Normally:
        ◦   RecordType.Name = Warehouse Transfer
        ◦   Source_Warehouse__c = Shipment_Line_Item__r.Source_Warehouse__c
        ◦   Destination_Warehouse__c = Shipment__r.Destination_Warehouse__c
        ◦   Transfer_Begin_Date__c = Shipment_Line_Item__r.ShipDate__c
        ◦   Transfer_End_Date__c = Shipment_Line_Item__r. DeliveryDate__c
        */


        System.assertEquals(1, [Select Quantity__c from Inventory__c where Id = :destInventory.Id].Quantity__c);

        System.Debug(':: :: :: TESTING DELIVERED :: :: ::');
        sli2.Line_Status__c = 'Delivered';
        update sli2; 
        Test.stopTest();

        //verify results
        System.assertEquals(2, [Select Quantity__c from Inventory__c where Id = :destInventory.Id].Quantity__c);
        System.assertEquals(destWarehouse.Id, [Select Warehouse__c from Asset where Id = :a.Id].Warehouse__c);
        System.assertEquals(accDest.Id, [Select AccountId from Asset where Id = :a.Id].AccountId);
        }
}