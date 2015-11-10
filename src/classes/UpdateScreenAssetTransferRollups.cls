public with sharing class UpdateScreenAssetTransferRollups {
	
	public Screens__c screen{get;set;}
	
	public UpdateScreenAssetTransferRollups(apexPages.StandardController ctl)
	{
		screen = (Screens__c)ctl.getRecord();
		screen = [Select Id, name, RealD_3D_Installed__c from Screens__c where Id = :screen.Id];
	}
	
	public PageReference runUpdate()
	{
		try{
                
	       screen.Number_of_Asset_Transfers__c = 0;
	       screen.Inactive_Date__c = null;
	       screen.Active_Date__c = null;
	       screen.Number_of_Removal_Asset_Transfers__c = 0;
	      
	       update screen;
	       
	       
           //Populate Screen.Number_of_Asset_Transfers__c
	       //Count all asset Transfers where screen is Destination_Screen__c
	       for(AggregateResult ar : [select Destination_Screen__c, count(Id) ScreenCount
		                               from Asset_Transfer__c 
		                              where Destination_Screen__c  = :screen.Id
		                             group by Destination_Screen__c])
		   {
		   	   screen.Number_of_Asset_Transfers__c = Integer.valueOf(ar.get('ScreenCount'));
		   }
		   
		   //Inactive Date:  Populate Screen.Inactive_Date__c with:
		   //Newest Transfer_Begin_Date__c where screen is Source_Screen__c 
		   //IF RealD_3D_Installed__c = "FALSE" ELSE NULL
		   for(AggregateResult ar : [select Source_Screen__c, max(Transfer_Begin_Date__c) maxDate
		                               from Asset_Transfer__c 
		                              where Source_Screen__c = :screen.Id
		                                and Transfer_Begin_Date__c != null
		                             group by Source_Screen__c])
		   {
		   	   //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'screen.Name: '+ screen.Id+ ' | screen.RealD_3D_Installed__c: '+ screen.RealD_3D_Installed__c) );
		   	   //return null;
		   	   if(screen.RealD_3D_Installed__c != true )
		   	     screen.Inactive_Date__c = ( (Date) ar.get('maxDate'));
		   	   else
		   	     screen.Inactive_Date__c = null;
		   } 
		   
		   //Active Date:  Populate Screen.Active_Date__c with
		   //Oldest Transfer_End_Date__c where screen is Destination_Screen__c
	       for(AggregateResult ar : [select Destination_Screen__c, min(Transfer_End_Date__c) minDate
		                               from Asset_Transfer__c 
		                              where Destination_Screen__c = :screen.Id
		                                and Transfer_End_Date__c != null
		                             group by Destination_Screen__c])
		   {
		   	   screen.Active_Date__c = ((Date) ar.get('minDate'));
		   } 
		   
		   //Number of Removal Asset Transfers: Populate Screen.Number_of_Removal_Asset_Transfers__c
	       //Count all asset Transfers where screen is Source_Screen__c
	       for(AggregateResult ar : [select Source_Screen__c, count(Id) remCount
		                               from Asset_Transfer__c 
		                              where Source_Screen__c = :screen.Id
		                             group by Source_Screen__c])
		   {
		   	   screen.Number_of_Removal_Asset_Transfers__c = Integer.valueOf( ar.get('remCount'));
		   }
		   update screen;
	   }
	   catch(Exception e)   
	   {
	   	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
	   	   return null;
	   }
	   
	   	   
	    return new PageReference('/'+screen.Id);
		
	}

}