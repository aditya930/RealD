trigger ShipmentLineItemTrigger_Suyati on Shipment_Line_Item__c (before insert, before update, after insert, after update) {
  
  ShipmentLineItemTriggerHandler_suyati  handler = new ShipmentLineItemTriggerHandler_suyati ();
  
  if(trigger.isBefore){
    
    if(trigger.isUpdate)
       handler.onBeforeUpdate(trigger.oldMap, trigger.newMap);
  }
  if(trigger.isAfter){
    
    if(trigger.isUpdate)
       handler.onAfterUpdate(trigger.oldMap, trigger.newMap);
       
    if(trigger.isInsert)
       handler.onAfterInsert(trigger.newMap); 
  }

}