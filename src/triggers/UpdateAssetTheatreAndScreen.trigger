trigger UpdateAssetTheatreAndScreen on Asset_Transfer__c (before insert, before update) {

/****************************************************************************************
 * Name    : UpdateAssetTheatreAndScreen
 * Author  : Nathan Shinn
 * Date    : 07-13-2011
 * Purpose : Update Asset Theatre and Screen/Warehouse from linked Asset Transfer
 * 			 When: Asset_Transfer.Update_Asset__c = TRUE
 *			    AND Asset_Transfer.Destination__Screen__c NOT Blank
 *			    AND Asset_Transfer.Asset__c NOT Blank
 *			     1. Update Asset.Screen__c with value from Destination_Screen__c
 *			     2. Update Asset.Account (Theatre) with Destination_Screen__c.Theatre__c (Theatre field from linked Destination Screen Record)
 *			When: Asset_Transfer.Update_Asset__c = TRUE
 *			   AND Asset_Transfer.Destination__Warehouse__c NOT Blank
 *			   AND Asset_Transfer.Asset__c NOT Blank
 *			    1.  Update Asset.Warehouse__c with Destination_Warehouse__c
 *			    2.  Update Asset.Account (Theatre) with Destination_Warehouse__c.Account__c (Account field from linked Destination Warehouse Record)
 *
 **========================
 * = MODIFICATION HISTORY =
 **========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 07-13-2011  Nathan Shinn        Created
 *
 *****************************************************************************************/
 /*
   Map <Id, Asset_Transfer__c>AssetMap =  new Map <Id, Asset_Transfer__c>();
   Map <Id, Asset_Transfer__c>AssetWarehouseMap =  new Map <Id, Asset_Transfer__c>();
   set<Id> screens = new set<Id>();
   set<Id> wherehouses = new set<Id>();
   
   for (Asset_Transfer__c at : trigger.new) 
   {
   	  if (at.Update_Asset__c && at.Destination_Screen__c != null && at.Asset__c != null)
   	  {
   	  	AssetMap.put(at.Asset__c, at);
   	  	screens.add(at.Destination_Screen__c);
   	  }
   	  if (at.Update_Asset__c && at.Destination_Warehouse__c != null && at.Asset__c != null)
   	  {
   	  	AssetWarehouseMap.put(at.Asset__c, at);
   	  	wherehouses.add(at.Destination_Warehouse__c);
   	  }
   }
   
   map<Id, Screens__c> screenMap = new  map<Id, Screens__c>([select Id, Theater__c from Screens__c where Id in :screens]);
    
   
   list<Asset> aList = new list<Asset>();
   for(Asset a : [select Id from Asset where Id in :AssetMap.keySet()])
   {
   	  a.screen__c =  assetMap.get(a.Id).Destination_Screen__c;
   	  a.AccountId  = screenMap.get(assetMap.get(a.Id).Destination_Screen__c).Theater__c;
   	  aList.add(a);
   }
   //update the asset
   if(aList.size() > 0)
     update aList;
     
   aList.clear();
   
   map<Id, Warehouse__c> warehouseMap = new  map<Id, Warehouse__c>([select Id, Account__c from Warehouse__c where Id in :wherehouses]);
    
   for(Asset a : [select Id from Asset where Id in :AssetWarehouseMap.keySet()])
   {
   	  a.Warehouse__c =  AssetWarehouseMap.get(a.Id).Destination_Warehouse__c;
   	  a.AccountId  = warehouseMap.get(AssetWarehouseMap.get(a.Id).Destination_Warehouse__c).Account__c;
   	  aList.add(a);
   }
   
   //update the asset
   if(aList.size() > 0)
     update aList;
     
 */  
     
   
}