public with sharing class AssetTriggerHandler {
	
	public static boolean firstRun = true;
	
	public void OnAfterUpdate(map<Id, Asset> oldMap, map<Id,Asset> newMap)
	{
        //UpdateAssetComponentMaterialFinishedProduct(newMap.values());
        list<Asset> assetList = new list<Asset>();
        for(Asset a : newMap.values())
        {
        	if(a.Encryption_Key_01__c != oldMap.get(a.Id).Encryption_Key_01__c
			  || a.Encryption_Key_02__c != oldMap.get(a.Id).Encryption_Key_02__c
			  || a.Encryption_Key_03__c != oldMap.get(a.Id).Encryption_Key_03__c
			  || a.Encryption_Key_04__c != oldMap.get(a.Id).Encryption_Key_04__c
			  || a.Unique_ID__c != oldMap.get(a.Id).Unique_ID__c)
			{
				assetList.add(a);
			}
        }
        
        if(assetList.size() > 0)
        	backupUpdatedOrDeletedAssets(assetList);
    }
    
    public void OnAfterInsert(list<Asset> newMap)
	{
        UpdateAssetComponentMaterialFinishedProduct(newMap);
    }
    
    public void OnBeforeUpdate(map<Id, Asset> oldMap, map<Id,Asset> newMap)
	{
        
        validateDuplicateAssets(newMap.values());
    }
    
    public void OnBeforeInsert(list<Asset> newList)
	{
        
        validateDuplicateAssets(newList);
    }
    
    public void OnBeforeDelete(list<Asset> oldList)
	{
        
        preventDeleteUniqueId(oldList);
        backupUpdatedOrDeletedAssets(oldList);
    }
    
    public void UpdateAssetComponentMaterialFinishedProduct(list<asset> newAssets)
    {
    	//get a distinct set of Component_Material__c to asset mappings
		if (firstRun) 
		{
		    firstRun = false;//prevent recursive processing
		    list<String> assetIds = new list<String>();
		    map<Id, Id> assetComponentMaterialMap = new map<Id, Id>();
			for(Asset a : newAssets)
			{
				if(a.BuildComponent1__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent1__c, a.Id);
				if(a.BuildComponent2__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent2__c, a.Id);
				if(a.BuildComponent3__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent3__c, a.Id);
				if(a.BuildComponent4__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent4__c, a.Id);
				if(a.BuildComponent5__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent5__c, a.Id);
				if(a.BuildComponent6__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent6__c, a.Id);
		        if(a.BuildComponent7__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent7__c, a.Id);
		        if(a.BuildComponent8__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent8__c, a.Id);               
				if(a.BuildComponent9__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent9__c, a.Id);
				if(a.BuildComponent10__c != null)
		           assetComponentMaterialMap.put(a.BuildComponent10__c, a.Id);
		           
		        assetIds.add(a.Id);
			
			}
			
			//loop through the distinct map and construct a list for update
			list< Component_Material__c> compMaterialList = new list< Component_Material__c>();
			for(Id i : assetComponentMaterialMap.keyset())
			{
				compMaterialList.add(new Component_Material__c(id = i, 
				                                               Finished_Product__c = assetComponentMaterialMap.get(i))); 
			}
			
			if(compMaterialList.size() > 0)
			   update compMaterialList;
		    
		    nullAssetBuildComponents(assetIds);
        }
        else {
		    System.debug('Already ran!');
		    return;
		}
	}
	
	@future
	public static void nullAssetBuildComponents(list<String> AssetIds)
	{
		
		list<Asset> updateAssets = new list<Asset>();
		firstRun = false;//prevent recursive processing
		for(string s : assetIds)
		{
			Asset a = new Asset(id = s);
			a.BuildComponent1__c = null;
	        a.BuildComponent2__c = null;
	        a.BuildComponent3__c = null;
	        a.BuildComponent4__c = null;
	        a.BuildComponent5__c = null;
	        a.BuildComponent6__c = null;
	        a.BuildComponent7__c = null;
	        a.BuildComponent8__c = null;
	        a.BuildComponent9__c = null;
	        a.BuildComponent10__c = null;
	        
	        updateAssets.add(a);
		}
		try{
		if(updateAssets.size() > 0)
		   Database.update(updateAssets, false);
		}
		catch(Exception e){}
	}
	
	public static void validateDuplicateAssets(list<Asset> assets)
	{
		/*
		 * 1.       Prevent Duplicate Asset Records from being created.
					GOAL: Prevent users from creating new asset records or editing existing asset records to create a duplicate of an existing asset record. Asset records that contain “Unknown” or “Missed in the Serial Number field should be exempt from this rule
					a.       When an asset record is created or updated WHERE
                             i.      Asset Name Matches Existing Asset AND Serial Number does not contain “Unknown”, “Missed”
					OR
					         ii.      Asset Serial Number & Product Matches Existing Asset AND Serial Number does not contain “Unknown”, “Missed”, “”
					b.      ERROR: “Cannot complete this action. A record for this asset already exists. Search for the asset name or serial number to locate the existing asset record.”
		 */
		 
		 set<String> AssetNames = new set<String>();
		 set<String> AssetSerial = new set<String>();
		 set<String> AssetProduct = new set<String>();
		 set<Id> assetIds = new set<Id>();
		 map<string, Asset> serialProductMap = new map<String, Asset>();
		 map<string, Asset> assetNameMap = new map<String, Asset>();
		 string assetNameLike = '';
		 Integer cnt1 = 1;
		 for(Asset a : assets)
		 {
		 	AssetNames.add(a.Name);
		 	if(cnt1 == 1)
		 		assetNameLike += ' Name like \''+a.Name+'\' ';
		    else
		 		assetNameLike += ' or Name like \''+a.Name+'\' ';
		    cnt1++;
		 	AssetSerial.add(a.SerialNumber);
		 	AssetProduct.add(a.Product__c);
		 	if(a.Id != null) assetIds.add(a.Id);
		 }
		 
		 string sqlStr = 'Select Id, Name, SerialNumber, Product2ID from Asset where (NOT Id in :assetIds) ' ;
		 if(assetNameLike.length() > 3)
		 	sqlStr += ' and ('+assetNameLike+')';
		 System.debug('::::::sqlStr 1> '+sqlStr);
		 for(Asset a :  (List<Asset>)Database.query(sqlStr))
		 {
		 	if(!a.SerialNumber.containsIgnoreCase('Unknown') && !a.SerialNumber.containsIgnoreCase('Missed'))
		 	    assetNameMap.put(a.Name.toUpperCase(), a);
		 }
		
		 String snLikeOr = '';
		 Integer cnt = 1;
		 for(String s : AssetSerial)
		 {
		 	if(cnt == 1)
		 		snLikeOr += ' SerialNumber like \''+s+ '\' ' ;
		 	else
		 		snLikeOr +=  ' or SerialNumber like \''+s+ '\' ' ;
		 		
		    cnt ++;
		 }
		 sqlStr = 'Select Id, SerialNumber, Name , Product2Id '+
		                  ' from Asset '+
		                 '  where  Product__c in :AssetProduct and (NOT Id in :assetIds) ';
         if(snLikeOr.length() > 3)
         	sqlStr += ' and ('+snLikeOr+')';
         
		 System.debug('::::::sqlStr 2> '+sqlStr);	
		 for(Asset a : (List<Asset>)Database.query(sqlStr))
		 {
		 	if(a.SerialNumber != null && !a.SerialNumber.containsIgnoreCase('Unknown') && !a.SerialNumber.containsIgnoreCase('Missed'))
		 	   serialProductMap.put(a.SerialNumber.toUpperCase()+'-'+a.Product2Id, a);
		 }
		 
		 for(Asset a : assets)
		 {
		 	System.Debug('::::::::START DUP CHECK::::::::::' + a);
		 	if(a.SerialNumber != null && !a.SerialNumber.containsIgnoreCase('Unknown') && !a.SerialNumber.containsIgnoreCase('Missed'))
		 	{
		 		if(assetNameMap.containsKey(a.Name.toUpperCase()) || serialProductMap.containsKey(a.SerialNumber.toUpperCase()+'-'+a.Product2Id))
		 		{
		 		   a.addError('Cannot complete this action. A record for this asset already exists. Search for the asset name or serial number to locate the existing asset record.');
		 		   System.Debug('::::::::FOUND A DUPE!!!::::::::::');
		 		}
		 	}
		 	System.Debug('::::::::DONE DUP CHECK::::::::::');
		 	   
		 
		 }
		 
	}
	
	void preventDeleteUniqueId(list<Asset> assets)
	{
		/*
		
		 Prevent Deletion of Asset Records that Contain a Unique ID
		 GOAL: Prevent Asset Records from being deleted when Unique_ID__c is populated
			a.       When an asset record is Deleted WHERE
					                                                               i.      Unique_ID__c != NULL
			b.      Error: “This asset record cannot be deleted because it contains information necessary to generate a license key”
		 */
		 
		 for(Asset a : assets)
		 {
		 	if(a.Unique_ID__c != null)
		 	  a.addError('This asset record cannot be deleted because it contains information necessary to generate a license key');
		 }
	}
	
	void backupUpdatedOrDeletedAssets(list<Asset> assets)
	{
		/*
			  3.Create Backup records when changes are made to encryption fields or unique ID
				GOAL: Create a new record in a separate table with the Unique ID and Encryption Keys every time a change is made to these fields on an asset.  
				This will provide a backup of this data should it ever be deleted or modified.
				a. When an asset record is updated WHERE
				    i.      Encryption_Key_01__c is changed
						OR
				    ii.      Encryption_Key_02__c is changed
						OR
				    iii.      Encryption_Key_03__c is changed
						OR
				    iv.      Encryption_Key_04__c is changed
						OR
		            v.      Unique_ID__c is changed
		       	b. Create a new record in object CA_Encryption_Backup__c
                   i.    CA_Encryption_Backup__c. Name = Asset.SerialNumber&&Trigger Date (MMDDYY)
                   ii.   CA_Encryption_Backup__c. Encryption_Key_01__c = Asset.Encryption_Key_01__c
                   iii.  CA_Encryption_Backup__c. Encryption_Key_02__c = Asset.Encryption_Key_02__c
                   iv.   CA_Encryption_Backup__c. Encryption_Key_03__c = Asset.Encryption_Key_03__c
                   v.    CA_Encryption_Backup__c. Encryption_Key_04__c = Asset.Encryption_Key_04__c
                   vi.   CA_Encryption_Backup__c. Unique_ID __c = Asset.Unique_ID__c
                   vii.  CA_Encryption_Backup__c. Serial_Number__c = Asset.SerialNumber
                   viii. CA_Encryption_Backup__c. Parent_Record_ID__c = Asset.ID
		*/
		list<CA_Encryption_Backup__c> caEncryptionBackupList = new list<CA_Encryption_Backup__c>();
		DateTime d = System.Now();
		String dateStamp = d.format('mmddyy');
		for(Asset a : assets)
		{
			 caEncryptionBackupList.add(new CA_Encryption_Backup__c( name = a.SerialNumber + '_'+dateStamp
																	,Encryption_Key_01__c = a.Encryption_Key_01__c
																	,Encryption_Key_02__c = a.Encryption_Key_02__c
																	,Encryption_Key_03__c = a.Encryption_Key_03__c
																	,Encryption_Key_04__c = a.Encryption_Key_04__c
																	,Unique_ID__c = a.Unique_ID__c
																	,Serial_Number__c = a.SerialNumber
																	,Parent_Record_ID__c = a.Id));
		}
		if(caEncryptionBackupList.size() > 0)
		  insert caEncryptionBackupList;
		
	}

}