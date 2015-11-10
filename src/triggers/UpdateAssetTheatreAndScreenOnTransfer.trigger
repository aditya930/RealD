trigger UpdateAssetTheatreAndScreenOnTransfer on Asset_Transfer__c (after insert, after update) {
/****************************************************************************************
 * Name    : UpdateAssetTheatreAndScreenOnTransfer
 * Author  : Nathan Shinn
 * Date    : 07-20-2011
 * Purpose : When: Asset_Transfer.Update_Asset__c = TRUE AND Asset_Transfer.Destination__Screen__c 
 *                 NOT Blank AND Asset_Transfer.Asset__c NOT Blank
 *                 ·         Update Asset.Screen__c with value from Destination_Screen__c
 *                 ·         Update Asset.Account (Theatre) with Destination_Screen__c.Theatre__c 
 *                           (Theatre field from linked Destination Screen Record)
 *            When: Asset_Transfer.Update_Asset__c = TRUE AND
 *                  Asset_Transfer.Destination__Warehouse__c NOT Blank AND Asset_Transfer.Asset__c 
 *                  NOT Blank
 *                 ·         Update Asset.Warehouse__c with Destination_Warehouse__c
 *                 ·         Update Asset.Account (Theatre) with Destination_Warehouse__c.Account__c 
 *                           (Account field from linked Destination Warehouse Record)
 *
 * ========================
 * = MODIFICATION HISTORY =
 * ========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 07-20-2011  Nathan Shinn        Created
 *
 *****************************************************************************************/
 list<Asset> assets = new list<Asset>();
 for(Asset_Transfer__c at : [select Id, Destination_Screen__c
                                    , Destination_Screen__r.Theater__c
                                    , Destination_Warehouse__c
                                    , Destination_Warehouse__r.Account__c
                                    , Asset__c
                                    , Update_Asset__c
                               from Asset_Transfer__c 
                              where Id in :trigger.newMap.keySet()])
 {
 	if (at.Update_Asset__c)
 	{
 		Asset a = new Asset(Id=at.Asset__c);
 		if(at.Destination_Screen__c != null && at.Asset__c != null)
 		{
 		   a.Screen__c = at.Destination_Screen__c;
 		   a.Warehouse__c = null;
 		   if(at.Destination_Screen__r.Theater__c != null)
 		       a.AccountId = at.Destination_Screen__r.Theater__c;
 		                      
 		   
 		}
 		   
 		if(at.Destination_Warehouse__c != null && at.Asset__c != null)
 		{
 		  a.Warehouse__c = at.Destination_Warehouse__c;
 		  a.Screen__c = null;
 		  if(at.Destination_Warehouse__r.Account__c != null)
 		     a.AccountId = at.Destination_Warehouse__r.Account__c;
 		}
 		
 		assets.add(a);
 	}
 }
 
 if(assets.size() > 0)
    update assets;
 
}