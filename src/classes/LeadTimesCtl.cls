public with sharing class LeadTimesCtl {
	
	public LeadTimesCtl()
	{
		
	}
	
	public list<Lead_Time__c> getLeadTimes()
	{
		return [Select Name
                     ,US_Domestic_Delivery_Times__c
                     ,International_Delivery_Times__c
                  from Lead_Time__c
                 order by Sort_Order__c]; 
	}
	
	public string getLastUpdated()
	{
		String lastUpdated = '';
		for(AggregateResult ar : [select max(lastModifiedDate) maxDate
                                    from Lead_Time__c])
        {        	
           DateTime dt = DateTime.valueOf(ar.get('maxDate'));
           lastUpdated = dt.format('MMMMMM dd, yyyy');
        }
        
        return lastUpdated;
	}
	
	@isTest
	static void testLeadTimes()
	{
		Double maxSortOrder = 0;
		
		Lead_Time__c lt = new Lead_Time__c(Name = 'test-1-2-3'
		                                  ,US_Domestic_Delivery_Times__c =  '1'
                                          ,International_Delivery_Times__c = '2'
                                          ,Sort_Order__c = 1);
        insert lt;
		   
		Lead_Time__c lt2 = new Lead_Time__c(Name = 'test-1-2-3'
		                                  ,US_Domestic_Delivery_Times__c =  '1'
                                          ,International_Delivery_Times__c = '2'
                                          ,Sort_Order__c = 2);
        insert lt2;
		LeadTimesCtl ctl = new LeadTimesCtl();
		ctl.getLeadTimes();
		ctl.getLastUpdated();
	}

}