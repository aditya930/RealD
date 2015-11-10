trigger AccountSalesRegion on Account (before insert, before update) 
{
/****************************************************************************************
 * Name    : AccountSalesRegion
 * Author  : Unknown
 * Date    : Unknown
 * Purpose : adds sales region from Sales_Region__C table to the account based on common country 
 *
 * ========================
 * = MODIFICATION HISTORY =
 * ========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 09-04-2011  Nathan Shinn         Review, reformat, Remove redundant list, and Add comment header
 *
 *****************************************************************************************/
    Set <String> sCountries=new Set<String>();  
    
    for(Account a : trigger.new)
    {
        sCountries.add(a.BillingCountry);
    }
    
    Map<String,String> mRegions=new Map<String,String>();
    
    for(Sales_Region__c sr : [SELECT Id
                                    ,Name
                                    ,SalesRegion__c
                                    ,Country__c 
                                FROM Sales_Region__c 
                               WHERE Country__c IN :sCountries])
    {
        mRegions.put(sr.Country__c,sr.SalesRegion__c);
    }
    
    for(Account a : trigger.new)
    {
        a.SalesRegion__c=mRegions.get(a.BillingCountry);
    }
}