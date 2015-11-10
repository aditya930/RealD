/*
* @author Suyati technologies
* @date October 21, 2015
*
* @group Shipment__c
*
* @description trigger fires on every License_Key__c record creation
*/
public with sharing class ScheduleShipmentController {
    
     public ScheduleShipmentController(ApexPages.StandardController ctl)
     {
        
     }

     public string errorMessage{get;set;}

     /*******************************************************************************************************
     * @description Method get current record id and schedule it for approval.
     * @return page reference to current page
     */
     public PageReference scheduleShipment()
     {
          errorMessage = scheduleStaticShipment(ApexPages.currentPage().getParameters().get('Id'));
          if(errorMessage != null)
          {
               return null;
          }
          return new PageReference('/'+ApexPages.currentPage().getParameters().get('Id'));
     }

     /*******************************************************************************************************
     * @description Method get Shipment Id and schedule it for approval.
     * @return success or error message to the user
     */
     public static string scheduleStaticShipment(Id ShipmentId)
     {
          List<Shipment__c> lstShipments = [SELECT Id, Status__c FROM Shipment__c WHERE Id =: ShipmentId];
          return scheduleStaticShipmentManager(lstShipments, true);  
     }

     /*******************************************************************************************************
     * @description Method get list of shipment records and schedule it for approval.
     */
     public static void scheduleStaticShipment(List<Shipment__c> shipments)
     {
          scheduleStaticShipmentManager(shipments, false); 
     }

     /*******************************************************************************************************
     * @description Method get list of shipment records, flag and schedule it for approval.
     * @param shipments holds list of shipment records
     * @param isCalledFromPage to check whether method is called from page or trigger
     */
     public static string scheduleStaticShipmentManager(List<Shipment__c> shipments, boolean isCalledFromPage)
     {
          List<Id> shipmentIds = new List<Id>();
          List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();
          List<Shipment_Line_Item__c> lineItemsToUpdate = new List<Shipment_Line_Item__c>();
          List<Shipment_Line_Item__c> lineItems = new List<Shipment_Line_Item__c>();

          for(Shipment__c shipment : shipments){
               shipmentIds.add(shipment.Id);
          }

          lineItemsToUpdate = [SELECT Id, LineSummary__c, Line_Status__c,Shipment__c FROM Shipment_Line_Item__c WHERE Shipment__c IN :shipmentIds];

          for(Shipment__c s : shipments)
          {
               if(s.Status__c != 'Pending'){
                    if(isCalledFromPage == true) {
                         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You can only Schedule a Pending Shipment') );
                         return 'You can only Schedule a Pending Shipment';
                    }
               }
               else{
                    s.Status__c = 'Finance Review';
                    for(Shipment_Line_Item__c lineitem : lineItemsToUpdate){
                         
                         if(s.Id == lineitem.Shipment__c){
                              lineitem.Line_Status__c = 'Scheduled';
                              lineItems.add(lineitem);

                              if(s.LineProducts__c == null)
                                   s.LineProducts__c = '\n'+lineitem.LineSummary__c;
                              else
                                   s.LineProducts__c += '\n'+lineitem.LineSummary__c;
                         }                         
                    }
                    if(s.LineProducts__c != '' || s.LineProducts__c != null){
                         s.LineProducts__c = 'Product | Product Code | Qty'+s.LineProducts__c;                              
                    }
                    shipmentsToUpdate.add(s);
               }
          }
          if(lineItems.size() > 0)
          {
               update lineItems;         
          }
          //update the shipment
          update shipmentsToUpdate;
          
          if(shipmentsToUpdate.size() > 0){
               List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
               Approval.ProcessSubmitRequest req1;
               for (Shipment__c shipment : shipmentsToUpdate) {
                    req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval ');
                    req1.setObjectId(shipment.Id);
                    requests.add(req1);
               }

               Approval.ProcessResult[] processResults = null;
               try {
                    processResults = Approval.process(requests, true);
               }catch (System.DmlException e) {
                    System.debug('Exception Is ' + e.getMessage());
               }
          }
          return null;
     }
}