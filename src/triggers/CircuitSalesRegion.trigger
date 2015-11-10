trigger CircuitSalesRegion on Circuits__c (before insert, before update) {
    
/****************************************************************************************
 * Name    : CircuitSalesRegion
 * Author  : Unknown
 * Date    : Unknown
 * Purpose : Populates the salesfreeon on the Circuit object from the Sales_Region 
 *           Object based on common Country 
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
    
    for(Circuits__c a : trigger.new)
    {
        sCountries.add(a.Country__c);
    }
    
    Map<String,String> mRegions=new Map<String,String>();
    
    for(Sales_Region__c sr : [SELECT Id
                                   , Name
                                   , SalesRegion__c
                                   , Country__c 
                                FROM Sales_Region__c 
                               WHERE Country__c IN :sCountries])
    {
        mRegions.put(sr.Country__c,sr.SalesRegion__c);
    }
    
    for(Circuits__c a : trigger.new)
    {
        a.Sales_Region__c=mRegions.get(a.Country__c);
    }
}