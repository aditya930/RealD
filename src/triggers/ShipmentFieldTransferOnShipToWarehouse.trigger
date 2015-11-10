trigger ShipmentFieldTransferOnShipToWarehouse on Shipment__c (before insert, before update) {
	
 /****************************************************************************************
 * Name    : ShipmentFieldTransferOnShipToWarehouse
 * Author  : Nathan Shinn
 * Date    :  8/16/2011
 * Purpose :1. Updates the Mount and kit return fields from the Product Return labels
 *          2. Updates the integration Warehouse address fields from wharehouse, theater and 
 *             shipping street omly when the shipment status is Scheduled.
 *
 *
 * ========================
 * = MODIFICATION HISTORY =
 * ========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 8/16/2011   Nathan Shinn         Created
 * 9/05/2011  Nathan Shinn			Consolidate mount logic and add comments
 *
 *****************************************************************************************
	map<Id, String> theaterMap = new map<Id, String>();
	set<Id> theaterIds = new set<Id>();
	
	map<Id, Warehouse__c> warehouseMap = new map<Id, Warehouse__c>();
	set<Id> warehouseIds = new set<Id>();
	
	map<String, Id> products = new map<String, Id>();
   
    for(Product2 p : [select Id
                          , Generic_Name__c 
                       from Product2 
                      where Generic_Name__c != null])
       products.put(p.Generic_Name__c, p.id);
       
       
	for(Shipment__c s : trigger.new)
	{
	   theaterIds.add(s.Theatre__c);
	   warehouseIds.add(s.Destination_Warehouse__c);
	}
	
	for(Account a: [Select Id
	                     , Name 
	                  from Account 
	                 where Id in :theaterIds])
	{
	  theaterMap.put(a.Id, a.Name);
	}
	
	for(Warehouse__c w : [Select Id
	                           , Ship_to_Name__c
	                           , Street_Address__c
	                           , City__c
	                           , State__c
	                           , Postal_Code__c
	                           , Country__c
	                       from Warehouse__c where Id in :warehouseIds])
	{
		warehouseMap.put(w.Id, w);
	}
	
	

	for(Shipment__c s : trigger.new)
	{
		
		/**1. Update the Mount and kit returns**
	    //Mounts
	    if(s.Mount__c != null && products.get(s.Mount__c) != null )
	       s.Line_3_Product__c = products.get(s.Mount__c);
	    
	    //Return Kits  
	    if(s.Return_Labels_Kit__c != null && products.get(s.Return_Labels_Kit__c) != null)
	       s.Line_4_Product__c =  products.get(s.Return_Labels_Kit__c); 
				
		
		/**2. Update the Integration Shipment addresses **
		if(!s.Status__c.equalsIgnoreCase('Scheduled'))
		  continue;//these updates are only for Scheduled Shipments

        //initialize the shipment addresses at null 
		s.Integration_Ship_Address_Line_1__c =  null;
		s.Integration_Ship_Address_Line_2__c =  null;
		s.Integration_Ship_Address_Line_3__c =  null;
		s.Integration_Ship_Address_Line_4__c =  null;
		s.Integration_Ship_City__c = null;
	    s.Integration_Ship_State__c = null;
	    s.Integration_Ship_Postal_Code__c = null;
	    s.Integration_Ship_Country__c = null;
	    
	    //split the address field into an array of address lines
	    String[] addressLines = null;
	    if(s.Shipping_Street__c != null)
		  addressLines = s.Shipping_Street__c.split('\n');
		
		//update the integration shipment address from the shipping street and theater fields
		if(s.Ship_to_Warehouse__c == false)
		{
			s.Integration_Ship_Name__c = theaterMap.get(s.Theatre__c);
		    
		    if (addressLines.size() > 0)
		      s.Integration_Ship_Address_Line_1__c = addressLines[0] ;
		    if (addressLines.size() > 1)
		      s.Integration_Ship_Address_Line_2__c =  addressLines[1] ;
		    if (addressLines.size() > 2)
		      s.Integration_Ship_Address_Line_3__c =  addressLines[2] ;
		    if (addressLines.size() > 3)
		      s.Integration_Ship_Address_Line_4__c =  addressLines[3] ;
		      
		    s.Integration_Ship_City__c = s.Shipping_City__c;
		    s.Integration_Ship_State__c = s.Shipping_State_Province__c;
		    s.Integration_Ship_Postal_Code__c = s.Shipping_Postal_Code__c;
		    s.Integration_Ship_Country__c = s.Shipping_Country__c;
		}
		else{
			//update the integration shipment address from the shipping street, theater and and destination warehouse fields
			if(warehouseMap.get(s.Destination_Warehouse__c) != null)
			{
			   addressLines =((String) warehouseMap.get(s.Destination_Warehouse__c).Street_Address__c).split('\n');
		       s.Integration_Ship_Address_Line_1__c = 'C/O '+ warehouseMap.get(s.Destination_Warehouse__c).Ship_to_Name__c;
			}
		    
		    s.Integration_Ship_Name__c = theaterMap.get(s.Theatre__c);
		    if (addressLines.size() > 0)
		      s.Integration_Ship_Address_Line_2__c =  addressLines[0] ;
		    if (addressLines.size() > 1)
		      s.Integration_Ship_Address_Line_3__c =  addressLines[1] ;
		    if (addressLines.size() > 2)
		      s.Integration_Ship_Address_Line_4__c =  addressLines[2] ;
		     
		    if(warehouseMap.get(s.Destination_Warehouse__c) != null)
			{  
			    s.Integration_Ship_City__c = warehouseMap.get(s.Destination_Warehouse__c).City__c;
			    s.Integration_Ship_State__c = warehouseMap.get(s.Destination_Warehouse__c).State__c;
			    s.Integration_Ship_Postal_Code__c = warehouseMap.get(s.Destination_Warehouse__c).Postal_Code__c;
			    s.Integration_Ship_Country__c = warehouseMap.get(s.Destination_Warehouse__c).Country__c;
			}
		}
		
	}
	*/
 
 
 
	

}