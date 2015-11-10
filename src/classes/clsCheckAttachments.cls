global class clsCheckAttachments
{   webservice static Boolean chkAtt(String keyReqId) 
    { 
         CA_Key_Request__c newCAKeyRequest= [SELECT ID,Status__c 
                                                    FROM CA_Key_Request__c 
                                                    WHERE ID=: keyReqId];
         
         if(newCAKeyRequest.Status__c=='Keys Ready for Download'){
             return true;
         }
         
         else {
             return false;
         } 
         
     }

     
}