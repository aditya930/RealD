trigger UpdateParentCircuits on Account (after update) 
{	
	Set <String> sParentIds=new Set<String>();
	Map<String,Circuits__c> mCircuitsToUpdate=new Map<String,Circuits__c>();
	Circuits__c pC=null;

	for(Account a: trigger.new)
	{
		if(a.Circuit__c!=null) 
			sParentIds.add(a.Circuit__c);
	}
	
	System.debug('parent Ids set: '+sParentIds);
	
	if(sParentIds.size()>0)
	{
		List<AggregateResult> lTotal=[SELECT Circuit__c,SUM(Auditoriums_with_RealD_Installed__c) RealDTotal FROM Account WHERE Circuit__c in :sParentIds  GROUP BY Circuit__c ];
		
		for(AggregateResult ar : lTotal)
		{
			pC=new Circuits__c(Id=(String)ar.get('Circuit__c'),Auditoriums_with_RealD_Installed__c=(Decimal)ar.get('RealDTotal'));
			mCircuitsToUpdate.put((String)ar.get('Circuit__c'),pC);
		}
		
		System.debug('parent to update: '+mCircuitsToUpdate);
		
		if(mCircuitsToUpdate.size()>0)
			update mCircuitsToUpdate.values();
	}
}