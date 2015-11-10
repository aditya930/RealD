trigger Shipment_Completion_Asset_Update on Shipment__c (after update, before update, before Insert) {
    /****************************************************************************************
     * Name    : Shipment_Completion_Asset_Update
     * Author  : Nathan Shinn
     * Date    :  8/16/2011
     * Purpose :1. Updates existing Assets associated with a shipment
     *          2. Creates Asset records that should exist and associates them to the shipment 
     *          3. Creates Asset Transfer records for the shipment and assets.
     *
     *
     * ========================
     * = MODIFICATION HISTORY =
     * ========================
     * DATE        AUTHOR               CHANGE
     * ----        ------               ------
     * 8/21/2011   Nathan Shinn         Created
     * 9/05/2011   Nathan Shinn         Remove mount logic and add comments
     * 9/15/2011   Nathan Shinn         Move all Logic to the ShipmentTriggerActions class
     * 09/18/2011  Nathan Shinn         Consolidate field update logic
     * 06/11/2011  Nathan Shinn         Add call to send License Key email
     * 11/09/2012  Nathan Shinn         Remove legacy Shipment fields
     *
     *****************************************************************************************/ 
     
     
     
     //update trigger fields
     System.debug('+++++++++|> Update Shipment Fields');
     /*if(trigger.isBefore)
        updateShipmentFields();*/
    
     //instantiate the trigger actions class
     ShipmentTriggerActions sta= new ShipmentTriggerActions();
     ShipmentHandler handler = new ShipmentHandler();
     
     if(trigger.isBefore && trigger.isUpdate)
     {
       handler.beforeUpdate(trigger.oldMap, trigger.newMap);
     }
     
     //Add the asset transfer records
     if(trigger.isAfter && trigger.isUpdate)
     {
       //sta.addAssetTransfer(trigger.newMap,trigger.oldMap, trigger.isInsert);
       
       handler.afterUpdate(trigger.oldMap, trigger.newMap);
       
       //Call the License File Email method
       EncryptionWrapper.sendEmailFromShipmentUpdate(trigger.newMap.keySet());
     }
     

  
}