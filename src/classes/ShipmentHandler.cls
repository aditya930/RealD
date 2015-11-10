public without sharing class ShipmentHandler {
	
	/*
	   
	  
	 */
	 
	 public void afterUpdate(map<Id,Shipment__c> oldMap, map<Id,Shipment__c> newMap)
	 {
	 	list<Shipment__c> scheduledShipments = new list<Shipment__c>();
	 	list<Shipment__c> recalledShipments = new list<Shipment__c>();
	 	//collect the scheduled shipments
	 	for(Shipment__c s : newMap.values())
	 	{
	 	  if(s.Status__c == 'Scheduled')
	 	     scheduledShipments.add(s);
	 	     
	 	  if(s.Recalled__c)
	 	  	recalledShipments.add(s);
	 	     
	 	}
	 	     
	 	 
	 	list<Shipment_Line_Item__c> lineItemsToSchedule = new list<Shipment_Line_Item__c>();
	 	list<Shipment_Line_Item__c> lineItemsToPending = new list<Shipment_Line_Item__c>();
	 	
	 	//update the shipment Line items associated with the scheduled shipments
	 	for(Shipment_Line_Item__c sl : [Select Id, LineSummary__c, Shipment__c, Line_Status__c 
	 	                                  from Shipment_Line_Item__c 
	 	                                 where Shipment__c in :scheduledShipments ])
	 	{
	 	  if(sl.Line_Status__c == 'Pending')
	 	  {
	 	     sl.Line_Status__c = 'Scheduled';
	 	     lineItemsToSchedule.add(sl);	 	  
	 	  }
	 	  
	 	}
	 	
	 	//update the shipment Line items associated with the recalled shipments
	 	for(Shipment_Line_Item__c sl : [Select Id, LineSummary__c, Shipment__c, Line_Status__c 
	 	                                  from Shipment_Line_Item__c 
	 	                                 where Shipment__c in :recalledShipments ])
	 	{
	 	  	sl.Line_Status__c = 'Pending';
	 	    lineItemsToPending.add(sl);
	 	  
	 	}
	 	
	 	//update the scheduled line items
	 	if(lineItemsToSchedule.size() > 0)
	 	   update lineItemsToSchedule;	 	
	 	//update the pending/recalled line items
	 	if(lineItemsToPending.size() > 0)
	 	   update lineItemsToPending;
	 	    
	 	  
	 }
	 
	 public void beforeUpdate(map<Id,Shipment__c> oldMap, map<Id,Shipment__c> newMap)
	 {
	 	list<Shipment__c> scheduledShipments = new list<Shipment__c>();
	 	//collect the scheduled shipments
	 	for(Shipment__c s : newMap.values())
	 	  if(s.Status__c == 'Scheduled')
	 	     scheduledShipments.add(s);
	 	 
	 	map<Id, Shipment__c> shipmentUpdate = new map<Id, Shipment__c>();
	 	//update the shipment Line items associated with the scheduled shipments
	 	for(Shipment_Line_Item__c sl : [Select Id, LineSummary__c, Shipment__c, Line_Status__c 
	 	                                  from Shipment_Line_Item__c 
	 	                                 where Shipment__c in :scheduledShipments ])
	 	{
	 	  if(oldMap.get(sl.Shipment__c).Status__c != newMap.get(sl.Shipment__c).Status__c)
	 	  {
	 	  	  if(shipmentUpdate.containsKey(sl.Shipment__c))
	 	  	  {
	 	  	  	shipmentUpdate.get(sl.Shipment__c).LineProducts__c += '\n'+sl.LineSummary__c;//used to track updated items
	 	  	  	newMap.get(sl.Shipment__c).LineProducts__c =shipmentUpdate.get(sl.Shipment__c).LineProducts__c;
	 	  	  	
	 	  	  }
	 	  	  else
	 	  	  {
	 	  	  	Shipment__c s = new Shipment__c(Id = sl.Shipment__c, LineProducts__c = 'Product | Product Code | Qty\n'+sl.LineSummary__c);
	 	  	  	shipmentUpdate.put(s.Id,s); 
	 	  	  	newMap.get(sl.Shipment__c).LineProducts__c =shipmentUpdate.get(sl.Shipment__c).LineProducts__c;
	 	  	  }
	 	  }
	 	  
	 	}
	 	  
	 	  
	 }

}