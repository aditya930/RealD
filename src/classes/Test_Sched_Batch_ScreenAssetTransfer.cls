@isTest
private class Test_Sched_Batch_ScreenAssetTransfer {

    static testMethod void runTest() {
        Test.startTest();

	        Sched_Batch_ScreenAssetTransferRollUps b
                = new Sched_Batch_ScreenAssetTransferRollUps(); 
            String schedule = '0 0 23 * * ?';
	        system.schedule('Test - Sched_Batch_ScreenAssetTransferRollUps '+System.now(), schedule, b);
  
        Test.stopTest();
    }
}