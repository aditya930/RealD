/*
* @author Suyati technologies
* @date October 21, 2015
*
* @group License_Key__c
*
* @description trigger fires on every License_Key__c record creation
*/
Global with sharing class EncryptionWrapper {
     //Variable to send success or error maessage while executing class through detail page button
     public static string message;
     
     /*******************************************************************************************************
     * @description Method accept list of Conditional Access License Key, encrypt license key and insert it as an attachment.
     * @param licenseKeyRecords holds list of Conditional Access License Key records.
     */
     public void encryptLicenseFile( List<License_Key__c> licenseKeyRecords) {

          List<Id> assetIds = new List<Id>();
          Integer[] uuId;
          Long[] encryptionKey;
          Integer[] encryptedContent;
          String contentString;
          Blob fileBlob;
          Attachment attachment;
          List<Attachment> lstAttachments = new List<Attachment>();
          //List<Asset> lstAssets = new List<Asset>();

          for(License_Key__c key : licenseKeyRecords){
               assetIds.add(key.Asset__c);
          }

          /*for(Asset ass : [SELECT Id, Unique_ID__c, SerialNumber, Encryption_Key_01__C, Encryption_Key_02__C, Encryption_Key_03__C, Encryption_Key_04__C FROM Asset WHERE Id IN : assetIds]){
               //if(ass.Unique_ID__c != '' || ass.Unique_ID__c != null){
               if(ass.Unique_ID__c != null){
                    lstAssets.add(ass);
               }
               System.Debug('lstAssets  '+lstAssets.size());
               System.Debug('lstAssets  '+lstAssets);
               System.Debug('Unique_ID__c  '+ass.Unique_ID__c);
          }*/

          for(Asset a : [SELECT Id, Unique_ID__c, SerialNumber, Encryption_Key_01__C, Encryption_Key_02__C, Encryption_Key_03__C, Encryption_Key_04__C FROM Asset WHERE Id IN : assetIds]) {
               for(License_Key__c key : licenseKeyRecords){
                    if(key.Asset__c == a.id) {
                        if(a.Unique_ID__c == null){
                            key.addError('Cannot complete this action. Related Asset record having Unique Id field as null.');
                        }
                        else{
                            //convert the uuid to a Integer array                    
                            uuId = CryptoUtils.HexStringToCodePoint(a.Unique_ID__c);

                            //retrieve the integers generated for the asset into an array
                            encryptionKey = new Long[]{a.Encryption_Key_01__C.intValue()
                                                                 ,a.Encryption_Key_02__C.intValue()
                                                                 ,a.Encryption_Key_03__C.intValue()
                                                                 ,a.Encryption_Key_04__C.intValue()};

                            //convert key into a byte array
                            encryptedContent = CryptoUtils.CustomAESWithObfuscate(encryptionKey
                                                                 , uuId
                                                                 , key.License_Begin_Date__c
                                                                 , key.License_End_Date__c);

                            contentString = CryptoUtils.IntArrayToHexString(encryptedContent );//   //String.fromCharArray(encryptedContent);

                            //Convert into a binary array
                            fileBlob = Blob.valueOf(contentString);

                            //attach the lic file to the license Key record
                            attachment = new Attachment();
                            attachment.ParentId = key.Id;
                            String assetSub = a.SerialNumber.Substring(a.SerialNumber.length() - 5, a.SerialNumber.length());

                            //RD_SSSSS_MMDDYY.lic
                            attachment.Name = 'RD_'+ a.SerialNumber + '_' 
                                       + buildDatetimeString((key.License_Begin_Date__c)) + '_' 
                                       + buildDatetimeString((key.License_End_Date__c)) + '.lic';//<-- TBD
                            
                            attachment.Body = fileBlob;
                            lstAttachments.add(attachment);
                       }
                    }
               }
          }
          insert lstAttachments;
     }
    
     /*******************************************************************************************************
     * @description Method accept list of Conditional Access License Key and invokes send mail mathod to send attachments.
     * @param lstLicenseKeys holds list of Conditional Access License Key records.
     */
     //@future
     public static void emailEncryptedKeyFile(List<License_Key__c> lstLicenseKeys)
     {
          List<String> licenseKeyIds = new List<String>();
          for(License_Key__c key : lstLicenseKeys){
               licenseKeyIds.add(key.Id);
          }
          sendEmail(licenseKeyIds);
     }
    
    /*******************************************************************************************************
     * @description Method invoked Shipment_Completion_Asset_Update trigger fires and send attachments.
     * @param shipmentKeyId holds set of Shipment record ids.
     */
    //@future
    public static void sendEmailFromShipmentUpdate(Set<Id> shipmentKeyId)
    {
          list<String> licenseKeyIds = new list<String>();
          map<String, String> taskMp = new map<String, String>();
          list<String> licenseKeyIdsToSendEmail = new list<String>();

          for(License_Key__c l :[Select Id from License_Key__c where Shipment__c in :shipmentKeyId ] )
          {
               licenseKeyIds.add(l.Id);
          }

          for(task t : [Select Id , whatId from Task where whatId in :licenseKeyIds])
          {
               taskMp.put(t.whatId, t.Id);
          }

          for(String s : licenseKeyIds)
          {
               if(!taskMp.containsKey(s))
                    licenseKeyIdsToSendEmail.add(s);
          }
          sendEmail(licenseKeyIdsToSendEmail);
    }
    
     /*******************************************************************************************************
     * @description Method override for send mails.
     * @param licenseKeyIds holds list of License key record ids.
     */
     public static void sendEmail(List<String> licenseKeyIds){
          sendEmailManager(licenseKeyIds);
     }

     /*******************************************************************************************************
     * @description Method invoked by detail page button to send mails.
     * @param licenseKeyId holds one record id.
     */
     webservice static string sendEmail(String licenseKeyId)
     {
          List<String> licenseKeyIds = new List<String>();
          licenseKeyIds.add(licenseKeyId);

          message = '';
          sendEmailManager(licenseKeyIds);
          return message;
     }

     /*******************************************************************************************************
     * @description Common method to send mail to send mails.
     * @param licenseKeyId holds list of License key record ids.
     */
     Public static void sendEmailManager(List<String> licenseKeyIds)
     { 
          Integer loc = 0; 
          Set<Id> lkids = new Set<Id> ();
          List<String> shipmentsToUpdate = new List<String>();
          List<String> keyIds = new List<String>();
          Map<License_Key__c, Attachment> keyAttachmentmap = new Map<License_Key__c, Attachment>();
          List<License_Key__c> lstLicenseKeys = new List<License_Key__c>();
          List<id> keyIdsToSendEmail = new List<Id>();
          List<License_Key__c> licenseKeys = new List<License_Key__c>();

          for(License_Key__c key : [SELECT Id FROM License_Key__c WHERE Id IN : licenseKeyIds]){
               lkids.add(key.Id);
          }

          lstLicenseKeys = new List<License_Key__c>();
          lstLicenseKeys = isEncryptionEmailReady(lkids);

          if(lstLicenseKeys.size() == 0)
          {

               message = 'The Shipment MUST be specified.'
                        + '\nThe specified Shipment\'s Shipment Held field must be blank.'
                        + '\nThe specified Shipment\'s Status field must = “Scheduled”.'
                        + '\nThe specified Shipment\'s Scheduled Ship Date must be Today or Earlier (not a date in the future).';
          }
          else{
               for(License_Key__c key : lstLicenseKeys){
                    keyIds.add(key.Id);
               }
               try{

                    EmailTemplate template = [SELECT e.Id, e.DeveloperName, subject 
                                          FROM EmailTemplate e
                                          WHERE e.DeveloperName  = 'RealD_License_Key'];
                    Messaging.SingleEmailMessage email;
                    Messaging.SingleEmailMessage email2;
                    Messaging.EmailFileAttachment efa;
                    ConditionalAccessShipmentDefaults__c defaultsSetting = ConditionalAccessShipmentDefaults__c.getInstance();


                    for(License_Key__c key : [SELECT Id, Primary_Contact__c, Secondary_Contact__c, Shipment__c FROM License_Key__c WHERE Id IN :keyIds]){
                         if(key.Secondary_Contact__c == null && key.Primary_Contact__c == null){                  
                              message = 'Primary and secondary contact are not specified. Cannot send email.';                  
                         }
                         else{
                              keyIdsToSendEmail.add(key.Id);
                              licenseKeys.add(key);
                         }
                    }

                    if(keyIdsToSendEmail.size() > 0){

                         for(Attachment att : [Select Id, Body, Name, ParentId from Attachment where ParentId IN :keyIdsToSendEmail]){
                              for(License_Key__c key : licenseKeys){
                                   if(att.ParentId == key.Id){
                                        keyAttachmentmap.put(key, att);
                                   }    
                              }
                         }

                         //using the RealD_License_Key email template and logged as an activity under the License Key record. 
                         for( License_Key__c key : keyAttachmentmap.keySet())
                         {

                              email = new Messaging.SingleEmailMessage();
                              email.setTargetObjectId(key.Primary_Contact__c);
                              email.setTemplateId(template.Id);
                              email.setSaveAsActivity(true);
                              email.setWhatId(key.Id);
                              email.setReplyTo(defaultsSetting.ReplyToEmailAddress__c);
                              email.setOrgWideEmailAddressId(defaultsSetting.OrgWideEmailID__c);

                              efa = new Messaging.EmailFileAttachment();
                              efa.setFileName(keyAttachmentmap.get(key).Name);
                              efa.setBody(keyAttachmentmap.get(key).Body);
                              email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                              if(key.Primary_Contact__c != null)
                              {
                                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                              }

                              email2 = new Messaging.SingleEmailMessage();
                              email2.setTargetObjectId(key.Secondary_Contact__c);
                              email2.setTemplateId(template.Id);
                              email2.setSaveAsActivity(true);
                              email2.setWhatId(key.Id);
                              email2.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                              email2.setOrgWideEmailAddressId(defaultsSetting.OrgWideEmailID__c);
                              loc = 20; 
                              if(key.Secondary_Contact__c != null)
                              {
                                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email2 });
                              }
                              shipmentsToUpdate.add(key.Shipment__c);
                         }

                         //When the email is sent, update the Shipment__r.Status__c field to “Shipped” and set the Shipment__r.Actual_Ship_Date__c to NOW
                         updateShipmentStatus(shipmentsToUpdate);
                         message = 'Email sent successfully';
                    }
               }

               catch(Exception e)
               {
                    //updateShipmentStatus(lk.Shipment__c);
                    message = 'Error sending email. Contact your system administrator [ '+e + ' ] loc: ' + loc ;
               }
          }
     }

     /*******************************************************************************************************
     * @description Method accepts Licennce key Begin date or End date values to manipulate attachment name.
     * @param inDateTime holds License Key Begin Date or Enda date.
     */
     public static String buildDatetimeString(DateTime inDateTime)
     {
          Date inDate = Date.valueOf(inDateTime);
          String monthstr = '';
          integer themonth = inDate.month();
          String daystr = '';
          integer theday = inDate.day();
          integer year = inDate.year();
          string yearstr = String.ValueOf(year).Substring(2,String.ValueOf(year).length());

          if (themonth < 10)
          {
               monthstr = '0'+String.valueOf(themonth);
          }
          else
          {
               monthstr = String.valueOf(themonth);
          }    
          if (theday < 10)
          {
               daystr = '0'+String.valueOf(theday);
          }
          else
          {
               daystr = String.valueOf(theday);
          }             
          return yearstr + monthstr + daystr;
     }

     /*******************************************************************************************************
     * @description Method accepts Licennce key record ids and create new shipment and line item 
     * if there is no shipment associated with it.
     * @param licenseKeyRecordIds holds License Key record ids.
     */
     public static List<License_Key__c> isEncryptionEmailReady(Set<Id> licenseKeyRecordIds)
     {  
          /*
           This field (License_Key__c.Shipment__c) MUST be populated
             The Shipment__r. Shipment_Held__c field must = NULL
               The Shipment__r.Status__c field must = “Scheduled”
               The Shipment__r.Scheduled_Ship_Date must be Today or Earlier (not a date in the future)
          */

          List<License_Key__c> lstLicenseKeys = new List<License_Key__c>();
          List<License_Key__c> licenseKeysWithShipments = new List<License_Key__c>();
          List<License_Key__c> licensekeysToUpdate;
          Shipment__c shipment;
          Shipment_Line_Item__c lineItem;
          List<License_Key__c> lstLicenseKeysToUpdateShipment = new List<License_Key__c>();
          List<Shipment_Line_Item__c> lstLineItems = new List<Shipment_Line_Item__c>();
          Map<Id, Shipment__c> mapKeyWithShipment;
          
          //Get details from custom setting
          ConditionalAccessShipmentDefaults__c defaultsSetting = ConditionalAccessShipmentDefaults__c.getInstance();

          integer errLoc = 0;
          try {
               lstLicenseKeys = [Select Id
                                      , Shipment__c
                                      , Shipment__r.Send_License_Keys__c
                                      , Asset__r.Account.Circuit__c
                                      , Asset__r.AccountId
                                      , Primary_Contact__c
                                      , Asset__r.Account.ShippingPostalCode
                                      , Asset__r.Account.ShippingStreet
                                      , Asset__r.Account.ShippingCity
                                      , Asset__r.Account.ShippingState
                                      , Asset__r.Account.ShippingCountry
                                      , Asset__r.Screen__c
                                   from License_Key__c
                                  where Id IN : licenseKeyRecordIds];
               System.debug(':::::::: >'+lstLicenseKeys);

               errLoc = 10;
               mapKeyWithShipment = new Map<Id, Shipment__c>();
               licensekeysToUpdate = new List<License_Key__c>();
               for(License_Key__c key : lstLicenseKeys){
                    if(key.Primary_Contact__c != null){

                         System.debug(':::::::: CREATE A SHIPMENT?'); 
                         errLoc = 20;   
                         if(key.Shipment__c == null || (key.Shipment__c != null && key.Shipment__r.Send_License_Keys__c == false))
                         { 
                              //if the shipment record does not exist, create one but return false
                              if(key.Shipment__c == null)
                              {
                                
                                   System.debug(':::::::: >>>> CREATING SHIPMENT ');
                                   shipment = new Shipment__c(RecordTypeId = defaultsSetting.RecordTypeID__c
                                                   , Circuit__c = key.Asset__r.Account.Circuit__c == null ? defaultsSetting.DefaultCircuitID__c : key.Asset__r.Account.Circuit__c
                                                   , Theatre__c = key.Asset__r.AccountId
                                                   //, Screen__c = key.Asset__r.Screen__c == null ? defaultsSetting.DefaultScreenID__c : key.Asset__r.Screen__c
                                                   , Contact__c = key.Primary_Contact__c == null ?  defaultsSetting.DefaultContactID__c : key.Primary_Contact__c
                                                   //, Line_1_Product__c = defaultsSetting.productId__c
                                                   //, Quantity_1__c = 1
                                                   , Scheduled_Ship_Date__c = System.today()
                                                   , Shipping_Street__c = key.Asset__r.Account.ShippingStreet == null ? defaultsSetting.DefaultShippingStreet__c : key.Asset__r.Account.ShippingStreet
                                                   , Shipping_Service_Type__c = defaultsSetting.ShippingServiceType__c
                                                   //, Source_Warehouse__c = defaultsSetting.SourceWarehouseID__c
                                                   , Shipping_City__c = key.Asset__r.Account.ShippingCity
                                                   , Shipping_State_Province__c = key.Asset__r.Account.ShippingState
                                                   , Shipping_Postal_Code__c = key.Asset__r.Account.ShippingPostalCode
                                                   , Shipping_Country__c = key.Asset__r.Account.ShippingCountry
                                                   , ShipTo__c = 'Theater'
                                                   , Status__c = 'Pending'
                                                   , Shipment_Type__c = defaultsSetting.ShipmentType__c);
                                   mapKeyWithShipment.put(key.Id, shipment);
                                   licensekeysToUpdate.add(key);
                              }
                         }
                         else{
                              //List of license keys which already have shipments
                              licenseKeysWithShipments.add(key);
                         }
                    }
               }
               if(mapKeyWithShipment.Values().size() > 0){
                    insert mapKeyWithShipment.Values();

                    lstLicenseKeysToUpdateShipment = new List<License_Key__c>();
                    for(Id keyId : mapKeyWithShipment.keySet()){
                         for(License_Key__c keyref : licensekeysToUpdate){
                              if(keyId == keyref.Id){
                                   keyref.Shipment__c = mapKeyWithShipment.get(keyId).id;
                                   lstLicenseKeysToUpdateShipment.add(keyref);

                                   System.debug(':::::::: >>>> CREATING LINE ITEMS ');
                                   lineItem = new Shipment_Line_Item__c(Shipment__c = mapKeyWithShipment.get(keyId).id
                                                                , SourceWarehouse__c = defaultsSetting.SourceWarehouseID__c
                                                                , Screen__c = keyref.Asset__r.Screen__c == null ? defaultsSetting.DefaultScreenID__c : keyref.Asset__r.Screen__c
                                                                , Quantity__c = 1
                                                                , Product__c = defaultsSetting.productId__c);
                                   lstLineItems.add(lineItem);
                              }
                         }
                    }
                    update lstLicenseKeysToUpdateShipment;
                    insert lstLineItems;

                    ScheduleShipmentController.scheduleStaticShipment(mapKeyWithShipment.Values());
               }
          }
          catch(Exception e) {
               System.debug('::::::ConditionalAccessShipmentDefaults__c:::::::'+ConditionalAccessShipmentDefaults__c.getInstance());
          }
          return licenseKeysWithShipments;
     }

     /*******************************************************************************************************
     * @description Method accepts shiments and update their status to Shipped
     * @param shipmentIds holds Shipment record ids.
     */
     @future
     static void updateShipmentStatus(List<String> shipmentIds)
     {
          //Get details from custom setting
          ConditionalAccessShipmentDefaults__c defaultsSetting = ConditionalAccessShipmentDefaults__c.getInstance();

          list<Shipment_Line_Item__c> sliList = new list<Shipment_Line_Item__c>();
          for(Shipment_Line_Item__c sli : [Select Id, Product__c, Line_Status__c from Shipment_Line_Item__c where Shipment__c IN :shipmentIds])
          {
               System.Debug('>>>>>>>>>>>> LINE ITEMS TO UPDATE' + sli);
               System.Debug('>>>>>>>>>>>> Custom Setting Product Id: '+defaultsSetting.productId__c);
               if(sli.Product__c == defaultsSetting.productId__c)
               {
                    System.Debug('>>>>>>>>>>>> SETTINT IT TO SHIPPED!!');
                    sli.Line_Status__c = 'Shipped';
                    sliList.add(sli);
               }
          }     
          if(sliList.size() > 0)
          update sliList;
     }
}