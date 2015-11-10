public class ShipmentTriggerActions {
	map<string, Shipment__c> processedShipmentMap = new map<string, Shipment__c>();
	map<Id, String> ProductGenericNamesMap = new map<Id, String>();
	map<Id, Id> theaterMap = new map<Id, String>();
	map<Id, Id> warehouseMap = new map<Id, Id>();
	/*
	public Map<string, Asset> addUpdateShipmentAssets(Map<Id, Shipment__c> newMap
	                                                , Map<Id, Shipment__c> oldMap
	                                                , Boolean isInsert
	                                                , Boolean isUpdate )
	{
	   set<Id> Product_Set = new set<Id>();
	   set<Id> Screen_Set = new set<Id>();
	   set<Id> Warehouse_Set = new set<Id>();
	   set<String> Serial_Number_Set = new set<string>();
	   map<string, Shipment__c> shipmentMap = new map<string, Shipment__c>();
	   list<Asset> assetUpdates = new list<Asset>();
	   list<Asset> assetCreate = new list<Asset>();
	   map<string, Asset> shipmentAssetIds = new map<String, Asset>();
	  
	   for(Shipment__c s : newMap.values())
	   {  
	     
	      
	      if(s.Status__c == 'Shipped')
	      {
	      	if(s.Line_1_Serial_Number__c != NULL)
	      	{
		         Product_Set.add(s.Line_1_Product__c);
		         Serial_Number_Set.add(s.Line_1_Serial_Number__c );
		         shipmentMap.put(s.Line_1_Product__c+'-'+s.Line_1_Serial_Number__c, s);
	      	}
	      	if(s.Line_2_Serial_Number__c != NULL)
	      	{
		         Product_Set.add(s.Line_2_Product__c);
		         Serial_Number_Set.add(s.Line_2_Serial_Number__c );
		         shipmentMap.put(s.Line_2_Product__c+'-'+s.Line_2_Serial_Number__c, s);
	      	}
	      	if(s.Line_3_Serial_Number__c != NULL)
	      	{
		         Product_Set.add(s.Line_3_Product__c);
		         Serial_Number_Set.add(s.Line_3_Serial_Number__c );
		         shipmentMap.put(s.Line_3_Product__c+'-'+s.Line_3_Serial_Number__c, s);
	      	}
	      	if(s.Line_4_Serial_Number__c != NULL)
	      	{
		         Product_Set.add(s.Line_4_Product__c);
		         Serial_Number_Set.add(s.Line_4_Serial_Number__c );
		         shipmentMap.put(s.Line_4_Product__c+'-'+s.Line_4_Serial_Number__c, s);
	      	}
	      	if(s.Line_5_Serial_Number__c != NULL)
	      	{
		         Product_Set.add(s.Line_5_Product__c);
		         Serial_Number_Set.add(s.Line_5_Serial_Number__c );
		         shipmentMap.put(s.Line_5_Product__c+'-'+s.Line_5_Serial_Number__c, s);
	      	}
	      	Screen_Set.add(s.Screen__c);
	      	if(s.Destination_Warehouse__c != null)
	      	   Warehouse_Set.add(s.Destination_Warehouse__c);	      
	      }
	   }
	   
	   //map the products to get the generic names
	   for(Product2 p : [select Id, Generic_Name__c from Product2 where Id in :Product_Set])
	     ProductGenericNamesMap.put(p.Id, p.Generic_Name__c);
	   
	   //load a map of theater (Account) Ids
	   for(Screens__c s :[select Id, Theater__c from Screens__c where Id in :Screen_set and Theater__c != null] )
	     theaterMap.put(s.Id, s.Theater__c);
	     
	   //load a map of warehouse Ids
	   for(Warehouse__c s :[select Id, Account__c from Warehouse__c where Id in :Warehouse_set and Account__c != null])
	     warehouseMap.put(s.Id, s.Account__c);
	     
	   if(Product_Set.size() > 0)
	   {
	      //update existing assets
	      for(Asset a : [select Id,Product2Id,Asset.SerialNumber
	                       from Asset 
	                      where Product2Id in :Product_Set
	                        and SerialNumber in :Serial_Number_Set])
	      {
	        if(shipmentMap.get(a.Product2Id + '-' + a.SerialNumber) != null
	         && processedShipmentMap.get(a.Product2Id + '-' + a.SerialNumber) == null)
	        {
	           Shipment__c s = shipmentMap.get(a.Product2Id + '-'+ a.SerialNumber);
	           processedShipmentMap.put(a.Product2Id + '-' + a.SerialNumber, s);
	           
	           if(!s.Ship_to_Warehouse__c) 
	           {
	           	  //a.AccountId = theaterMap.get(s.Screen__c);
	           	  
	              //a.Screen__c = s.Screen__c;
	             	                
	              a.Warehouse__c = null;
	              assetUpdates.add(a);
	              shipmentAssetIds.put(a.Product2Id + '-'+ a.SerialNumber, a);
	           } 
	           
	           if(s.Ship_to_Warehouse__c) 
	           {
	              a.Screen__c = null;
	              a.AccountId = warehouseMap.get(s.Destination_Warehouse__c);
	              a.Warehouse__c = s.Destination_Warehouse__c;
	              assetUpdates.add(a);
	              shipmentAssetIds.put(a.Product2Id + '-'+ a.SerialNumber, a);
	           } 
	           
	        }
	      }
	   
	     if(assetUpdates.size() > 0)
	        update assetUpdates;
	     
	        
	        
	     //create assets that did not exist
	     /*
	     for(Shipment__c s : newMap.values())
	     {
	       if(s.Status__c != 'Shipped')
	         continue;
	         
	        if(s.Asset_1__c == null 
	         && s.Line_1_Serial_Number__c != null 
	         && processedShipmentMap.get(s.Line_1_Product__c+'-'+s.Line_1_Serial_Number__c) == null) 
	           assetCreate.add(createAssetObj(ProductGenericNamesMap.get(s.Line_1_Product__c) + '-' + s.Line_1_Serial_Number__c
	                                         ,s.Line_1_Product__c 
	                                         ,s.Line_1_Serial_Number__c
	                                         ,s));
	                                         
	        if(s.Asset_2__c == null 
	           && s.Line_2_Serial_Number__c != null &&processedShipmentMap.get(s.Line_2_Product__c+'-'+s.Line_2_Serial_Number__c) == null) 
	           assetCreate.add(createAssetObj(ProductGenericNamesMap.get(s.Line_2_Product__c) + '-' + s.Line_2_Serial_Number__c
	                                         ,s.Line_2_Product__c 
	                                         ,s.Line_2_Serial_Number__c
	                                         ,s));
	        
	        if(s.Asset_3__c == null 
	           && s.Line_3_Serial_Number__c != null && processedShipmentMap.get(s.Line_3_Product__c+'-'+s.Line_3_Serial_Number__c) == null) 
	           assetCreate.add(createAssetObj(ProductGenericNamesMap.get(s.Line_3_Product__c) + '-' + s.Line_3_Serial_Number__c
	                                         ,s.Line_3_Product__c 
	                                         ,s.Line_3_Serial_Number__c
	                                         ,s));
	          
	        if(s.Asset_4__c == null 
	           && s.Line_4_Serial_Number__c != null && processedShipmentMap.get(s.Line_4_Product__c+'-'+s.Line_4_Serial_Number__c) == null) 
	           assetCreate.add(createAssetObj(ProductGenericNamesMap.get(s.Line_4_Product__c) + '-' + s.Line_4_Serial_Number__c
	                                         ,s.Line_4_Product__c 
	                                         ,s.Line_4_Serial_Number__c
	                                         ,s));
	        
            if(s.Asset_5__c == null 
	           && s.Line_5_Serial_Number__c != null 
	           && processedShipmentMap.get(s.Line_5_Product__c+'-'+s.Line_5_Serial_Number__c) == null) 
	           assetCreate.add(createAssetObj(ProductGenericNamesMap.get(s.Line_5_Product__c) + '-' + s.Line_5_Serial_Number__c
	                                         ,s.Line_5_Product__c 
	                                         ,s.Line_5_Serial_Number__c
	                                         ,s));
	                                         
	          //s.addError('theaterMap.get(s.Screen__c): '+theaterMap.get(s.Screen__c)+ ' warehouseMap.get(s.Id): '+warehouseMap.get(s.Id) );
	     } 
	     
	    
	     
	     //create missing Assets
	     if(assetCreate.size() > 0)
	        insert assetCreate;
	        
	        
	     System.debug('AAAAAAAAAAAAAAAAAAAA assetCreate> '+assetCreate);
	     //create a map back to the new asset Ids to associate to the Shipments   
	     for(Asset a : assetCreate)
	       shipmentAssetIds.put(a.Product2Id + '-'+ a.SerialNumber, a);
	     
	   }
	   System.debug('VVVVVVVVVVVVVVVVVVV shipmentAssetIds> '+shipmentAssetIds);
	   return shipmentAssetIds;
	}
	
	private Asset createAssetObj(String name, Id productId, String serialNum, Shipment__c s)
	{
		
		Asset a = new Asset();
		
		if(!s.Ship_to_Warehouse__c) 
        {
          a.AccountId = theaterMap.get(s.Screen__c);
          a.Name = name;
          a.Screen__c = s.Screen__c;
          a.SerialNumber = serialNum;
          a.Product2Id = productId;
          a.Warehouse__c = null;
        } 
       
        if(s.Ship_to_Warehouse__c) 
        {
          a.AccountId = warehouseMap.get(s.Destination_Warehouse__c); 
          a.Name = name;
          a.Screen__c = null;
          a.SerialNumber = serialNum;
          a.Product2Id = productId;
          a.Warehouse__c = s.Destination_Warehouse__c;
        }
        
        processedShipmentMap.put(a.Product2Id + '-' + a.SerialNumber, s);
        
		return a;
	}
	
	//filters out duplicate attet transfer records
	public map<string, Asset_Transfer__c> existingTransferMap = new  map<string, Asset_Transfer__c>();
	
	public void addAssetTransfer(Map<Id, Shipment__c> newMap, Map<Id, Shipment__c> oldMap, Boolean isInsert)
	{
	      System.debug('>>>>>>>>>>>>>>>>>|> addAssetTransfer');
         
	      list<Asset_Transfer__c> assetTransfers = new list<Asset_Transfer__c>();    
	      
	      set<Id> assetSet = new set<Id>();
	   	  set<Id> screenSet  = new set<Id>();
	   	  set<Id> warehouseSet = new set<Id>();
	   	  
	      //Add the asset Ids to the shipments 
	      list<Shipment__c> shipments = new list<Shipment__c>();
	      
	      for(Shipment__c s : [Select Id
	                             , Screen__r.Theater__c
	                             , Destination_Warehouse__r.Account__c
	                             , Line_1_Serial_Number__c
	                             , Line_1_Product__c
	                             , Line_1_Product__r.Generic_Name__c
	                             
	                             , Line_2_Serial_Number__c
	                             , Line_2_Product__c
	                             , Line_2_Product__r.Generic_Name__c
	                             
	                             , Line_3_Serial_Number__c
	                             , Line_3_Product__c
	                             , Line_3_Product__r.Generic_Name__c
	                             
	                             , Line_4_Serial_Number__c
	                             , Line_4_Product__c
	                             , Line_4_Product__r.Generic_Name__c
	                             
	                             , Line_5_Serial_Number__c
	                             , Line_5_Product__c
	                             , Line_5_Product__r.Generic_Name__c
	                             
	                             , Screen__c
	                             , Actual_Ship_Date__c
	                             , Source_Warehouse__c
	                             , Destination_Warehouse__c
	                             , Status__c
	                             , Ship_to_Warehouse__c 
	                             
	                             , Asset_1__c
	                             , Asset_2__c
	                             , Asset_3__c
	                             , Asset_4__c
	                             , Asset_5__c
	                             
	                          from Shipment__c
	                         where Id in :newMap.keySet()])
	   {
	   	    shipments.add(s);
	   	    if(s.Asset_1__c != null)
	   	       assetSet.add(s.Asset_1__c);
	   	    if(s.Asset_1__c != null)
	   	       assetSet.add(s.Asset_2__c);
	   	    if(s.Asset_1__c != null)
	   	       assetSet.add(s.Asset_3__c);
	   	    if(s.Asset_1__c != null)
	   	       assetSet.add(s.Asset_4__c);
	   	    if(s.Asset_1__c != null)
	   	       assetSet.add(s.Asset_5__c);
	   	    screenSet.add(s.Screen__c);
	   	    warehouseSet.add(s.Destination_Warehouse__c);
	   	        
	   } 
	   
	   //Create a filter for duplicate Asset Transfer Records
	   for(Asset_Transfer__c at : [select Id 
	                                    , Asset__c
	                                    , Shipment__c
	                                    , Destination_Screen__c
	                                    , Destination_Warehouse__c
	                                 from Asset_Transfer__c
	                                where Asset__c in :assetSet
	                                  and Shipment__c in :newMap.keySet()
	                                  and(Destination_Screen__c in :screenSet 
	                                     or Destination_Warehouse__c in :warehouseSet)])
	   {
	      if(at.Destination_Screen__c != null)
	         existingTransferMap.put(at.Shipment__c + '-' + at.Asset__c +'-' + at.Destination_Screen__c,at);
	      if(at.Destination_Warehouse__c != null)
	         existingTransferMap.put(at.Shipment__c + '-'+ at.Asset__c +'-' + at.Destination_Warehouse__c,at);
	   }
	   
	   for(Shipment__c s : shipments)
	   {  
	   	  System.debug('>>>>>>>>>>>>>>>>>|> Shipment__c>> '+newMap.get(s.Id).Status__c);
         
	   	  if( newMap.get(s.Id).Status__c == 'Shipped')
	   	  {
	     	if(newMap.get(s.Id).Asset_1__c != null && existingTransferMap.get(s.Id + '-' + newMap.get(s.Id).Asset_1__c +'-' + s.Screen__c) == null)
	            assetTransfers.add(createAssetTransferObject(newMap.get(s.Id)
	                                                        ,s.Line_1_Product__r.Generic_Name__c+' Install'
	                                                        ,newMap.get(s.Id).Asset_1__c));
	            
	        if(newMap.get(s.Id).Asset_2__c != null  && existingTransferMap.get(s.Id + '-' + newMap.get(s.Id).Asset_2__c +'-' + s.Screen__c) == null)
	            assetTransfers.add(createAssetTransferObject(newMap.get(s.Id)
	                                                        ,s.Line_2_Product__r.Generic_Name__c+' Install'
	                                                        ,newMap.get(s.Id).Asset_2__c));
	            
	        if(newMap.get(s.Id).Asset_3__c != null && existingTransferMap.get(s.Id + '-' + newMap.get(s.Id).Asset_3__c +'-' + s.Screen__c) == null)
	            assetTransfers.add(createAssetTransferObject(newMap.get(s.Id)
	                                                        ,s.Line_3_Product__r.Generic_Name__c+' Install'
	                                                        ,newMap.get(s.Id).Asset_3__c));
	            
	        if( newMap.get(s.Id).Asset_4__c != null && existingTransferMap.get(s.Id + '-' + newMap.get(s.Id).Asset_4__c +'-' + s.Screen__c) == null)
	            assetTransfers.add(createAssetTransferObject(newMap.get(s.Id)
	                                                        ,s.Line_4_Product__r.Generic_Name__c+' Install'
	                                                        ,newMap.get(s.Id).Asset_4__c));
	            
	        if( newMap.get(s.Id).Asset_5__c != null && existingTransferMap.get(s.Id + '-' + newMap.get(s.Id).Asset_5__c +'-' + s.Screen__c) == null)
	            assetTransfers.add(createAssetTransferObject(newMap.get(s.Id)
	                                                        ,s.Line_5_Product__r.Generic_Name__c+' Install'
	                                                        ,newMap.get(s.Id).Asset_5__c));
	   	  }     
	     
	     }
	     
	     if(assetTransfers.size() > 0 )
	     {
	        list<Asset_Transfer__c> assetAdds = new list<Asset_Transfer__c>();    
	        for( Asset_Transfer__c a : assetTransfers)
	        {
	        	if(a != null)
	        	  assetAdds.add(a);
	        }
	        if(assetAdds.size() > 0)
	          insert assetAdds;
	     }
		
	}
	
	private Asset_Transfer__c createAssetTransferObject( Shipment__c s, String name, Id assetId)
	{
		   System.debug('*******************************************************');
		   Asset_Transfer__c at;
		   Id installRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Install').getRecordTypeId();
	       Id WareshouseRecType = Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Warehouse Transfer').getRecordTypeId();
		   
		   Date d;
      	   if(s.Actual_Ship_Date__c != null)
      	       d = Date.newInstance(s.Actual_Ship_Date__c.year()
                                   ,s.Actual_Ship_Date__c.month()
                                   ,s.Actual_Ship_Date__c.day() );
		   
		   if(!s.Ship_to_Warehouse__c 
		      && existingTransferMap.get(s.Id + '-' + assetId +'-' + s.Screen__c) == null)//check for duplicates 
	       {
	          	  at =  new Asset_Transfer__c(recordTypeId = installRecType
	                                         ,Transfer_Begin_Date__c = d
	                                         ,Source_Warehouse__c = s.Source_Warehouse__c
	                                         ,Asset__c = assetId
	                                         ,Name = name
	                                         ,Created_via_API__c = TRUE
	                                         ,Shipment__c = s.Id
	                                         ,Destination_Screen__c = s.Screen__c
	                                         ,Destination_Warehouse__c = s.Destination_Warehouse__c);
	                
          } 
          else if(existingTransferMap.get(s.Id + '-' + assetId +'-' + s.Destination_Warehouse__c) == null) //check for duplicates 
          {
	          	  
                                               
	          	  at =  new Asset_Transfer__c(recordTypeId = WareshouseRecType
	                                         ,Transfer_Begin_Date__c = d
	                                         ,Source_Warehouse__c = s.Source_Warehouse__c
	                                         ,Asset__c = assetId
	                                         ,Name = name
	                                         ,Created_via_API__c = TRUE
	                                         ,Shipment__c = s.Id
	                                         ,Destination_Warehouse__c = s.Destination_Warehouse__c);
	                 
	       }
	       

	       
	       return at;
 
	}
*/
}