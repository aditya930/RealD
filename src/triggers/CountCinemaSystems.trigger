trigger CountCinemaSystems on Asset (after delete, after insert, after update) 
{
    Map<Id,Screens__c> mScreens=new Map<Id,Screens__c>();
    
    if(trigger.isUpdate || trigger.isInsert)
    {
        for(Asset a :  trigger.new)
        {
            if(a.Screen__c!=null)
                mScreens.put(a.Screen__c,new Screens__c(Id=a.Screen__c, Number_of_Installed_Cinema_Systems__c=0) );
        }
    }
    
    if(trigger.isUpdate || trigger.isDelete)
    {
        for(Asset a : trigger.old )
        {
            if(a.Screen__c!=null)
                mScreens.put(a.Screen__c,new Screens__c(Id=a.Screen__c, Number_of_Installed_Cinema_Systems__c=0) );
        }
    }
    
    List<AggregateResult> lCounts=[SELECT COUNT(Id) AssetTotal,Screen__c 
                                     FROM Asset 
                                    WHERE Screen__c IN :mScreens.keySet() 
                                      AND Product2.Include_in_Cinema_Systems_Count__c = TRUE
                                    GROUP BY Screen__c];

    for(AggregateResult ar : lCounts)
    {
        mScreens.get((Id)ar.get('Screen__c')).Number_of_Installed_Cinema_Systems__c=(Integer)ar.get('AssetTotal');
    }
    
    if(mScreens.size()>0)
    {   
        update mScreens.values();
    } 
}