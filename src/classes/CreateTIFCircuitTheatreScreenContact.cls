public with sharing class CreateTIFCircuitTheatreScreenContact {
/****************************************************************************************
 * Name    : CreateTIFShipmentObjects
 * Author  : Eric Nelson
 * Date    : 12-12-2011
 * Purpose : The goal of this is to create a custom button on the Cinema Order, 
 *           that, when clicked, creates or updates a circuit record, a theatre record, a 
 *           screen record, and contact record.  If a record is being updated, it 
 *           will already be linked via lookup relationship to the Cinema Order.  If a record is created 
 *           (Circuit/Theatre/Screen/Contact) it should be linked to the original TIF record.
 *
 **========================
 * = MODIFICATION HISTORY =
 **========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 12-12-2011  Eric Nelson        Created
 *
 *****************************************************************************************/

   public TIF__c tif{get;set;}
   Map<String, String> recordTypeNames{get;set;}
   Map<String, Id>RecordTypeMap{get;set;}
   public CreateTIFCircuitTheatreScreenContact(ApexPages.StandardController ctlr)
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
   	                 , t.Record_Completed__c
   	                 , t.Projection_Throw_Distance__c
   	                 , t.Phone__c
   	                 , t.Contact_Email__c
   	                 , t.Number_of_Seats__c
   	                 , t.Name
   	                 , t.Id
   	                 , t.Form_Status__c
   	                 , t.Flat_1_85_Picture_Width__c
   	                 , t.Flat_1_85_Picture_Height__c
   	                 , t.Flat_Screen_Width_ft__c
   	                 , t.Throw_ft__c
   	                 , t.Scope_Screen_Width_ft__c
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
   	  //Check for a circuit. If found, Update. Otherwise, Create.
   	  Circuits__c c = new Circuits__c();
   	  if(tif.Circuit__c != null)
   	    c = [Select Id from Circuits__c where Id = :tif.Circuit__c];
   	  
   	    c.City__c = tif.Billing_City__c;
   	    c.Country__c  = tif.Billing_Country__c;
   	    c.Street_Address__c = tif.Billing_Street_1__c;
   	    c.State_Province__c  = tif.Billing_State_Province__c;
   	    c.Zip_Postal_Code__c =  tif.Billing_Zip_Postal_Code__c;
   	    c.Name = tif.Exhibitor_Owner__c;
   	    c.Circuit_Type__c  =  'Cinema';
   	    
      if(tif.Update_Circuit__c && c.Id != null)
   	     update c;
   	  else if(c.Id == null)
   	     insert c;
   	     
   	  tif.Circuit__c = c.Id;
   	  
   	  //Check for a Theater (Account). If found, Update. Otherwise, Create.
   	  Account a = new Account();
   	  if(tif.Theatre__c != null)
   	    a = [Select Id from Account where Id = :tif.Theatre__c];
   	  
   	    a.BillingPostalCode =  tif.Billing_Zip_Postal_Code__c; 
   	    a.BillingStreet= tif.Billing_Street_1__c;
   	    a.BillingState = tif.Billing_State_Province__c;
   	    a.BillingCountry = tif.Billing_Country__c;
   	    a.BillingCity = tif.Billing_City__c;
   	    a.ShippingCity = tif.Shipping_City__c;
   	    a.ShippingCountry = tif.Shipping_Country__c;
   	    a.ShippingPostalCode = tif.Shipping_Zip_Postal_Code__c;
   	    a.ShippingState = tif.Shipping_State_Province__c;
   	    a.ShippingStreet = tif.Shipping_Street_1__c;
   	    a.Account_Type__c =  'Cinema';
   	    a.Name = tif.Theatre_Name__c;
   	    a.Circuit__c = c.Id;
   	    a.Account_Email__c = tif.Theater_Email__c;
   	    a.Phone = tif.Phone__c;
   	  if(tif.Update_Theatre__c && a.Id != null) 
   	     update a;
   	  else if (a.Id == null)
   	     insert a; 
   	  
   	  tif.Theatre__c = a.Id;
   	  
   	  //Check for a Screen. If found, Update. Otherwise, Create
   	  Screens__c s = new Screens__c();
   	  if(tif.Screen__c != null)
   	    s = [Select Id from Screens__c where Id = :tif.Screen__c];
   	  
   	  	s.Name = tif.Theatre_Name__c + ' SCR ' + tif.Auditorium_Number__c;
   	  	if(s.Id == null)
   	  	   s.Theater__c = a.Id;
   	    s.Auditorium_Number__c = String.ValueOf(tif.Auditorium_Number__c);
   	    s.Total_Seats_in_Auditorium__c = tif.Number_of_Seats__c;
   	    //s.Projector__c = tif.Digital_Projector_Make_Model__c;
   	    s.Flat_Picture_Size_Width__c = tif.Flat_Screen_Width_ft__c; 
   	    s.Scope_Picture_Size_Width__c = tif.Scope_Screen_Width_ft__c;
   	    s.Throw__c = tif.Throw_ft__c;
   	    
   	  if(tif.Update_Screen__c ==true && s.Id != null)
   	    update s;
   	  else if(s.Id == null)
   	    insert s;
   	  
   	  tif.Screen__c = s.Id;
            
      if(tif.Contact__c == null)
      {
      	List<String> fNameLName = ((String)tif.Contact_Name__c).split(' ');
      	
      	Contact con = new Contact(Phone = tif.Phone__c
      	                          ,Email = tif.Contact_Email__c
      	                          ,Circuit__c = c.Id);
      	if(fNameLName.size() > 1)
      	{
      		con.FirstName = fNameLName.get(0);
      		con.LastName = fNameLName.get(1);
      		
      	}
      	else
      	{
      		con.LastName = tif.Contact_Name__c;
      	}
      	insert con;
      	
      	tif.Contact__c = con.Id;
      }
      
      tif.Update_Circuit__c = false;
      tif.Update_Theatre__c = false;
      tif.Update_Screen__c = false;
      update tif;
         	  return new PageReference('/'+tif.Id);
      
   }
}