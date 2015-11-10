public with sharing class CreateTIFShipmentObjects {
/****************************************************************************************
 * Name    : CreateTIFShipmentObjects
 * Author  : Nathan Shinn
 * Date    : 07-06-2011
 * Purpose : The goal of this is to create a custom button on the Theatre Information Form, (TIF) 
 *           that, when clicked, creates a new shipment record.   
 *
 **========================
 * = MODIFICATION HISTORY =
 **========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 07-06-2011  Nathan Shinn        Created
 * 12-12-2011  Eric Nelson         Moved Circuit/Theatre/Screen Creation/Updates to separate Class
 * 11-09-2012  Nathan Shinn		   Removed legacy Shipment fields
 *
 *****************************************************************************************/

   public TIF__c tif{get;set;}
   Map<String, String> recordTypeNames{get;set;}
   Map<String, Id>RecordTypeMap{get;set;}
   public CreateTIFShipmentObjects(ApexPages.StandardController ctlr)
   {
   	  recordTypeNames = new Map<String, String>();
   	  RecordTypeMap =  new Map<String, Id>();
   	  tif = (TIF__c)ctlr.getRecord();
   	  if(tif != null)
   	    tif = [Select Exhibitor_Owner__c 
   	                 , t.Update_Theatre__c
   	                 , t.Update_Screen__c
   	                 , t.Update_Circuit__c
   	                 , t.Theatre__c
   	                 , t.Theatre_Name__c
   	                 , t.Theater_Email__c
   	                 , t.Shipping_Zip_Postal_Code__c
   	                 , t.Shipping_Street_1__c
   	                 , t.Shipping_State_Province__c
   	                 , t.Shipping_Country__c
   	                 , t.Shipping_City__c
   	                 , t.Screen__c
   	                 , t.Screen_Width__c
   	                 , t.Screen_Height__c
   	                 , t.Scope_2_39_Picture_Width__c
   	                 , t.Scope_2_39_Picture_Height__c
   	                 , t.Request_Date__c
   	                 , t.Record_Completed__c
   	                 , t.Projection_Throw_Distance__c
   	                 , t.Product__c
   	                 , t.Phone__c
   	                 , t.Number_of_Seats__c
   	                 , t.Name
   	                 , t.Id
   	                 , t.Form_Status__c
   	                 , t.Flat_1_85_Picture_Width__c
   	                 , t.Flat_1_85_Picture_Height__c
   	                 , t.Digital_Projector_Make_Model__c
   	                 , t.Contact_Name__c
   	                 , t.Comments__c
   	                 , t.Circuit__c
   	                 , t.Billing_Zip_Postal_Code__c
   	                 , t.Billing_Street_1__c
   	                 , t.Billing_State_Province__c
   	                 , t.Billing_Country__c
   	                 , t.Billing_City__c
   	                 , t.Auditorium_Number__c 
   	                 , t.Contact__c
   	             From TIF__c t 
   	            where Id = :tif.Id];
   	            
   	    
   	   // for(RecordTYpe rt : [Select Id, Name from RecordType])
	//	    RecordTypeMap.put(rt.Name, rt.Id);
   }
   
   public PageReference run()
   {
   	  if(tif.Product__c == null || tif.Product__c == 'Unknown')
   	  {
   	  	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'A product must be selected in order to Create a Shipment') );
   	  	  return null;
   	  }
   	  
   	  if(tif.Form_Status__c != 'Reviewed')
   	  {
   	  	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Orders must be set to Reviewed before they can be converted to shipments') );
   	  	  return null;
   	  }
   	  
   	  if(tif.Circuit__c == null)
   	  {
   	  	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Orders must be linked to a Circuit before they can be converted to shipments') );
   	  	  return null;
   	  }
   	  
   	  if(tif.Theatre__c == null)
   	  {
   	  	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Orders must be linked to a Theatre before they can be converted to shipments') );
   	  	  return null;
   	  }
   	  
   	  if(tif.Screen__c == null)
   	  {
   	  	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Orders must be linked to a Screen before they can be converted to shipments') );
   	  	  return null;
   	  }
      
      Shipment__c sh = new Shipment__c();
      
      Id productId = null;
      
      /*
      for(Product2 p : [select Id from Product2 where Generic_Name__c = :tif.Product__c and Default_Product__c = true])
      {
        sh.CinemaSystem__c = p.Id;
        //sh.Line_1_Product__c = p.Id;
      }*/
      //sh.RecordTypeId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get(Product_Shipment_RecordType_Map__c.getInstance(tif.product__c).RecordType_Name__c).getRecordTypeId();
      sh.Circuit__c		=	tif.Circuit__c	;
	  sh.Delivery_Due_Date__c =	tif.Request_Date__c	;
	  //sh.Projector__c	= tif.Digital_Projector_Make_Model__c	;
	  sh.Shipping_Street__c	=	tif.Shipping_Street_1__c	;
	  sh.Shipping_City__c		=	tif.Shipping_City__c	;
	  sh.Shipping_State_Province__c	=	tif.Shipping_State_Province__c	;
	  sh.Shipping_Postal_Code__c		=	tif.Shipping_Zip_Postal_Code__c	;
	  sh.Shipping_Country__c		=	tif.Shipping_Country__c	;
	  sh.Theatre__c	=	tif.Theatre__c	;
      //sh.Cinema_Order__c  = tif.Id; 
      sh.Screen__c = tif.Screen__c;
      sh.Contact__c = tif.Contact__c;
     
      insert sh;

      tif.Form_Status__c = 'Converted to Shipment';
      update tif;
      
   	  return new PageReference('/'+sh.Id);
   }
}