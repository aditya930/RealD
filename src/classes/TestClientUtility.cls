public with sharing class TestClientUtility {
	
	public static Account createAccount()
	{
		Account a =  new Account(name='testAcc1'
	                            ,BillingCountry = 'USA');
		
		return a;
	}
	
	public static Contact createContact(Id accountId)
	{
		Contact c = new Contact(AccountId = accountId
		                       ,LastName = 'Test');
		
		return c;
	}
	
	public static Product2 createProduct2()
	{
		Product2 prod = new Product2(name = 'testprodx'
                                   ,Generic_Name__c = 'testGenProdx');
                                   
        return prod;
	}
	
	public static Case createCase()
	{
		Case c = new Case(Type = 'RMA Rwquest'
                         ,Status = 'New');
                                   
        return c;
	}
	
	public static Screens__c createScreen(Id theaterId)
	{
		Screens__c screen = new Screens__c(Theater__c = theaterId
                                         ,Name = 'testScreen 1');
                                
        return screen;
	}
	
	public static Circuits__c createCircuit()
	{
		Circuits__c cir = new Circuits__c(Name = 'Test Circuit 1'
		                                ,Circuit_Type__c = 'Cinema'
		                                ,Country__c = 'USA');
                                
        return cir;
	}
	
	public static Warehouse__c createWarehouse(Id accountId)
	{
		Warehouse__c wh = new Warehouse__c(name = 'testwarehsouse1'
                                          ,Account__c = accountId
                                          ,Warehouse_Type__c = 'RealD Distribution'
                                          ,Street_Address__c = 'ddddd\nssss');
                                
        return wh;
	}
	
	public static Asset createAsset(Id accountId, Id screenId, Id warehouseId, Id productId)
	{
		Asset a = new Asset(Screen__c = screenId
		                 , Product2Id = productId
		                 , Name = 'testx1'
		                 , Warehouse__c = warehouseId
		                 , accountId = accountId
	                     , SerialNumber = '777888999');
                                
        return a;
	}
	
	public static Shipment__c createShipment(Id theaterId, Id circuitId, Id contactId, Id screenId, Id sourceWarehouseId, Id destWarehouseId, Id productId, Id assetId, Id caseId)
	{
		Shipment__c ship = new  Shipment__c(Actual_Ship_Date__c = System.now()
						                 //, Source_Warehouse__c = sourceWarehouseId
						                 , Destination_Warehouse__c = destWarehouseId
						                 //, Asset_1__c = assetId
						                 , Screen__c = screenId
						                 , Status__c = 'Scheduled'
						                 //, Mount__c = null
						                 //, Return_From_Address__c = 'xxx'
						                // , Return_to_Warehouse__c = sourceWarehouseId
						                 , RMA__c =caseId
						                // , Line_1_Serial_Number__c = '11'
						                 //, Line_1_Product__c = productId
						                 , COntact__c = contactId
						                 , Circuit__c = circuitId
						                 , Shipping_Service_Type__c	='Domestic Ground'
						                 , Scheduled_Ship_Date__c = System.today() + 5
						                 , Theatre__c = theaterId
						                 , Shipping_Street__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaa\nbbbbbbbbbbbbbbbbbbbbbbbb'
						                 //, Return_Labels_Kit__c = 'testGenProdx'
						                 );
	     return ship;
	}
	
	public static Shipment_Line_Item__c createShipmentLineItem(Id shipmentId, Id productId, Id warehouseId, Id screenId)
	{
		Shipment_Line_Item__c sli = new Shipment_Line_Item__c(Shipment__c = shipmentId
                                                             , SourceWarehouse__c = warehouseId
                                                             , Screen__c = screenId
                                                             , Quantity__c = 1
                                                             , Product__c = productId);
	    return sli;
	}
	
	public static Asset_Transfer__c createAssetTransfer(Id assetId, Id sourceScreenId, Id destScreenId, Date TransferBeginDate, Date TransferEndDate)
	{
		
        Asset_Transfer__c ast = new Asset_Transfer__c(Destination_Screen__c = destScreenId
                                                     ,Transfer_Begin_Date__c = TransferBeginDate
                                                     ,Source_Screen__c = sourceScreenId
                                                     ,Transfer_End_Date__c = TransferEndDate
                                                     ,asset__c = assetId
                                                     );
                                
        return ast;
	}
	
	public static Task createTask(Id whoId, Id whatId)
	{
		Task t = new Task( Subject = 'testtask'
                          ,Whatid = WhatId
                          ,WhoId = whoId);
                                          
        return t;
	}
	
	public static TIF__c createTif(String productName) 
	{
		TIF__c t = new TIF__c( Update_Theatre__c = true
		   	                 , Update_Screen__c = true
		   	                 , Update_Circuit__c = true
		   	                 , Theatre_Name__c = 'x'
		   	                 , Exhibitor_Owner__c = 'exhib'
		   	                 , Theater_Email__c = 'xys@realdxys.nathan.com.dev'
		   	                 , Contact_Email__c = 'test@testcontact.com.dev'
		   	                 , Shipping_Zip_Postal_Code__c = 'x'
		   	                 , Shipping_Street_1__c = 'x'
		   	                 , Shipping_State_Province__c = 'x'
		   	                 , Shipping_Country__c = 'x'
		   	                 , Shipping_City__c = 'x'
		   	                 , Screen_Width__c  = 3
		   	                 , Screen_Height__c = 1
		   	                 , Scope_2_39_Picture_Width__c = 1
		   	                 , Scope_2_39_Picture_Height__c = 1
		   	                 , Request_Date__c = System.today() + 2
		   	                 , Record_Completed__c = true
		   	                 , Projection_Throw_Distance__c  = 1
		   	                 , Product__c = productName
		   	                 , Phone__c = '111'
		   	                 , Number_of_Seats__c = 2
		   	                 , Form_Status__c = 'Reviewed'
		   	                 , Flat_1_85_Picture_Width__c = 2
		   	                 , Flat_1_85_Picture_Height__c = 2
		   	                 , Digital_Projector_Make_Model__c ='s'
		   	                 , Contact_Name__c =  'd'
		   	                 , Comments__c = 'd'
		   	                 , Billing_Zip_Postal_Code__c = 'x'
		   	                 , Billing_Street_1__c = 'x'
		   	                 , Billing_State_Province__c = 'x'
		   	                 , Billing_Country__c = 'x'
		   	                 , Billing_City__c = 'x'
		   	                 , Auditorium_Number__c  = 1);
		  return t;
	}
	
	public static string generate16BitId()
    {
    	String returnId = '';
    	while(returnId.length() < 17)
    	{
    		Double randNumber = Math.abs(Math.random());
    		returnId += String.valueOf(randNumber).replace('.', '');
    	}
    	
    	return returnId.substring(0,16);
    }
       
    public static string generateSerialNumber()
    {
    	return 'XL'+generate16BitId().substring(0,5);
    } 
    
    public static Component_Material__c createComponentMaterial(string name)
    {
    	return new Component_Material__c(Name = name);
    	
    }
    
    public static Inventory__c createInventory(Id warehouseId, Id productId )
    {
    	return new Inventory__c( Warehouse__c = warehouseId
                               , Quantity__c = 1
                               , Product__c = productId
                               , Date__c = System.Today()
                               , Comments__c = 'Test');
    }
    
    public static  Component_Material__c createComponentMaterial(Id RecordTypeId)
    {
    	return new Component_Material__c( RecordTypeId = RecordTypeId
		                                , Name = 'Test' 
		                                , New_Build_Repair__c = 'New');
    }

}