/*
* @author Suyati technologies
* @date October 21, 2015
*
* @group License_Key__c
*
* @description trigger fires on every License_Key__c record creation
*/
trigger EncryptLicenseKey on License_Key__c (after insert) {

     EncryptionWrapper wrap = new EncryptionWrapper();
     //Calls method to encrypt lisence key and insert as an attachment
     wrap.encryptLicenseFile(trigger.new);

     List<License_Key__c> lstLicenseKeys = new List<License_Key__c>();
     //Validating the lecense keys before sending it to contacts
     lstLicenseKeys = EncryptionWrapper.isEncryptionEmailReady(trigger.newMap.keySet());

     //Invoke method to send emails to contacts
     if( lstLicenseKeys.size() > 0){
          EncryptionWrapper.emailEncryptedKeyFile(lstLicenseKeys);
     }
     /*else 
     if(trigger.new[0].Primary_Contact__c != NULL)
     trigger.new[0].addError('The Shipment MUST be specified.'
                          +'\nThe specified Shipment\'s Shipment Held field must be blank.'
                          +'\nThe specified Shipment\'s Status field must = “Scheduled”.'
                          +'\nThe specified Shipment\'s Scheduled Ship Date must be Today or Earlier (not a date in the future).');*/
}