/*Controller Class for DownloadCAKeys Page
Fetches the attachments related to a Key Request
Created By: Suyati Technologies */
global With Sharing Class DownloadCAKeysController {

    
    /*Specifies the list of attachments to be compressed.*/
    
    Public String zipContent {get; set;}
    
    /*Specifies the Id of current Conditional Access License Key Request record.*/

    Public String currentRecordId{get; set;}

    /*Specifies the Name of current Conditional Access License Key Request record.*/
    Public String zipFileName {get;set;}
    
    /*Constructor which holds License Key record id and its Name*/
    Public DownloadCAKeysController(){
        currentRecordId = ApexPages.currentpage().getparameters().get('recID');
        CA_Key_Request__c caKeyRequest= [SELECT Id,Name,License_End_Date__c,Circuit__r.Name FROM CA_Key_Request__c WHERE Id =:currentRecordId];
        String strEndDate = String.valueOf(caKeyRequest.License_End_Date__c);
        String strCircuitName = caKeyRequest.Circuit__r.Name;
        zipFileName = strCircuitName + '(' + strEndDate + ')';
    }


    
    /*******************************************************************************************************
    * @description Method fetch all attachments Conditional Access License Keys for a particular Conditional Access License Key Request and serialize into a wrapper.
    * @param keyRequestId Id of the current record
    * @return wrapper contains list of attachments
    */
    @RemoteAction
    Public Static List<AttachmentWrapper> getAttachments(String keyRequestId){
        List <AttachmentWrapper> lstAttachmentWrapper = new List <AttachmentWrapper>();
        List<Attachment> lstAttachments = new List<Attachment>();
        Set<Id> licenseKeyIds = new Set<Id>();
        
        for(License_Key__c key : [SELECT Id FROM License_Key__c WHERE License_Key_Request__c =: keyRequestId]){
            licenseKeyIds.add(key.Id);
        }       
        
        lstAttachments = [SELECT Id, Name, ParentId, ContentType, Body FROM Attachment WHERE ParentId IN : licenseKeyIds];
        lstAttachmentWrapper = wrapAttachments(lstAttachments);
        
        return lstAttachmentWrapper;
    }
    
    /*******************************************************************************************************
    * @description Method serialize attachments into a wrapper.
    * @param lstAttachments list of attachments of License_Key__c 
    * @return wrapper contains list of attachments
    */
    Public Static List<AttachmentWrapper> wrapAttachments(List<Attachment> lstAttachments) {

        List <AttachmentWrapper> lstAttachmentWrapper = new List <AttachmentWrapper>();
        string stringBeforeDot;
        string stringAfterDot;
        Integer count;
        Integer tempCount;
        AttachmentWrapper wrapper;
        Map <String,Integer> mapCountAttachment = new Map <String,Integer>();

        if(lstAttachments.size() > 0){
            for(Attachment att : lstAttachments) {
                wrapper = new AttachmentWrapper();
                
                if(mapCountAttachment.containsKey(att.Name)){
                    tempCount = mapCountAttachment.get(att.Name);
                    tempCount ++;
                    mapCountAttachment.put(att.Name, tempCount);
                }

                else {
                    mapCountAttachment.put(att.Name,0);
                }

                count = mapCountAttachment.get(att.Name);
                stringBeforeDot = att.Name.substringBefore('.');
                stringAfterDot = att.Name.substringAfter('.');
                if(count==0){
                    wrapper.attName = att.Name;
                }
                else{
                    wrapper.attName = stringBeforeDot + '(' + count + ').' + stringAfterDot;
                }
                
                wrapper.attEncodedBody = EncodingUtil.base64Encode(att.Body);
                lstAttachmentWrapper.add(wrapper);
                }

        }   
        return lstAttachmentWrapper;
    }

    
    /*Wrapper class which holds the attachments.*/
    
    Public Class AttachmentWrapper {
        /*Specifies the body of attachment.*/
        Public String attEncodedBody;
        /*Specifies the name of attachment.*/
        Public String attName;
    }
}