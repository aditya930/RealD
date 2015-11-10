public with sharing class CAconversionController {
	
	public Asset asset0{get;set;}
	public String newXlCaSerialNumber{get;set;}
	Component_Material__c componentMaterial{get;set;}

	public CAconversionController(ApexPages.StandardController ctl)
	{
		asset0 = new asset();
		newXlCaSerialNumber = '';
		
	}
	
	
	/*When user clicks submit:
		1.       Check for Existing CA Asset Record where Serial Number = New XL CA Serial Number AND Product = XL Conditional Access
		2.       If Found, Error: “The selected conditional access serial number already exists in the system.  Notify your manager or administrator before continuing.”
		3.       If no existing asset is found, Continue:
		4.       Lookup Asset Record for Existing XL where Serial Number = OLD XL Serial Number AND Product = XL2
		5.       Update Asset Serial Number to NEW XL CA Serial Number
		6.       Update Asset Name to “XL CA-<NEW XL CA Serial Number>”
		7.       Update Asset Product to XL Conditional Access
		8.       Update Asset Description – Append “Converted from <OLD XL Serial Number>”
		9.       Lookup Build Component Record where Serial/Batch Number = Top Cover Serial Number AND Record Type = XL Top Cover
		10.   Update Finished Product to  Asset record from step 2 above
		11.   Update New Build/Repair field to “Repair”
	 */
	 public PageReference save()
	 {
	 	Asset asset1 = [Select Id, Name, SerialNumber, Description from Asset where Id = :asset0.Linked_Asset__c];
	 	
	 	for(Asset a : [Select Id from Asset where SerialNumber = :newXlCaSerialNumber and Id != :asset1.Id and Product2.Name = 'XL Conditional Access'])
	 	{
	 		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The selected conditional access serial number already exists in the system.  Notify your manager or administrator before continuing.'));
	 		return null;
	 	}
	 	if(asset1.Description != null)
	 		asset1.Description = asset1.Description + 'Converted from '+asset1.SerialNumber;
	    else 
	        asset1.Description = 'Converted from '+asset1.SerialNumber+' on '+System.today().format();
	        
	 	asset1.SerialNumber = newXlCaSerialNumber;
	 	asset1.Name = 'XL CA-'+newXlCaSerialNumber;
	 	asset1.Product2Id = [Select Id from Product2 where name = 'XL Conditional Access' limit 1][0].Id;
	 	Component_Material__c componentMaterial = [select Id, Name, Finished_Product__c, New_Build_Repair__c  
						 	                         from Component_Material__c 
						 	                        where Id = :asset0.BuildComponent1__c 
						 	                          and RecordType.name = 'XL Top Cover'];
	 	componentMaterial.Finished_Product__c = asset1.Id;
		componentMaterial.New_Build_Repair__c = 'Repair';
		
		update asset1;
		update componentMaterial;
		
	 	
	 	return new pageReference('/'+asset1.Id);
	 }
	 
	 @isTest
	 static void testThisClass()
	 {
	 	Account acc = TestClientUtility.createAccount();
       insert acc;
       
       //create test data
       Screens__c screen = TestClientUtility.createScreen(acc.Id);
       insert screen;
       
       //create test data
       Screens__c screen2 = TestClientUtility.createScreen(acc.Id);
       insert screen2;
       
       Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
       insert wh;
       
       Product2 p = TestClientUtility.createProduct2();
       insert p;
       
       Product2 p2 = TestClientUtility.createProduct2();
       p2.Name = 'XL Conditional Access';
       insert p2;
       
       Asset a = TestClientUtility.createAsset(acc.Id, screen.Id, null, p.Id);
	   insert a; 
	   
	   Asset a2 = TestClientUtility.createAsset(acc.Id, screen2.Id, null, p2.Id);
	   a2.SerialNumber='TEST1234-4321';
	   a2.Name = 'x';
	   insert a2; 
	   
	   RecordType rt = [Select Id from RecordType where Name = 'XL Top Cover' limit 1];
	   Component_Material__c m = TestClientUtility.createComponentMaterial(rt.Id);
	   insert m;
	   
 		//Create the controller and execute its methods
 		ApexPages.StandardController ctlr = new ApexPages.StandardController(a);
 		CAconversionController ctl = new CAconversionController(ctlr);
 		ctl.asset0.Linked_Asset__c = a2.Id;
 		ctl.asset0.BuildComponent1__c = m.Id;
 		
 		ctl.newXlCaSerialNumber = 'test4321-1234';
 		ctl.save();
	 		
	 		
	 }

}