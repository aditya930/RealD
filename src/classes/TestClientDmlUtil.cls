public with sharing class TestClientDmlUtil {
    
    public static Account createAccount()
    {
        Account a = new Account(Name = 'test-0', BillingCountry = 'USA');
        
        return a;
    }
    
    public static Contact createContact(Account account)
    {
        Contact c = new Contact(LastName = 'Test'
                              , AccountId = account.Id
                              , Email = 'test123@reald.com.test');
        
        return c;
    }
    
    public static Asset createAsset(Screens__c screen, Warehouse__c warehouse, Account account, Product2 product)
    {
        Asset a = new Asset(Screen__c = screen.Id
                         , Product2Id = product.Id
                         , Name = 'testx1'
                         , Warehouse__c = warehouse.Id
                         , accountId = account.Id
                         , Unique_ID__c = generate16BitId()
                         , SerialNumber = generateSerialNumber());
        
        return a;
    }
    
    public static List<License_Key__c> createLicenseKey1(Asset asset, Contact pContact, Contact sContact, Shipment__c shipment)
    {
        License_Key__c l1 = new License_Key__c(License_Begin_Date__c = System.today()
                                             ,License_End_Date__c = System.today() + 30
                                             ,Asset__c = asset.Id
                                             ,Primary_Contact__c = pContact.Id
                                             ,Secondary_Contact__c = sContact.Id
                                             ,Shipment__c = shipment.Id);
       
        License_Key__c l2 = new License_Key__c(License_Begin_Date__c = System.today()
                                             ,License_End_Date__c = System.today() + 30
                                             ,Asset__c = asset.Id
                                             ,Primary_Contact__c = pContact.Id
                                             ,Secondary_Contact__c = sContact.Id);
                                             
        List<License_Key__c> lstLk = new List<License_Key__c>();
        lstLk.add(l1);
        lstLk.add(l2);
        
        return lstLk;
    }
    
    public static License_Key__c createLicenseKey(Asset asset, Contact pContact, Contact sContact)
    {
        License_Key__c l = new License_Key__c(License_Begin_Date__c = System.today()
                                             ,License_End_Date__c = System.today() + 30
                                             ,Asset__c = asset.Id
                                             ,Primary_Contact__c = pContact.Id
                                             ,Secondary_Contact__c = sContact.Id);
        
        return l;
    }
    
    
    public static Screens__c createScreen(Account account)
    {
        
        Screens__c screen = new Screens__c(Theater__c = account.Id
                                          ,Name = 'testScreen 1');
        
       
        return screen;
    }
       
    public static Warehouse__c createWarehousewh(Account account)
    {
       Warehouse__c wh = new Warehouse__c(name = 'testwarehsouse1'
                                          ,Account__c = account.Id
                                          ,Street_Address__c = 'ddddd\nssss');
       
       return wh;
    }
    
    public static Product2 createProduct2()
    {
       Product2 p = new Product2(name = 'testprodx'
                                ,Generic_Name__c = 'testGenProdx');
       
       return p;
    }
    
    public static Shipment__c createShipment(Asset a, Contact c)
    {
        Shipment__c shipment = new Shipment__c(Circuit__c = a.Account.Circuit__c 
                                                   , Theatre__c = a.AccountId
                                                   , Contact__c = c.Id
                                                   , Scheduled_Ship_Date__c = System.today()
                                                   , Shipping_Street__c = a.Account.ShippingStreet
                                                   , Shipping_City__c = a.Account.ShippingCity
                                                   , Shipping_State_Province__c = a.Account.ShippingState
                                                   , Shipping_Postal_Code__c = a.Account.ShippingPostalCode
                                                   , Shipping_Country__c = a.Account.ShippingCountry
                                                   , ShipTo__c = 'Theater'
                                                   , Status__c = 'Pending'
                                                   , Shipment_Type__c = 'Parts'
                                                   , Send_License_Keys__c = true);
        return shipment;
    }
    
    public static string generate16BitId()
    {
        String returnId = '';
        while(returnId.length() < 17)
        {
            Double randNumber = Math.abs(Math.random());
            returnId += String.valueOf(randNumber).replace('.', '');
        }
        
        return returnId.substring(0,16);
    }
       
    public static string generateSerialNumber()
    {
        return 'XL'+generate16BitId().substring(0,5);
    }   

}