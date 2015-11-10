public with sharing class PackOutController{

    public PackOutController(ApexPages.StandardController ctl)
    {
    }
    public static PageReference createPackout(){
        
        try{
            
        Pack_Out__c packout = new Pack_Out__c();
        Asset a = [Select Id, Returned__c 
           from Asset where Id = :ApexPages.currentPage().getParameters().get('Id')];
        packout.Asset__c = a.ID;
        packout.Associate__c = UserInfo.getUserId();
        packout.Date__c = Date.today();
        packout.New_RMA__c = a.Returned__c;
  
        Database.insert(packout);
        
        PageReference p = Page.SerialLabel;
        p.getParameters().put('scontrolCaching', '1');
        p.getParameters().put('id', a.Id);
        
        return p;
        }
        
        catch (System.DmlException err) {
        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'This serial number has already been packed out today.  If you need to generate a new label, please print a Replacement Label instead.');
		ApexPages.addMessage(errMsg);
        return null;    
        }    
        
        //return new pageReference('/Apex/SerialLabel?scontrolCaching=1&id='+a.Id);
            
    }

}