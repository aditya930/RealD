public with sharing class CancelShipmentController {
    
    public CancelShipmentController(ApexPages.StandardController ctl)
    {
        
    }
    public string errorMessage{get;set;}
    public PageReference cancelShipment()
    {
        Shipment__c s =
        [Select Id, Status__c 
           from Shipment__c 
          where Id = :ApexPages.currentPage().getParameters().get('Id')];
        
        if(s.Status__c == 'Shipped')
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You cannot cancel a shipped order') );
            errorMessage = 'You cannot cancel a shipped order';
            return null;
        }

       //recall approval process
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                                                 where p.ProcessInstance.TargetObjectId =: s.Id])
        {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Shipment Canceled');
            req.setAction('Removed');
            req.setWorkitemId(workItem.Id);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
            
        }
        
        s.Status__c = 'Canceled';
        update s;
        
        list<Shipment_Line_Item__c> lineItems = new list<Shipment_Line_Item__c>();
        
        for(Shipment_Line_Item__c sli : [Select Id, Line_Status__c from Shipment_Line_Item__c where Shipment__c = :s.Id])
        {
            sli.Line_Status__c = 'Canceled';
            lineItems.add(sli);
        }
        
        if(lineItems.size() > 0)
          update lineItems;
        
 
        
        
        return new PageReference('/'+s.Id);
          
    }

}