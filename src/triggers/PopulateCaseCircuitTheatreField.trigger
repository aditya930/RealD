trigger PopulateCaseCircuitTheatreField on Case (before insert, before update) {
/****************************************************************************************
 * Name    : PopulateCaseCircuitTheatreField
 * Author  : Nathan Shinn
 * Date    : 06-30-2011
 * Purpose : The goal is to populate the Circuit and/or Theatre fields (lookups) when they 
 *           are left blank using the linked records of those that are populated.  For 
 *           instance, if the screen field is populated on the case, but the theatre and 
 *           circuit are not, when the case is saved, the trigger should use the theatre (account) 
 *           and circuit from the linked screen to populate the remaining two fields.
 *
 *           IF: Theatre Name and/or Circuit is blank AND screen is NOT blank, populate Theatre and/or 
 *               Circuit with corresponding records linked to screen
 *           IF: Circuit is blank AND Theatre is NOT blank, populate Circuit with corresponding record 
 *               linked to Theatre
 *
 * ========================
 * = MODIFICATION HISTORY =
 * ========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 06-30-2011  Nathan Shinn        Created
 *
 *****************************************************************************************/
   
    map<Id, Id> screenIds = new map<Id, Id>();
    map<Id, Id> theaterIds = new map<Id, Id>();
    
    map<Id, Screens__c> screens = new map<Id, Screens__c>();
    map<Id, Account> theaters = new map<Id, Account>();
    
    //we want to manage this before insert so we will need to collect Ids and process them later
    for(Case c : Trigger.new)
    {
    	if(c.Circuit__c == null && c.AccountId != null)
    	  theaterIds.put(c.Id, c.AccountId);
    	if(c.AccountId == null && c.Screen__c != null)
    	   screenIds.put(c.Id, c.Screen__c);
    }
    
    /**
    1. capture the parent records that have the data
    2. iterate throught the parents and capture the associated attributes
    3. add the missing case values retrieved from the parent objects via mapping to the source objects
    
    **/
    //Loop through the accounts
    for(account a : [select Id, Circuit__c from Account where Id in :theaterIds.values()])
	{
		theaters.put(a.Id, a);
	}
	
	//get the screen data
	
    //Loop through the accounts 
    for(Screens__c s : [select Id, Theater__c, Theater__r.Name, Theater__r.Circuit__c from Screens__c where Id in :screenIds.values()])
	{
		screens.put(s.Id, s);
	}
	
	//update the Cases with the missing values
	for(Case c : Trigger.new)
    {
    	if(c.Circuit__c == null && c.AccountId != null)
    	  c.Circuit__c = theaters.get(c.AccountId).Circuit__c;
    	//if(c.Theater_Name__c == null && c.Screen__c != null)
    	//   c.Theater_Name__c = screens.get(c.Screen__c).Theater__r.Name;
    	if(c.AccountId == null && c.Screen__c != null && screens.get(c.Screen__c) != null)
    	   c.AccountId = screens.get(c.Screen__c).Theater__c;
    	if(c.Circuit__c == null && c.Screen__c != null)
    	   c.Circuit__c = screens.get(c.Screen__c).Theater__r.Circuit__c;
    }
    	
    
}