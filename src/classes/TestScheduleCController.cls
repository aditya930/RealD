@isTest
private class TestScheduleCController {

    static testMethod void runTest() {

       Product2 prod = TestClientUtility.createProduct2();
       prod.Include_in_Cinema_Systems_Count__c = TRUE;
                                   
       insert prod;
        
       Circuits__c cir = TestClientUtility.createCircuit();
       cir.Circuit_Type__c = 'Cinema'; 
       cir.Effective_Date_of_Agreement__c = Date.today();
       cir.Date_of_Schedule__c = Date.today();
       cir.Licensee__c = 'Licensee Name';
       cir.RealD_Entity__c = 'RealD Inc.';
       cir.Signer__c = 'Craig Gatarz';
       cir.Schedule_Name__c = 'Schedule C';
       cir.Schedule_Type__c = 'RealD System License and Leasing Agreement';
       cir.New_Agreement_Format__c = FALSE;
       cir.Termination_Date__c = Date.today(); 
       insert cir;
        
       Account acc = TestClientUtility.createAccount();
       acc.Circuit__c = cir.Id;
       acc.Account_Type__c = 'Cinima';
       insert acc;

       Screens__c screen = TestClientUtility.createScreen(acc.Id);
       screen.RealD_3D_Installed__c = TRUE;
       screen.Auditorium_Number__c = '2';
       screen.Number_of_Installed_Cinema_Systems__c = 0;
       screen.Active_Date__c = system.today();
       insert screen;
       
       Asset ast = TestClientUtility.createAsset(acc.Id, screen.Id, null, prod.Id);
       ast.SerialNumber = '77899';
       ast.Product2Id = prod.Id;
       ast.AccountId = acc.Id;
       ast.Screen__c = screen.Id;
       ast.InstallDate = Date.Today(); 
       ast.UsageEndDate = Date.Today();
       ast.Renewal_Term_End_Date__c = Date.Today(); 
       insert ast;
       
       //Manage Work flow rules that set the RealD 3D Installed to false
       screen.Number_of_Installed_Cinema_Systems__c = 1;
       screen.Active_Date__c = Date.Today();
       //Number_of_Asset_Transfers__c > Number_of_Removal_Asset_Transfers__c
       screen.Number_of_Removal_Asset_Transfers__c = null;
       screen.Delay_Deactivation_for_Reconcile__c = TRUE;
       

       
       update screen;
       
       system.assert([select RealD_3D_Installed__c from Screens__c where Id = :screen.Id].RealD_3D_Installed__c);
       
       prod.Include_in_Cinema_Systems_Count__c = TRUE;
       update prod;
       
       
       ast.Product2Id = prod.Id;
       ast.AccountId = acc.Id;
       ast.Screen__c = screen.Id;
       
      
       update ast;
       
       Test.startTest();
       Test.setCurrentPage(Page.ScheduleC);
       ApexPages.currentPage().getParameters().put('Id',cir.Id);
       ScheduleCController ctl = new ScheduleCController();
       
       System.assertEquals(cir.Id, ctl.circuitId);
       
       System.assert([select Account.Schedule_C_Name_Location__c, id, Name, Product_Name__c, InstallDate, UsageEndDate, SerialNumber, Screen__r.Auditorium_Number__c, Screen__r.RealD_3D_Installed__c, Product2.Include_in_Cinema_Systems_Count__c 
                        FROM Asset 
                       WHERE Screen__r.RealD_3D_Installed__c = TRUE 
                         AND Product2.Include_in_Cinema_Systems_Count__c = TRUE  
                         AND Account.Circuit__c=:cir.Id].size() > 0);
       
       ctl.getCircuit();
       ctl.getAssets();
       ctl.getScheduleLinesForPrinting();
       ctl.FIRST_BREAK = 1;
       ctl.getScheduleLinesForPrinting();
       ctl.getName();
       Test.stopTest();
       
    }
}