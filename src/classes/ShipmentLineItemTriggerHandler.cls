public with sharing class ShipmentLineItemTriggerHandler {
    
    public void onBeforeUpdate(map<Id,Shipment_Line_Item__c> oldMap, map<Id,Shipment_Line_Item__c> newMap)
    {
        //process shipment completion
        shimpmentCompletionHandler(newMap.values());
    }
    
    public void onAfterUpdate(map<Id,Shipment_Line_Item__c> oldMap, map<Id,Shipment_Line_Item__c> newMap)
    {
        //process shipment completion
        updateLineItemInventory(oldMap, newMap);
    }
    public void onAfterInsert(map<Id,Shipment_Line_Item__c> newMap)
    {
        //process shipment completion
        updateLineItemInventory(null, newMap);
    }
    /*
        When  Line_Status__c = “Shipped”
        •   Update Inventory__c Records where:
            ◦   Inventory__r.RecordType = 012g00000008UbD (Name = “Current Inventory”)
            ◦   Inventory__r.Product__c = Shipment_Line_Item__r.Product__c
        ◦   For Inventory__r.Warehouse__c  = Shipment_Line_Item__r.SourceWarehouse__c
            ▪   Decrease Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
        ◦   For Inventory__r.Warehouse__c  = Shipment__r.Destination_Warehouse__c 
            ▪   Increase Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
        
        *If Matching Inventory Record cannot be found for Product/Warehouse combination, do not update record, do not error. 
        (It is possible that some products may be listed on a shipment, but not tracked in Inventory)
        Thus, if there is a source warehouse and a destination warehouse on a shipment, inventory should be decremented from the 
        source and incremented at the destination.  If there is only a source, it should only decrement, only a destination, it should only increment.
        
        1. Update ShipmentLineItemTrigger
            When Line_Status__c = “Shipped” AND
            Shipment__r.Shipment_Type__c = “RealD Warehouse Transfer”
                •   Update Inventory__c Records where:
                    ◦   Inventory__r.RecordType.Name = “Current Inventory”
                    ◦   Inventory__r.Product__c = Shipment_Line_Item__r.Product__c
                    ◦   For Inventory__r.Warehouse__c  = Shipment_Line_Item__r.SourceWarehouse__c
                        ▪   Decrease Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
                    ◦   For Inventory__r.Warehouse__c  = Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c 
                        ▪   Increase Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
                •   Link and update Asset records normally but set Asset.Warehouse__c to Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c
            *Do not create Asset Transfers
 
        2.Update ShipmentLineItemTrigger
            When Line_Status__c = “Delivered” AND
            Shipment__r.Shipment_Type__c = “RealD Warehouse Transfer”
                •   Update Inventory__c Records where:
                    ◦   Inventory__r.RecordType.Name = “Current Inventory”
                    ◦   Inventory__r.Product__c = Shipment_Line_Item__r.Product__c
                    ◦   For Inventory__r.Warehouse__c  = Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c
                        ▪   Decrease Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
                    ◦   For Inventory__r.Warehouse__c  = Shipment__r.Destination_Warehouse__c 
                        ▪   Increase Inventory__r.Quantity__c by Shipment_Line_Item__r.Quantity
                •   Link and update Asset records normally but set Asset.Warehouse__c to Shipment__r.Destination_Warehouse__c
                •   Create Asset Transfer Normally:
                    ◦   RecordType.Name = Warehouse Transfer
                    ◦   Source_Warehouse__c = Shipment_Line_Item__r.Source_Warehouse__c
                    ◦   Destination_Warehouse__c = Shipment__r.Destination_Warehouse__c
                    ◦   Transfer_Begin_Date__c = Shipment_Line_Item__r.ShipDate__c
                    ◦   Transfer_End_Date__c = Shipment_Line_Item__r. DeliveryDate__c
     */
    public void updateLineItemInventory(map<Id,Shipment_Line_Item__c> oldMap, map<Id,Shipment_Line_Item__c> newMap)
    {
        //source warehouse set
        set<Id> sourceWareshouses = new set<Id>();
        
        //destination warehouse set
        set<Id> destinationWareshouses = new set<Id>();
        
        //maps the Source Warehouse and product to the list of associated Shipments
        map<String, Integer> lineItemSourceWarehouseMap = new map<String, Integer>();
        
        //maps the Destination Warehouse and Product to the list of associated Shipments
        map<String, Integer> lineItemDestWarehouseMap = new map<String, Integer>();
        
        //maps the Destination Transfer Warehouse and Product to the list of associated Shipments
        map<String, Integer> lineItemDestTransferWarehouseMap = new map<String, Integer>();
        
        //maps the Destination Transfer Warehouse and Product to the list of associated Shipments for Delivered Inventory
        map<String, Integer> lineItemDestDeliveredTransferWarehouseMap = new map<String, Integer>();
        
        //maps the Destination Transfer Warehouse and Product to the list of associated Shipments for Delivered Inventory
        map<String, Integer> lineItemDestDeliveredWarehouseMap = new map<String, Integer>();
        
        //list of inventory records associated with destination warehouses
        list<Inventory__c> destinationInventory = new list<Inventory__c>();
        
        //list of inventory records associated with source warehouses
        list<Inventory__c> sourceInventory = new list<Inventory__c>();
        
        System.debug('::::::Line_Status__c:::::>>'+newMap.values()[0].Line_Status__c);
        
        //pull togethr a map of product/warehouse combinations along with inventory counts
        for(Shipment_Line_Item__c li : [select Product__c, SourceWarehouse__c, Shipment__r.Destination_Warehouse__c, Quantity__c, Line_Status__c
                                             , Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c, Shipment__r.Shipment_Type__c
                                          from Shipment_Line_Item__c 
                                         where Id in :newMap.keySet()
                                           and Line_Status__c in ('Shipped', 'Delivered')])
        {
            if( (oldMap != null && oldMap.get(li.Id).Line_Status__c == 'Shipped' && li.Line_Status__c == 'Shipped'))//already went through this. Don't increment or decrement
              continue;
            if( (oldMap != null && oldMap.get(li.Id).Line_Status__c == 'Delivered' && li.Line_Status__c == 'Delivered'))//already went through this. Don't increment or decrement
              continue;  
            if(li.SourceWarehouse__c != null && li.Line_Status__c != 'Delivered')
            {
                if(lineItemSourceWarehouseMap.containsKey(li.SourceWarehouse__c+'-'+li.Product__c))
                {
                    Integer i = lineItemSourceWarehouseMap.get(li.SourceWarehouse__c+'-'+li.Product__c);
                    i += Integer.ValueOf(li.Quantity__c);
                    lineItemSourceWarehouseMap.put(li.SourceWarehouse__c+'-'+li.Product__c, i);
                    
                }
                else
                {
                    lineItemSourceWarehouseMap.put(li.SourceWarehouse__c+'-'+li.Product__c, Integer.valueOf(li.Quantity__c));
                }
                
                sourceWareshouses.add(li.SourceWarehouse__c);
            }
            
            if(li.Shipment__r.Destination_Warehouse__c != null)
            {
                System.debug('::::::li.Shipment__r.Shipment_Type__c:::::>>'+li.Shipment__r.Shipment_Type__c);
                if(li.Shipment__r.Shipment_Type__c == 'RealD Warehouse Transfer')
                {
                    
                    if(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c != null)
                    {
                        if(li.Line_Status__c == 'Shipped')
                        {
                            if(lineItemDestTransferWarehouseMap.containsKey(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c))
                            {
                                Integer i = lineItemDestTransferWarehouseMap.get(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c);
                                if(i == null) i = 0;
                                i += Integer.ValueOf(li.Quantity__c==null ? 0 :li.Quantity__c);
                                lineItemDestTransferWarehouseMap.put(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c, Integer.ValueOf(i));
                                
                            }
                            else
                            {
                                lineItemDestTransferWarehouseMap.put(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c, Integer.ValueOf(li.Quantity__c == null ? 0 : li.Quantity__c));
                            }
                        }
                        else if(li.Line_Status__c == 'Delivered')
                        {
                            if(lineItemDestDeliveredTransferWarehouseMap.containsKey(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c))
                            {
                                Integer i = lineItemDestDeliveredTransferWarehouseMap.get(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c);
                                if(i == null) i = 0;
                                i += Integer.ValueOf(li.Quantity__c==null ? 0 :li.Quantity__c);
                                lineItemDestDeliveredTransferWarehouseMap.put(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c, Integer.ValueOf(i));
                                
                            }
                            else
                            {
                                lineItemDestDeliveredTransferWarehouseMap.put(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c, Integer.ValueOf(li.Quantity__c == null ? 0 : li.Quantity__c));
                            }
                            
                            if(lineItemDestDeliveredWarehouseMap.containsKey(li.Shipment__r.Destination_Warehouse__c+'-'+li.Product__c))
                            {
                                Integer i = lineItemDestDeliveredWarehouseMap.get(li.Shipment__r.Destination_Warehouse__c+'-'+li.Product__c);
                                if(i == null) i = 0;
                                i += Integer.ValueOf(li.Quantity__c==null ? 0 :li.Quantity__c);
                                lineItemDestDeliveredWarehouseMap.put(li.Shipment__r.Destination_Warehouse__c+'-'+li.Product__c, Integer.ValueOf(i));
                                
                            }
                            else
                            {
                                lineItemDestDeliveredWarehouseMap.put(li.Shipment__r.Destination_Warehouse__c+'-'+li.Product__c, Integer.ValueOf(li.Quantity__c == null ? 0 : li.Quantity__c));
                            }
                        }
                        destinationWareshouses.add(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c);
                        if(li.Line_Status__c == 'Delivered')
                        {
                            destinationWareshouses.add(li.Shipment__r.Destination_Warehouse__c);
                        }
                        System.Debug('::::: Transfer Count: '+lineItemDestTransferWarehouseMap.get(li.Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c+'-'+li.Product__c));
                    }
                }
                else 
                {
                    if(lineItemDestWarehouseMap.containsKey(li.Shipment__r.Destination_Warehouse__c+'-'+li.Product__c))
                    {
                        Integer i = lineItemDestWarehouseMap.get(li.Shipment__r.Destination_Warehouse__c+'-'+li.Product__c);
                        i += Integer.ValueOf(li.Quantity__c);
                        lineItemDestWarehouseMap.put(li.Shipment__r.Destination_Warehouse__c+'-'+li.Product__c, i);
                        
                    }
                    else
                    {
                        lineItemDestWarehouseMap.put(li.Shipment__r.Destination_Warehouse__c+'-'+li.Product__c, Integer.valueOf(li.Quantity__c));
                    }
                    destinationWareshouses.add(li.Shipment__r.Destination_Warehouse__c);
                }
                
                
            }
        }
        
        map<String, Inventory__c> destinationInventoryMap = new map<String, Inventory__c>();
        //iterte through the  Inventory Items associated with the shipment, destination wareshouses
        for(Inventory__c i : [Select Id, RecordType.Name, Quantity__c, Product__c, Warehouse__c 
                                from Inventory__c 
                               where Warehouse__c in :destinationWareshouses])
        {
            
            if(lineItemDestWarehouseMap.containsKey(i.Warehouse__c+'-'+i.Product__c)  && i.RecordType.Name == 'Current Inventory')
            {
                i.Quantity__c += lineItemDestWarehouseMap.get(i.Warehouse__c+'-'+i.Product__c);
                destinationInventory.add(i);
            }
            else if(lineItemDestTransferWarehouseMap.containsKey(i.Warehouse__c+'-'+i.Product__c)  && i.RecordType.Name == 'Current Inventory')
            {
                i.Quantity__c += lineItemDestTransferWarehouseMap.get(i.Warehouse__c+'-'+i.Product__c);
                destinationInventory.add(i);
            }
            else if(lineItemDestDeliveredTransferWarehouseMap.containsKey(i.Warehouse__c+'-'+i.Product__c)  && i.RecordType.Name == 'Current Inventory')
            {
                i.Quantity__c -= lineItemDestDeliveredTransferWarehouseMap.get(i.Warehouse__c+'-'+i.Product__c);
                destinationInventory.add(i);
            }
            if(lineItemDestDeliveredWarehouseMap.containsKey(i.Warehouse__c+'-'+i.Product__c)  && i.RecordType.Name == 'Current Inventory')
            {
                i.Quantity__c += lineItemDestDeliveredWarehouseMap.get(i.Warehouse__c+'-'+i.Product__c);
                destinationInventory.add(i);
            }
        }
        
        //iterte through the  Inventory Items associated with the source wareshouses
        for(Inventory__c i : [Select Id, RecordType.Name, Quantity__c, Product__c, Warehouse__c 
                                 from Inventory__c 
                                where Warehouse__c in :sourceWareshouses])
        {
            if(lineItemSourceWarehouseMap.containsKey(i.Warehouse__c+'-'+i.Product__c) && i.RecordType.Name == 'Current Inventory')
            {
                i.Quantity__c -= lineItemSourceWarehouseMap.get(i.Warehouse__c+'-'+i.Product__c);
                sourceInventory.add(i);
            }
        }
        
        if(sourceInventory.size() > 0)
           update sourceInventory;
           
        if(destinationInventory.size() > 0)
           update destinationInventory;
    }
     
    public void shimpmentCompletionHandler(list<Shipment_Line_Item__c> lineItems)
    {
        /*
        Purpose:
        1.  Links existing asset to Shipment Line Item
        2.  Creates Asset Transfer
        3.  Moves asset to correct Theatre & Screen/Warehouse
        
        Criteria:
        Update
        1.  Line_Status__c = “Shipped”
        2.  CreateAsset_Transfer__c = 1
        
        Actions:
        1.  Link existing asset to Shipment_Line_Item__c record
            a.  Search for existing Asset record where 
                i.  Shipment_Line_Item__r.Product__r.Generic_Name__c  = Asset.Product2.Generic_Name__c 
                ii. Shipment_Line_Item__r.SerialNumber__c = Asset.SerialNumber (NOT Case Sensitive)
            b.  Update Shipment_Line_Item__r.Asset__c with first found asset from (a.) above
            c.  If 0 Assets are found
                i.  Set Shipment_Line_Item__r.NoAssetFound__c to TRUE
        2.  Create Asset Transfer
            a.  Determine if an asset transfer exists - search for existing Asset_Transfer__c record where
                1.  Shipment_Line_Item__r.Shipment__c = Asset_Transfer__r.Shipment__c
                2.  Shipment_Line_Item__r.Asset__c = Asset_Transfer__r.Asset__c
                    ii.  If 1 or more Asset_Transfer__c records are found, STOP processing
                    iii. If 0 Asset_Transfer__c records are found, CREATE new Asset_Transfer__c record.
     */
     
     map<String,Shipment_Line_Item__c> completedLineItems = new map<String,Shipment_Line_Item__c>();
     set<String> productGenericNames = new set<string>();
     set<Id> productIds = new set<Id>();
     map<Id, String> productGenericNameMap = new map<Id, String>();
     map<String, Id> assetMap = new map<String, Id>();
     map<Id, Asset> assetIdMap = new map<Id, Asset>();
     set<String> serialNumbers = new set<String>();
     set<Id> shipmentIds = new set<Id>();
     map<Id,Shipment_Line_Item__c> lineItemsMap = new map<Id,Shipment_Line_Item__c>();
     
     for(Shipment_Line_Item__c li : [select Id, Line_Status__c, CreateAsset_Transfer__c, Product__c
                                          , SerialNumber__c, Asset__c, Shipment__c, NoAssetFound__c
                                          , Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c
                                          , Shipment__r.Destination_Warehouse__r.Account__c
                                          , Shipment__r.Destination_Warehouse__r.InTransitWarehouse__r.Account__c
                                          , Shipment__r.Shipment_Type__c
                                      from Shipment_Line_Item__c
                                     where Id in :lineItems])
     {
        lineItemsMap.put(li.Id,li);
     }
     //========================================
     // Update Asset Ids
     
     //retrieve the products and serial numbers
     for(Shipment_Line_Item__c s : lineItems)
     {
        if((s.Line_Status__c == 'Shipped' || s.Line_Status__c == 'Delivered')  && s.CreateAsset_Transfer__c == 1)
        {
          productIds.add(s.Product__c);
          serialNumbers.add(s.SerialNumber__c);
          shipmentIds.add(s.Shipment__c);
        }
     }
     
     //retrieve the productGeneric Names
     for(Product2 p : [Select Id, Generic_Name__c from Product2 where Id in :productIds])
     {
        productGenericNames.add(p.Generic_Name__c);
        productGenericNameMap.put(p.Id, p.Generic_Name__c);
     }
        
     //retrieve the assets related by Serial Number and Product Generic name
     for(Asset a : [Select Id, SerialNumber, Product2.Generic_Name__c, Warehouse__c
                      from Asset
                     where Product2.Generic_Name__c in :productGenericNames ])
      {
          assetMap.put(a.SerialNumber.toUpperCase()+'-'+a.Product2.Generic_Name__c, a.Id);
          assetIdMap.put(a.Id,a);
      }
      System.debug(':: :: :: assetMap: '+assetMap);
      //bring the asset Ids onto the line items
      for(Shipment_Line_Item__c s : lineItems)
      {
          if(!((s.Line_Status__c == 'Shipped' || s.Line_Status__c == 'Delivered') && s.CreateAsset_Transfer__c == 1))
            continue;
            
          if(s.SerialNumber__c != null && assetMap.containsKey(s.SerialNumber__c.toUpperCase()+'-'+productGenericNameMap.get(s.Product__c)))
            s.Asset__c = assetMap.get(s.SerialNumber__c.toUpperCase()+'-'+productGenericNameMap.get(s.Product__c));
          else
             s.NoAssetFound__c  = true;
          
      }
      
      //========================================
      // Add missing asset transfer
      map<string, Id> ShipmentAssetTransferMap = new map<string, Id>();
      list<Asset_Transfer__c> assetTransfers = new list<Asset_Transfer__c>();
      map<Id, Shipment__c> shipmntMap = new map<Id, Shipment__c>();
      
      //retrieve the shipment attributes needed for the asset transfers
      for(Shipment__c sh : [Select Id, Destination_Warehouse__c,MAS_Reference__c 
                             from Shipment__c
                            where Id in :shipmentIds])
      {
        shipmntMap.put(sh.Id, sh);
      }
      
      //retrieve asset transfers associated with the shipments
      for(Asset_Transfer__c at : [Select Id, Shipment__c , Asset__c
                                    from Asset_Transfer__c 
                                   where Shipment__c in :shipmentIds
                                     and Asset__c in :assetMap.values()])
      {
         ShipmentAssetTransferMap.put(at.Shipment__c+'-'+ at.Asset__c, at.Id);
      }
      
      //create the missing asset transfers
      for(Shipment_Line_Item__c s : lineItems)
      {
         System.Debug(':: :: :: s.Line_Status__c:'+s.Line_Status__c+', s.CreateAsset_Transfer__c '+s.CreateAsset_Transfer__c+', s.Asset__c:'+s.Asset__c+':: :: ::');
         if(!(( s.Line_Status__c == 'Shipped' || s.Line_Status__c == 'Delivered') && s.CreateAsset_Transfer__c == 1) || s.Asset__c == null)
             continue;
            
         if(!ShipmentAssetTransferMap.containsKey(s.Shipment__c+'-'+ s.Asset__c) 
             && !(lineItemsMap.get(s.Id).Shipment__r.Shipment_Type__c == 'RealD Warehouse Transfer' && (s.Line_Status__c == 'Shipped')) )//Do not create Asset Transfers for "Shipped" Warehouse Transfers
         {
            ShipmentAssetTransferMap.put(s.Shipment__c+'-'+ s.Asset__c, s.Id);//so we don't look again
            Id recTypeId = AssetTransferMap__c.getInstance(s.AssetTransferType__c).Record_Type_ID__c;
            
            if(lineItemsMap.get(s.Id).Shipment__r.Shipment_Type__c == 'RealD Warehouse Transfer' && s.Line_Status__c == 'Delivered')
            {
                for(RecordType rt : [Select Id from RecordTYpe where SObjectType = 'Asset_Transfer__c' and Name = 'Warehouse Transfer'])
                   recTypeId = rt.Id;
            }
            Asset_Transfer__c at
                 = new Asset_Transfer__c(RecordTypeId = recTypeId
                                        ,Name = s.Asset_Transfer_Name__c//productGenericNameMap.get(s.Product__c)+' '+s.AssetTransferType__c//Transfer_Naming_Convention__c
                                        ,Destination_Screen__c  = s.Screen__c
                                        ,Source_Warehouse__c = s.SourceWarehouse__c
                                        ,Transfer_Begin_Date__c = s.ShipDate__c
                                        ,Destination_Warehouse__c = shipmntMap.get(s.Shipment__c).Destination_Warehouse__c
                                        ,Shipment__c = s.Shipment__c
                                        ,Asset__c = s.Asset__c
                                        ,MAS_Reference__c   = shipmntMap.get(s.Shipment__c).MAS_Reference__c
                                        ,Update_Asset__c = TRUE
                                        ,Created_via_API__c =   TRUE);
           
           if(lineItemsMap.get(s.Id).Shipment__r.Shipment_Type__c == 'RealD Warehouse Transfer' && s.Line_Status__c == 'Delivered')
              at.Transfer_End_Date__c = s.DeliveryDate__c;
           
            assetTransfers.add(at);
            
         }
      }
       
      if(assetTransfers.size() > 0)
        insert(assetTransfers);
        
      //update the Assets' warehouse for the RealD Warehouse Transfers
      set<Asset> assetWarehouseSet = new set<Asset>();
      
      for(Shipment_Line_Item__c s : lineItems)
      {
          if(s.Asset__c == null)
            continue;
          
          if(lineItemsMap.get(s.Id).Shipment__r.Shipment_Type__c == 'RealD Warehouse Transfer')
          {
            Asset a = new Asset(Id=s.Asset__c);
            
            if(s.Line_Status__c == 'Shipped')
            {
               a.Warehouse__c = lineItemsMap.get(s.Id).Shipment__r.Destination_Warehouse__r.InTransitWarehouse__c;
               a.AccountId    = lineItemsMap.get(s.Id).Shipment__r.Destination_Warehouse__r.InTransitWarehouse__r.Account__c;
               System.Debug('::::Shipment__r.Destination_Warehouse__r.InTransitWarehouse__r.Account__c:: '+lineItemsMap.get(s.Id).Shipment__r.Destination_Warehouse__r.InTransitWarehouse__r.Account__c);
               //Add the account of the in transit warehouse
            }
            else if(s.Line_Status__c == 'Delivered')
            {
               a.Warehouse__c = lineItemsMap.get(s.Id).Shipment__r.Destination_Warehouse__c; 
               //Add the link to the account associated with the destination warehouse
               a.AccountId = lineItemsMap.get(s.Id).Shipment__r.Destination_Warehouse__r.Account__c;
               System.Debug('::::Shipment__r.Destination_Warehouse__r.Account__c:>>: '+lineItemsMap.get(s.Id).Shipment__r.Destination_Warehouse__r.Account__c);
               
            }
            
            assetWarehouseSet.add(a);
          }
      }
      
      list<Asset> assetWarehouseList = new list<Asset>();
      assetWarehouseList.addAll(assetWarehouseSet);
      if(assetWarehouseList.size() > 0)
        update assetWarehouseList;
      
    }
    
    
   

}