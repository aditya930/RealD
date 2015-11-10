public with sharing class ShipmentEditController {
    public Shipment__c shipment{get;set;}
    Account theater{get;set;}
    Warehouse__c destWarehouse{get;set;}
    public ShipmentEditController(ApexPages.StandardController ctl)
    {
        /*
        
        Purpose:
            1.  Auto-Fill Shipping Address from Theatre or Warehouse while on edit screen (“ShipmentEdit” visualforce page)
            2.  Fill in Shipping Address fields without saving or refreshing the page
         */
        string shipmentId =ctl.getId();
        shipment = new Shipment__c();
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Shipment__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String theQuery = 'SELECT ';
                
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String theName = s.getDescribe().getName();
            theQuery += theName + ',';
        }
                
        theQuery = theQuery.subString(0, theQuery.length() - 1); //trim last comma
        theQuery += ' FROM Shipment__c Where Id = :shipmentId';
        
        for(Shipment__c s : Database.query(theQuery))
          shipment = s;
          
        
          
        destWarehouse = new Warehouse__c();
        theater = new Account();
        for(Account a : [Select Id, Circuit__c, Billing_Entity__c
                            from Account
                           where Id = :ApexPages.currentPage().getParameters().get('CF00N60000001s5om_lkid') ])
        {
            theater = a;
            shipment.Theatre__c = a.Id;
            shipment.Circuit__c = a.Circuit__c;
            shipment.Billing_Entity__c = a.Billing_Entity__c;
            
        }
    }
    
    public pageReference updateAddress()
    {
        String loc = '1';
        try{
            
            
          loc = '10';
            if(shipment.ShipTo__c == 'Theatre')
            {
                    for(Account t : [Select Id
                              , Name
                              , ShippingStreet
                              , ShippingCity
                              , ShippingState
                              , ShippingPostalCode
                              , ShippingCountry
                           from account
                          where Id = :shipment.Theatre__c])
                        theater = t;
                        
                    loc = '20';
                    list<string> addressLines = new list<string>();
                    loc = '21';
                    if(theater.ShippingStreet != null)
                    {
                        addressLines = theater.ShippingStreet.split('\n');
                        shipment.ShippingStreet1__c ='';
                        shipment.ShippingStreet2__c ='';
                        shipment.ShippingStreet3__c ='';
                        shipment.ShippingStreet4__c ='';
                        
                        loc = '22';
                        shipment.ShipToName__c = theater.Name;
                        loc = '23';
                        if(addressLines.size() > 0)
                           if(addressLines[0].length() > 30)
                              shipment.ShippingStreet1__c = addressLines[0].subString(1,30);
                           else shipment.ShippingStreet1__c = addressLines[0]; 
                        if(addressLines.size() > 1)
                           if(addressLines[1].length() > 30)
                              shipment.ShippingStreet2__c = addressLines[1].subString(1,30);
                           else shipment.ShippingStreet2__c = addressLines[1]; 
                        if(addressLines.size() > 2)
                           if(addressLines[2].length() > 30)
                              shipment.ShippingStreet3__c = addressLines[2].subString(1,30);
                           else shipment.ShippingStreet3__c = addressLines[2]; 
                        if(addressLines.size() > 3)
                           if(addressLines[3].length() > 30)
                              shipment.ShippingStreet4__c = addressLines[3].subString(1,30);
                           else shipment.ShippingStreet4__c = addressLines[3]; 
                    }
                    else
                    {
                       shipment.ShippingStreet1__c =null;
                       shipment.ShippingStreet2__c =null;
                       shipment.ShippingStreet3__c =null;
                       shipment.ShippingStreet4__c =null;
                    }
                    loc = '24';
                    if(shipment.Shipping_City__c != null && shipment.Shipping_City__c.length() > 30)
                        shipment.Shipping_City__c = theater.ShippingCity.subString(0,30);
                    else 
                        shipment.Shipping_City__c = theater.ShippingCity;
                    loc = '25';
                    //if(shipment.Shipping_State_Province__c != null && shipment.Shipping_State_Province__c.length() > 2)
                    //   shipment.Shipping_State_Province__c = theater.ShippingState.subString(0,2);
                    //else 
                    shipment.Shipping_State_Province__c = theater.ShippingState;
                    
                    loc = '26';
                    shipment.Shipping_Postal_Code__c = theater.ShippingPostalCode;
                    loc = '27';
                    shipment.Shipping_Country__c = theater.ShippingCountry;
            }
             else if(shipment.ShipTo__c == 'Warehouse' )
             {
                    loc = '40';
                    for(Warehouse__c w : [select Id
                                    , Name
                                    , Ship_to_Name__c
                                    , Street_Address__c
                                    , City__c
                                    , State__c 
                                    , Postal_Code__c
                                    , Country__c
                                 from Warehouse__c
                                where Id = :shipment.Destination_Warehouse__c])
                        destWarehouse = w;
                    loc = '50';
                    if(destWarehouse.Id == null)
                    {
                        shipment.Destination_Warehouse__c.addError('Please Select a Destination Warehouse.');
                        return null;
                    }
                    loc = '60';
                    list<string> wAddressLines  = new list<string>();
                    if(destWarehouse.Street_Address__c != null)
                    {
                        
                        wAddressLines = destWarehouse.Street_Address__c.split('\n');
                        loc = '70';
                        shipment.ShipToName__c = destWarehouse.Ship_to_Name__c;
                        
                        shipment.ShippingStreet1__c = '';
                        shipment.ShippingStreet2__c = '';
                        shipment.ShippingStreet3__c = '';
                        shipment.ShippingStreet4__c = '';
                        
                        if(wAddressLines.size() > 0)
                          if(wAddressLines[0].length() > 30)
                            shipment.ShippingStreet1__c = wAddressLines[0].subString(0,30);
                          else shipment.ShippingStreet1__c = wAddressLines[0];
                        if(wAddressLines.size() > 1)
                          if(wAddressLines[1].length() > 30)
                            shipment.ShippingStreet2__c = wAddressLines[1].subString(0,30);
                          else shipment.ShippingStreet2__c = wAddressLines[1];
                        if(wAddressLines.size() > 2)
                          if(wAddressLines[2].length() > 30)
                            shipment.ShippingStreet3__c = wAddressLines[2].subString(0,30);
                          else shipment.ShippingStreet3__c = wAddressLines[2];
                        if(wAddressLines.size() > 3)
                          if(wAddressLines[3].length() > 30)
                            shipment.ShippingStreet4__c = wAddressLines[3].subString(30);
                          else shipment.ShippingStreet4__c = wAddressLines[3];
                    }
                    else
                    {
                       shipment.ShippingStreet1__c =null;
                       shipment.ShippingStreet2__c =null;
                       shipment.ShippingStreet3__c =null;
                       shipment.ShippingStreet4__c =null;
                    }
                    loc = '80';
                    if(shipment.Shipping_City__c != null && shipment.Shipping_City__c.length() > 30)
                        shipment.Shipping_City__c = destWarehouse.City__c.subString(0,30);
                    else
                        shipment.Shipping_City__c = destWarehouse.City__c;
                    loc = '90';
                    //if(shipment.Shipping_State_Province__c != null && shipment.Shipping_State_Province__c.length() > 2)
                    //    shipment.Shipping_State_Province__c = destWarehouse.State__c.subString(0,2);
                    //else 
                       
                    shipment.Shipping_State_Province__c = destWarehouse.State__c;
                    shipment.Shipping_Postal_Code__c = destWarehouse.Postal_Code__c;
                    shipment.Shipping_Country__c = destWarehouse.Country__c;
             }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ERROR at loc '+loc + ', '+e.getMessage()+destWarehouse));
            //ApexPages.addMessages(e);
            return null;
        }
         return null;
    }
    
    public PageReference save()
    {
        
        if(shipment.Shipment_Type__c == null){
          shipment.Shipment_Type__c.addError('Shipment Type is Required.');
          return null;
        }
        if(shipment.Circuit__c == null){
          shipment.Circuit__c.addError('Circuit is Required.');
          return null;
        }
        if(shipment.Theatre__c == null){
          shipment.Theatre__c.addError('Theater is Required.');
          return null;
        }
        if(shipment.Contact__c == null){
          shipment.Contact__c.addError('Contact is Required.');
          return null;
        }
        
        
        if(shipment.ShipToName__c == null){
          shipment.ShipToName__c.addError('Ship To Name is Required.');
          return null;
        }
        if(shipment.ShippingStreet1__c == null){
          shipment.ShippingStreet1__c.addError('Shipping Street is Required.');
          return null;
        }
        if(shipment.Shipping_City__c == null){
          shipment.Shipping_City__c.addError('Shipping City is Required.');
          return null;
        }
        if(shipment.Shipping_Country__c == null){
          shipment.Shipping_Country__c.addError('Shipping Country is Required.');
          return null;
        }
        if(shipment.Carrier__c == null){
          shipment.Carrier__c.addError('Carrier is Required.');
          return null;
        }
        if(shipment.Shipping_Service_Type__c == null){
          shipment.Shipping_Service_Type__c.addError('Shipping Service Type is Required.');
          return null;
        }
        if(shipment.Scheduled_Ship_Date__c == null){
          shipment.Scheduled_Ship_Date__c.addError('Scheduled Ship Date is Required.');
          return null;
        }
        upsert shipment;
        return new PageReference('/'+shipment.Id);
    }
    
    

}