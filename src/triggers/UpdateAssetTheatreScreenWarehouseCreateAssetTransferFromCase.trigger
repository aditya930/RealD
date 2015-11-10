trigger UpdateAssetTheatreScreenWarehouseCreateAssetTransferFromCase on Case (after update) {
/****************************************************************************************
 * Name    : UpdateAssetTheatreScreenWarehouseCreateAssetTransferFromCase
 * Author  : Nathan Shinn
 * Date    : 07-20-2011
 * Purpose : When: Case.Product_Received_Date__c NOT Blank AND Case.Asset NOT Blank
 *                  AND Case.Screen__c NOT Blank
 *                  ·         Update Asset:
 *                  o    Warehouse__c  = Case.Destination_Warehouse__c
 *                  o    Theatre = Case.Destination_Warehouse__c.Account__c
 *                  ·         Create New Asset Transfer
 *                  o    Record Type: "Return"
 *                  o    Transfer_Begin_Date__c = DATE(Case.Waiting_for_Return__c)
 *                  o    Transfer_End_Date__c = DATE(Case.Product_Received__c)
 *                  o    Source_Screen__c = Case.Screen__c
 *                  o    Asset = Case.Asset__c
 *                  o    Name = (Concatenate) Asset.Product2.Name&"Return" (eg: Zscreen Return)
 *                  o    Destination_Warehouse__c =Case.Destination_Warehouse__c
 *                  o    Case_For_RMA__c = Case.ID
 *
 * ========================
 * = MODIFICATION HISTORY =
 * ========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 07-20-2011  Nathan Shinn         Created
 * 08-17-2014  Nathan Shinn         Set Asset as Used when Returned on an RMA
 *
 *****************************************************************************************/
 list<Asset> assets = new list<Asset>();
 list<Asset_Transfer__c> assetTransfers = new list<Asset_Transfer__c>();
 Id installRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Install').getRecordTypeId();
 Id returnRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Return').getRecordTypeId();
 Id WareshouseRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Warehouse Transfer').getRecordTypeId();
 map<Id, Id> asset_Transfer_Map = new map<Id, Id>();           
 
 
 for(Asset_Transfer__c a : [Select Id, Case_For_RMA__c 
                              from Asset_Transfer__c 
                             where Case_For_RMA__c in :trigger.newmap.keySet()])
   asset_transfer_map.Put(a.Case_For_RMA__c, a.Id);
           
 Id defaultAccount = [select Account__c from Warehouse__c where Id = :Default_Destination_Warehouse__c.getInstance('Default').Warehouse_Id__c].Account__c;
 
 for(Case c : [select Id
                    , Destination_Warehouse__c
                    , Destination_Warehouse__r.Account__c
                    , AssetId
                    , Asset.Product2.Name
                    , Asset.Product2.generic_name__c
                    , Screen__c
                    , Waiting_for_Return__c
                    , Product_Received__c
               from Case c
              where Id in :trigger.newMap.keySet()
                and AssetId != null
                and Product_Received__c != null
                and Screen__c != null])
 {
    if(asset_transfer_map.get( c.Id) != null)
      continue; 
    
    Asset a = new Asset(Id = c.AssetId
                       ,Warehouse__c = c.Destination_Warehouse__c
                       ,Screen__c = null);
    if(c.Destination_Warehouse__c != NULL && c.Destination_Warehouse__r.Account__c != NULL)
    {
        a.AccountId = c.Destination_Warehouse__r.Account__c;
        
    }
    
    if(c.Destination_Warehouse__c == null) 
    {
       a.Warehouse__c = Default_Destination_Warehouse__c.getInstance('Default').Warehouse_Id__c;
       a.AccountId = defaultAccount;
    }
       
    assets.add(a);
    
    Date wrDate = null;
    Date teDate = null;
    if(c.Waiting_for_Return__c != null)
             wrDate = Date.newInstance(c.Waiting_for_Return__c.year()
                                      ,c.Waiting_for_Return__c.month()
                                      ,c.Waiting_for_Return__c.day() );
    if(c.Product_Received__c != null)
             teDate = Date.newInstance(c.Product_Received__c.year()
                                      ,c.Product_Received__c.month()
                                      ,c.Product_Received__c.day() );
                                 
    Asset_Transfer__c at = new Asset_Transfer__c(Transfer_Begin_Date__c = wrDate
                                                ,Transfer_End_Date__c = teDate
                                                ,recordTypeId = returnRecType
                                                ,Source_Screen__c = c.Screen__c
                                                ,Asset__c = c.AssetId
                                                ,Name = c.Asset.Product2.generic_name__c +' Return'
                                                ,Destination_Warehouse__c =c.Destination_Warehouse__c
                                                ,Case_For_RMA__c = c.ID
                                                ,Created_Via_API__c = TRUE);
    if(c.Destination_Warehouse__c != null) 
       at.Destination_Warehouse__c = c.Destination_Warehouse__c;
    else
       at.Destination_Warehouse__c = Default_Destination_Warehouse__c.getInstance('Default').Warehouse_Id__c;
            
    assetTransfers.add(at);
 }
 
 if(assets.size() > 0)
    update assets;
    
 if(assetTransfers.size() > 0)
    insert assetTransfers;
    
  /* 
    Set Asset as Used when Returned on an RMA
            Criteria: On Update of Case record where RMA_Status__c = "Product Received" AND MarkAssetUsed__c = TRUE
            Actions: Set case.asset__r.Used__c = TRUE
  */
  map<Id, Asset> assetToUpdate = new map<Id, Asset>();
  if(trigger.isUpdate) 
  {
     for(Case c : trigger.new)
     {
      
          if(c.RMA_Status__c == 'Product Received' && c.MarkAssetUsed__c == TRUE && c.AssetId != null
            && (trigger.oldmap.get(c.Id).RMA_Status__c != c.RMA_Status__c || trigger.oldMap.get(c.Id).MarkAssetUsed__c) )
          {
              assetToUpdate.put(c.AssetId, new Asset(Id = c.AssetId, Used__c = TRUE));
          }
          
           
     }
     if(assetToUpdate.size() > 0)
     {
        update assetToUpdate.values();
     }
  }
}