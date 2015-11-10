@isTest
private class TestUpdateAssetComponentMaterialFinished {

    static testMethod void runTest() {
      list<Component_Material__c> cmList = new list<Component_Material__c>();
      for(Integer i = 1; i < 11; i++)
      {
      	  cmList.add(TestClientUtility.createComponentMaterial('c'+ i +'-9999'));
      }
	  insert cmList;


       Circuits__c cir = TestClientUtility.createCircuit();
    	cir.Circuit_Type__c = 'Cinema';
    	cir.Country__c = 'USA';
        insert cir;

       Account acc = TestClientUtility.createAccount();
       acc.Circuit__c = cir.Id;
       acc.billingCountry='USA';
       insert acc;
       
     
       Warehouse__c wh = TestClientUtility.createWarehouse(acc.Id);
       wh.name = 'RealD Finished Goods';
       insert wh;
	   
       Product2 p =TestClientUtility.createProduct2();
       insert p;  


       Asset a = TestClientUtility.createAsset(acc.Id, null, wh.Id, p.Id);
       a.Product__c = 'XL';
	   a.BuildComponent1__c = cmList[1].Id;
	   a.BuildComponent2__c = cmList[2].Id;
	   a.BuildComponent3__c = cmList[3].Id;
	   a.BuildComponent4__c = cmList[4].Id;
	   a.BuildComponent5__c = cmList[5].Id;
	   a.BuildComponent6__c = cmList[6].Id;
	   a.BuildComponent7__c = cmList[7].Id;
	   a.BuildComponent8__c = cmList[8].Id;
	   a.BuildComponent9__c = cmList[9].Id;
	   a.BuildComponent10__c = cmList[0].Id;
	   a.SerialNumber = 'XL55555';
	   insert a;

    }
}