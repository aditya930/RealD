public with sharing class InventoryTriggerHandler {
	
    public static void onBeforeUpdate(map<Id, Inventory__c> oldMap, map<Id, Inventory__c> newMap)
    {
    	RecordType rt = [select Id from recordType where Name = 'Inventory Adjustment' and SObjectType = 'Inventory__c'];
    	list<Inventory__c> adjustmentList = new list<Inventory__c>();
    	for(Inventory__c i : newMap.values())
    	{
    		if(i.RecordTypeId == rt.Id && i.Approved__c == true && oldMap.get(i.Id).Approved__c == false)
    		{
    			adjustmentList.add(i);
    			
    		}
    	}
    	
    	if(adjustmentList.size() > 0)
    	{
    		adjustInventoryQuantity(adjustmentList);
    	}
    } 
    
    static void adjustInventoryQuantity(list<Inventory__c> iventoryAdjustments)
    {
    	set<Id> warehouseIds = new set<Id>();
    	set<Id> productIds = new set<Id>();
    	map<string,Inventory__c> adjustmentMap = new map<string,Inventory__c>();
    	
    	for(Inventory__c i : iventoryAdjustments)
    	{
    		warehouseIds.add(i.Warehouse__c);
    		productIds.add(i.Product__c);
    		adjustmentMap.put(i.Warehouse__c + '-' + i.Product__c, i);
    	}
    	
    	list<Inventory__c> inventoryToUpdate = new list<Inventory__c>();
    	
    	for(Inventory__c i : [Select Id, Warehouse__c, Product__c, Quantity__c 
    	                     from Inventory__c
    	                    where Warehouse__c in :warehouseIds
    	                      and Product__c in :productIds
    	                      and RecordType.Name = 'Current Inventory' ])
    	{
    		
    		if(adjustmentMap.containsKey(i.Warehouse__c + '-' + i.Product__c))
    		{
    			if(i.Quantity__c == null) i.Quantity__c = 0;
    			i.Quantity__c += adjustmentMap.get(i.Warehouse__c + '-' + i.Product__c).Quantity__c;
    			inventoryToUpdate.add(i);
    		}
    	}
    	
    	if(inventoryToUpdate.size() > 0)
    	  update inventoryToUpdate;
    }

}