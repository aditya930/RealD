trigger InventoryTrigger on Inventory__c (before update) {
	
	InventoryTriggerHandler.onBeforeUpdate(trigger.oldMap, trigger.newMap);

}