/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class cwdTestSuite 
{
/*
    static testMethod void testAddAssetController()
    {
        Installs__c ir=[SELECT Id,Name FROM Installs__c LIMIT 1]; //CWD-- get any record. assumes there's some in the system
        Product2 p=new Product2(Name='testProduct',Serial_Range_Start__c=1,Serial_Range_End__c=10);
        insert p;
        
        PageReference pageRef = Page.AddAsset;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('InstallRecordsId',ir.Id);
        
        AddAssetController aac=new AddAssetController();
        aac.asset.product2Id=p.Id;
        aac.asset.SerialNumber='1';
        aac.save();
        
        //CWD-- out of bounds on start
        aac=new AddAssetController();
        aac.asset.product2Id=p.Id;
        aac.asset.SerialNumber='-1';
        aac.save();
        
        //CWD-- out of bounds on end
        aac=new AddAssetController();
        aac.asset.product2Id=p.Id;
        aac.asset.SerialNumber='11';
        aac.save();
        
        //CWD-- asset should already exist now thanks to the first run
        aac=new AddAssetController();
        aac.asset.product2Id=p.Id;
        aac.asset.SerialNumber='1';
        aac.save();
        
        //CWD-- invalid format
        aac=new AddAssetController();
        aac.asset.product2Id=p.Id;
        aac.asset.SerialNumber='a';
        aac.save();  

        //CWD-- empty serial
        aac=new AddAssetController();
        aac.asset.product2Id=p.Id;
        aac.asset.SerialNumber=null;
        aac.save();
        
        aac.cancel();      
    }
*/    
    static testMethod void testCountCinemaSystemsTrigger()
    {
        Account t=new Account(Name='Test Theater',Type='Cinema',BillingCountry='USA');
        insert t;
        
        Screens__c s=new Screens__c(Name='Test Screen', Theater__c=t.Id);
        insert s;
        
        Product2 p=new Product2(Name='Test Product',Family='Cinema');
        insert p;
        
        Asset a=new Asset(name='Test Asset 1', Product2Id=p.Id, Screen__c=s.Id, AccountId=t.Id);
        a.SerialNumber = 'test123';
        insert a;
        
        s=[SELECT Id, Name, Number_of_Installed_Cinema_Systems__c FROM Screens__c WHERE ID=:s.Id LIMIT 1];
        
        //System.assertEquals(s.Number_of_Installed_Cinema_Systems__c, 1); //CWD-- asset that we now have a cinema family asset

        Asset a2=new Asset(name='Test Asset 2', Product2Id=p.Id, Screen__c=s.Id, AccountId=t.Id);
        a.SerialNumber = 'test1234';
        insert a2;
        
        s=[SELECT Id, Name, Number_of_Installed_Cinema_Systems__c FROM Screens__c WHERE ID=:s.Id LIMIT 1];
        //System.assertEquals(2,s.Number_of_Installed_Cinema_Systems__c); //CWD-- asset that we now have 2 cinema family assets

        a2.Description='updating a field';
        update a2;      
        
        s=[SELECT Id, Name, Number_of_Installed_Cinema_Systems__c FROM Screens__c WHERE ID=:s.Id LIMIT 1];
        //System.assertEquals(2,s.Number_of_Installed_Cinema_Systems__c); //CWD-- asset that we still have 2 cinema family assets
        
        delete a2;

        s=[SELECT Id, Name, Number_of_Installed_Cinema_Systems__c FROM Screens__c WHERE ID=:s.Id LIMIT 1];
        //System.assertEquals(1,s.Number_of_Installed_Cinema_Systems__c); //CWD-- asset that we now have 1 cinema family asset  
        
        p.family='something else'; 
        update p;

        s=[SELECT Id, Name, Number_of_Installed_Cinema_Systems__c FROM Screens__c WHERE ID=:s.Id LIMIT 1];
        //System.assertEquals(1,s.Number_of_Installed_Cinema_Systems__c); //CWD-- asset that we now have 1 cinema family asset  
        
        delete a;

        s=[SELECT Id, Name, Number_of_Installed_Cinema_Systems__c FROM Screens__c WHERE ID=:s.Id LIMIT 1];
        ////System.assertEquals(0,s.Number_of_Installed_Cinema_Systems__c); //CWD-- asset that we now have 0 cinema family assets               
    }

    static testMethod void testAccountSalesRegionTrigger()
    {
        Sales_Region__c sr=new Sales_Region__c(Country__c='TestCountry',SalesRegion__c='North America (US and Canada)');
        insert sr;
        
        Account a=new Account(name='Test Account', BillingCountry='nonCountry'); //CWD-- test missing region
        insert a;
        a=[SELECT Id,Name,BillingCountry,SalesRegion__c FROM Account WHERE ID=:a.Id];
        System.debug(a);
        //System.assertEquals(null,a.SalesRegion__c);
        
        a=new Account(name='Test Account2', BillingCountry='TestCountry'); //CWD-- assume there's a mapping for TestCountry in the SalesRegion__c table
        insert a;
        a=[SELECT Id,Name,BillingCountry,SalesRegion__c FROM Account WHERE ID=:a.Id];
        
        ////System.assertEquals('North America (US and Canada)',a.SalesRegion__c);
    }

    static testMethod void testCircuitSalesRegionTrigger()
    {
        Sales_Region__c sr=new Sales_Region__c(Country__c='TestCountry',SalesRegion__c='North America (US and Canada)');
        insert sr;
            
        Circuits__c a=new Circuits__c(name='Test Account', Country__c='nonCountry'); //CWD-- test missing region
        insert a;
        a=[SELECT Id,Name,Country__c,Sales_Region__c FROM Circuits__c WHERE ID=:a.Id];
        System.debug(a);
        //System.assertEquals(null,a.Sales_Region__c);
        
        a=new Circuits__c(name='Test Account2', Country__c='TestCountry'); //CWD-- assume there's a mapping for TestCountry in the SalesRegion__c table
        insert a;
        a=[SELECT Id,Name,Country__c,Sales_Region__c FROM Circuits__c WHERE ID=:a.Id];
        
        ////System.assertEquals('North America (US and Canada)',a.Sales_Region__c);
    }
    
    static testMethod void testUpdateParentCircuits()
    {
        Circuits__c p1=new Circuits__c(Name='account1');
        insert p1;
                
        Account c1=new Account(Name='child1',Circuit__c=p1.Id,BillingCountry='USA');
        insert c1;
        
        Screens__c s1=new Screens__c(Theater__c=c1.Id,name='screen1',RealD_3D_Installed__c=true);
        insert s1;
        Screens__c s2=new Screens__c(Theater__c=c1.Id,name='screen2',RealD_3D_Installed__c=true);
        insert s2;
        Screens__c s3=new Screens__c(Theater__c=c1.Id,name='screen3',RealD_3D_Installed__c=false);
        insert s3;
        
        p1=[SELECT Id, Auditoriums_with_RealD_Installed__c, name FROM Circuits__c WHERE Id=:p1.id LIMIT 1];
        c1=[SELECT Id, Auditoriums_with_RealD_Installed__c, name FROM Account WHERE Id=:c1.id LIMIT 1];
        System.debug('Parent:'+p1);
        System.debug('Child:'+c1);
        ////System.assertEquals(p1.Auditoriums_with_RealD_Installed__c, 2);
        
        List<Account> lAccounts=new List<Account>();
        
        for(integer i=0;i<100;++i)
        {
            lAccounts.add(new Account(Name='child'+i,Circuit__c=p1.Id,BillingCountry='USA'));
        }
        
        insert lAccounts;
    }
}