global class Batch_ScreenAssetTransferRollUps implements Database.Batchable<SObject>{
	
	 /****************************************************************************************
	 * Name    : Batch_ScreenAssetTransferRollUps
	 * Author  : Nathan Shinn
	 * Date    : 07-29-2011
	 * Purpose : 1.	Active Date:  Populate Screen.Active_Date__c with
	 *              Oldest Transfer_End_Date__c where screen is Destination_Screen__c
	 *           
	 *           2.	Inactive Date:  Populate Screen.Inactive_Date__c with:
	 *              Newest Transfer_Begin_Date__c where screen is Source_Screen__c 
	 *              IF RealD_3D_Installed__c = "FALSE" ELSE NULL
	 *           
	 *           3.	Number of Asset Transfers: Populate Screen.Number_of_Asset_Transfers__c
	 *              Count all asset Transfers where screen is Destination_Screen__c
	 *
	 *           4. Number of Removal Asset Transfers: Populate Screen.Number_of_Removal_Asset_Transfers__c
     *              Count all asset Transfers where screen is Source_Screen__c
     *
	 *
	 *            
	 *           Schedule updates hourly
	 *
	 * ========================
	 * = MODIFICATION HISTORY = 
	 * ========================
	 * DATE        AUTHOR               CHANGE
	 * ----        ------               ------
	 * 07-29-2011  Nathan Shinn         Created
	 * 09-26-2011  Nathan Shinn			Updated to only Change records whos summary values have changed
	 * 09-27-2011  Nathan Shinn			Updated to add count of assets per screen
	 *
	 *****************************************************************************************/
     Double failedUpdates{get; set;}//number of failed DML operations
      
     global Batch_ScreenAssetTransferRollUps()
     {              
     }
      
     global Database.queryLocator start(Database.BatchableContext ctx)
     { 
      	return Database.getQueryLocator      
                            ([select Id
                                   , Number_of_Asset_Transfers__c
                                   , RealD_3D_Installed__c
                                   , Inactive_Date__c
                                   , Active_Date__c
                                   , Number_of_Installed_Cinema_Systems__c
                                   , Number_of_Removal_Asset_Transfers__c
                               from Screens__c
                              where isDeleted = false
                               ]);
     }
      
     global void execute(Database.BatchableContext ctx, List<Sobject> objList)
     {
       map<Id, Screens__c> screenMap = new map<Id, Screens__c>();
       
       list<Screens__c> screenUpdates = new list<Screens__c>();
	   
       map<Id,Screens__c> screenRemovalTransfersMap = new map<Id,Screens__c>();
       map<Id,Screens__c> screenATDateMap = new map<Id,Screens__c>();
       map<Id,Screens__c> screenATActiveDateMap = new map<Id,Screens__c>();
	   map<Id,Screens__c> screenCinimaSystemsCountMap = new map<Id,Screens__c>();
	   map<Id,Screens__c> screenATCountMap = new map<Id,Screens__c>();
        
        //cast the BatchableContext to the speciffic sObject list
       List<Screens__c> screens
                = (List<Screens__c>)objList;
       
       for(Screens__c s : screens)
       {
         screenMap.put(s.Id, s);
       }
       
       //Populate Screen.Number_of_Asset_Transfers__c
	   //Count all asset Transfers where screen is Destination_Screen__c
	   set<Id> screenSet = screenMap.keySet();
	   
	   for(AggregateResult ar : [select Destination_Screen__c, count(Id) ScreenCount
	                               from Asset_Transfer__c 
	                              where Destination_Screen__c in :screenSet
	                               and isDeleted = false
	                             group by Destination_Screen__c])
	   {
	   	   Screens__c scrn = new Screens__c(Id = screenMap.get((Id)ar.get('Destination_Screen__c')).Id
		                                  , Number_of_Asset_Transfers__c = screenMap.get((Id)ar.get('Destination_Screen__c')).Number_of_Asset_Transfers__c );
   	   	   scrn.Number_of_Asset_Transfers__c = Integer.valueOf(ar.get('ScreenCount'));
   	   	   
   	   	   if(scrn.Number_of_Asset_Transfers__c < 0)
   	       	 scrn.Number_of_Asset_Transfers__c = 0;
   	       
   	       screenATCountMap.put(scrn.Id,scrn);
	   }
	   
	   //Inactive Date:  Populate Screen.Inactive_Date__c with:
	   //Newest Transfer_Begin_Date__c where screen is Source_Screen__c 
	   //IF RealD_3D_Installed__c = "FALSE" ELSE NULL
	   
       for(AggregateResult ar : [select Source_Screen__c, max(Transfer_Begin_Date__c) maxDate
	                               from Asset_Transfer__c 
	                              where Source_Screen__c in :screenSet
	                                and Transfer_Begin_Date__c != null
	                                and isDeleted = false
	                             group by Source_Screen__c])
	   {
	   	   Screens__c scrn = new Screens__c(Id = screenMap.get((Id)ar.get('Source_Screen__c')).Id
		                                  , Inactive_Date__c = screenMap.get((Id)ar.get('Source_Screen__c')).Inactive_Date__c
		                                  , RealD_3D_Installed__c = screenMap.get( (Id) ar.get('Source_Screen__c') ).RealD_3D_Installed__c );
	   	   if(scrn.RealD_3D_Installed__c == false)
	   	     scrn.Inactive_Date__c = ( (Date) ar.get('maxDate'));
	   	   else
	   	     scrn.Inactive_Date__c = null;
	   	     
	   	   screenATDateMap.put(scrn.Id,scrn);
	   } 
	   
	   //Active Date:  Populate Screen.Active_Date__c with
	   //Oldest Transfer_End_Date__c where screen is Destination_Screen__c
       for(AggregateResult ar : [select Destination_Screen__c, min(Transfer_End_Date__c) minDate
	                               from Asset_Transfer__c 
	                              where Destination_Screen__c in :screenSet
	                                and Transfer_End_Date__c != null
	                                and isDeleted = false
	                             group by Destination_Screen__c])
	   {
	   	   Screens__c scrn = new Screens__c(Id = screenMap.get((Id)ar.get('Destination_Screen__c')).Id
		                                  , Active_Date__c = screenMap.get((Id)ar.get('Destination_Screen__c')).Active_Date__c );
           scrn.Active_Date__c = ((Date) ar.get('minDate'));
	   	   screenATActiveDateMap.put(scrn.Id,scrn);
           
	   } 
	   
	   //Number of Removal Asset Transfers: Populate Screen.Number_of_Removal_Asset_Transfers__c
       //Count all asset Transfers where screen is Source_Screen__c
       for(AggregateResult ar : [select Source_Screen__c, count(Id) remCount
	                               from Asset_Transfer__c 
	                              where Source_Screen__c in :screenSet
	                                and isDeleted = false
	                              group by Source_Screen__c])
	   {
	   	   Screens__c scrn = new Screens__c(Id = screenMap.get((Id)ar.get('Source_Screen__c')).Id
		                                  , Number_of_Removal_Asset_Transfers__c = screenMap.get((Id)ar.get('Source_Screen__c')).Number_of_Removal_Asset_Transfers__c );
       	   scrn.Number_of_Removal_Asset_Transfers__c = Integer.valueOf( ar.get('remCount'));
   	       if(scrn.Number_of_Removal_Asset_Transfers__c < 0)
   	      	  scrn.Number_of_Removal_Asset_Transfers__c =0;
   	      
   	       screenRemovalTransfersMap.put(scrn.Id,scrn);
           
	   } 
	   
	  //Count the Number of assets per screen 
	   for(AggregateResult ar : [select COUNT(Id) AssetTotal, Screen__c 
	                              from Asset 
	                             where Screen__c in :screenSet
	                               and Product2.Include_in_Cinema_Systems_Count__c = TRUE
	                               and isDeleted = false
	                             group by Screen__c])
	   {
		  //System.Debug('*******>>>>>>>>>>>>>>> Number of assets per screen > '+ar.get('AssetTotal')+' |||||||||||||||||||||||||||');
		  Screens__c scrn = new Screens__c(Id = screenMap.get((Id)ar.get('Screen__c')).Id
		                                 , Number_of_Installed_Cinema_Systems__c = screenMap.get((Id)ar.get('Screen__c')).Number_of_Installed_Cinema_Systems__c );
		  
		  scrn.Number_of_Installed_Cinema_Systems__c = (Integer)ar.get('AssetTotal');
			  
			  if(scrn.Number_of_Installed_Cinema_Systems__c < 0)
			  	scrn.Number_of_Installed_Cinema_Systems__c =0;
			  	
			  screenCinimaSystemsCountMap.put(scrn.Id,scrn);
		  
	   }
       
       for(Screens__c s : screens)
       {
       	  Screens__c scrn = screenMap.get(s.Id);
       	  boolean hasUpdate = false;
       	  
       	  /** Number_of_Removal_Asset_Transfers__c **/
          if( screenRemovalTransfersMap.get(s.Id) != null)
          {
          	if(s.Number_of_Removal_Asset_Transfers__c != screenRemovalTransfersMap.get(s.Id).Number_of_Removal_Asset_Transfers__c)
          	{
          	   scrn.Number_of_Removal_Asset_Transfers__c = screenRemovalTransfersMap.get(s.Id).Number_of_Removal_Asset_Transfers__c;
          	   hasUpdate=true;
          	}
          }
          else 
          {
          	if(s.Number_of_Removal_Asset_Transfers__c != null && s.Number_of_Removal_Asset_Transfers__c != 0)
          	{
	          	scrn.Number_of_Removal_Asset_Transfers__c = 0;
	          	hasUpdate=true;
          	}
          }
          
          /** Number_of_Asset_Transfers__c **/
          if( screenATCountMap.get(s.Id) != null)
          {
          	if(Integer.ValueOf(s.Number_of_Asset_Transfers__c) != Integer.ValueOf(screenATCountMap.get(s.Id).Number_of_Asset_Transfers__c))
          	{
          	   scrn.Number_of_Asset_Transfers__c = screenATCountMap.get(s.Id).Number_of_Asset_Transfers__c;
          	   hasUpdate=true;
          	}
          }
          else 
          {
          	if(s.Number_of_Asset_Transfers__c != null && s.Number_of_Asset_Transfers__c != 0)
          	{
	          	scrn.Number_of_Asset_Transfers__c = 0;
	          	hasUpdate=true;
          	}
          }
          
          
          /** Number_of_Installed_Cinema_Systems__c **/
          if( screenCinimaSystemsCountMap.get(s.Id) != null)
          {
          	if(s.Number_of_Installed_Cinema_Systems__c != screenCinimaSystemsCountMap.get(s.Id).Number_of_Installed_Cinema_Systems__c)
          	{
          	   scrn.Number_of_Installed_Cinema_Systems__c = screenCinimaSystemsCountMap.get(s.Id).Number_of_Installed_Cinema_Systems__c;
          	   hasUpdate = true;
          	}
          }
          else 
          {
          	if(scrn.Number_of_Installed_Cinema_Systems__c != null && scrn.Number_of_Installed_Cinema_Systems__c != 0)
          	{
	          	scrn.Number_of_Installed_Cinema_Systems__c = 0;
	          	hasUpdate=true;
          	}
          }
          
          /** Active_Date__c **/
          if( screenATActiveDateMap.get(s.Id) != null)
          {
          	if(s.Active_Date__c != screenATActiveDateMap.get(s.Id).Active_Date__c)
          	{
          	   scrn.Active_Date__c = screenATActiveDateMap.get(s.Id).Active_Date__c;
          	   hasUpdate=true;
          	}
          }
          else 
          {
	          if(s.Active_Date__c != null)
	          {
	          	scrn.Active_Date__c = null;
	          	hasUpdate=true;
	          }
          }
          /** RealD_3D_Installed__c = false Inactive_Date__c **/
          if( screenATDateMap.get(s.Id) != null)
          {
          	if(scrn.Inactive_Date__c != screenATDateMap.get(s.Id).Inactive_Date__c)
          	{
          	   scrn.Inactive_Date__c = screenATDateMap.get(s.Id).Inactive_Date__c;
          	   hasUpdate=true;
          	}
          }
          else
          {
          	if(scrn.Inactive_Date__c != null)
          	{
	          	scrn.Inactive_Date__c = null;
	          	hasUpdate=true;
          	}
          }
          
          
          
          /** IF THERE IS AN UPDATE ADD IT TO THE UPDATE LIST **/
          if(hasUpdate)
            screenUpdates.add(scrn);
            
       }
		
	   //Update the Screens that have changed
	   if(screenUpdates.size() > 0)
	   {	
			update screenUpdates;
	   }
	   
	   
     }
     
     global void finish(Database.BatchableContext ctx){  
     	if(failedUpdates > 0)
     	{
	     	//there were processing errors. send an email notification
	     	
     	} 
        
     }
}