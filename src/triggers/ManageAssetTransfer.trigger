trigger ManageAssetTransfer on Asset_Transfer__c (before insert, before update) {
	
 /****************************************************************************************
 * Name    : ManageAssetTransfer
 * Author  : Nathan Shinn
 * Date    : 08-10-2011
 * Purpose : When: Removes inapplicable values in the screen/warehouse fields
 *             a. IF Record Type = “Install” AND (Source_Screen__c != NULL OR Destination_Warehouse__c != NULL), 
 *                 Update Source_Screen__c and Destination_Warehouse__c to NULL values.
 *             b. IF Record Type = “Move” AND (Source_Warehouse__c != NULL OR Destination_Warehouse__c != NULL), 
 *                 Update Source_Warehouse__c and Destination_Warehouse__c to NULL values.
 *             c. IF Record Type = “Return” AND (Source_Warehouse__c != NULL OR Destination_Screen__c != NULL), 
 *                 Update Source_Warehouse__c and Destination_Screen__c to NULL values.
 *             d. IF Record Type = “Warehouse Transfer” AND (Source_Screen__c != NULL OR Destination_Screen__c != NULL), 
 *                 Update Source_Screen__c and Destination_Screen__c to NULL values.
 *                 
 * ========================
 * = MODIFICATION HISTORY =
 * ========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 08-10-2011  Nathan Shinn        Created
 *
 *****************************************************************************************/
   
   Id installRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Install').getRecordTypeId();
   Id wareshouseRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Warehouse Transfer').getRecordTypeId();
   Id moveRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Move').getRecordTypeId();
   Id returnRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Return').getRecordTypeId();
   
   for(Asset_Transfer__c at : trigger.new)
   {
   	   if(at.RecordTypeId == installRecType)
   	   {
   	   	  at.Source_Screen__c = null;
   	   	  at.Destination_Warehouse__c = null;
   	   }
   	   
   	   if(at.RecordTypeId == moveRecType)
   	   {
   	   	  at.Destination_Warehouse__c = null;
   	   	  at.Source_Warehouse__c = null;
   	   }
   	   
   	   if(at.RecordTypeId == returnRecType)
   	   {
   	   	  at.Source_Warehouse__c = null;
   	   	  at.Destination_Screen__c = null;
   	   }
   	   
   	   if(at.RecordTypeId == wareshouseRecType)
   	   {
   	   	  at.Source_Screen__c = null;
   	   	  at.Destination_Screen__c = null;
   	   }
   }
}