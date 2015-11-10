trigger UpdateAssetComponentMaterialFinishedProduct on Asset (after insert, after update, before insert, before update, before delete) {
    
    AssetTriggerHandler handler = new AssetTriggerHandler();
    
    if(trigger.isUpdate)
    {
      if(trigger.isBefore) handler.OnBeforeUpdate(trigger.oldMap, trigger.newMap);
      
      if(trigger.isAfter) handler.OnAfterUpdate(trigger.oldMap, trigger.newMap);
    }
      
    if(trigger.isInsert)
    {
      if(trigger.isAfter) handler.OnAfterInsert(trigger.new);
      
      if(trigger.isBefore) handler.OnBeforeInsert(trigger.new);
    }
    
    if(trigger.isDelete)
    {
      if(trigger.isBefore) handler.OnBeforeDelete(trigger.old);
    }
    

}