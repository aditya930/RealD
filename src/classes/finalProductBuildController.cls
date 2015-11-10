public without sharing class finalProductBuildController {
        
        public Asset pAsset{get;set;}
        public finalProductBuildController(ApexPages.StandardController ctl)
        {
                if(ctl.getId() != null) 
                {   
                    pAsset =[Select Id,
                                    SerialNumber,
                                    Product__c ,
                                    Firmware_Version__c,
                                    Operator__c,
                                    Revision__c,
                                    Manufactured_By__c,
                                    Deviation__c,
                                    Build_Date__c,
                                    BuildComponent1__c,
                                    BuildComponent2__c,
                                    BuildComponent3__c,
                                    BuildComponent4__c,
                                    BuildComponent5__c,
                                    BuildComponent6__c,
                                    BuildComponent7__c,
                                    BuildComponent8__c,
                                    BuildComponent9__c,
                                    BuildComponent10__c,
                                    Name,
                                    AccountId,
                                    Warehouse__c
                               From Asset
                              where Id = :ctl.getId()];
                }
                else
                {
                        pAsset = new Asset();
                }
                pAsset.Operator__c = ApexPages.currentPage().getParameters().get('operator');
                pAsset.Manufactured_By__c = ApexPages.currentPage().getParameters().get('manufacturedby');
                pAsset.Build_Date__c = System.today();
        }
        
        public pageReference save()
        {
                //Asset a = new Asset(Id = pAsset.Id);
                pAsset.AccountId = pAsset.AccountId == null 
		                       ? FinalProductBuildDefaults__c.getInstance('DefaultValues').AccountId__c
		                       : pAsset.AccountId;
		        pAsset.Name = FinalBuildProducts__c.getInstance(pAsset.Product__c).Asset_Name_Prefix__c + '-' +  pAsset.SerialNumber; 
		        pAsset.Warehouse__c = pAsset.Warehouse__c == null 
		                        ? FinalProductBuildDefaults__c.getInstance('DefaultValues').WarehouseId__c
		                        : pAsset.Warehouse__c;
		        pAsset.Product2Id = FinalBuildProducts__c.getInstance(pAsset.Product__c).Product_ID__c;
		       
                
                try{
                	upsert pAsset;
                	return new PageReference('/'+pAsset.Id);
                }
                catch(Exception e)
                {
                  ApexPages.addMessages(e);
                  return null;
                }
                
                
        }

}