public with sharing class TheaterInfoFormThanksController 
{
    public boolean recordCompleted{ public get; public set; }
    
    public TheaterInfoFormThanksController()
    {
        recordCompleted=false;
        String str=System.currentPagereference().getParameters().get('state'); // Record_Completed__c
        
        if((str!=null)&&(str=='1'))
            recordCompleted=true;
    }
    
    static testMethod void testController()
    {    	
    	PageReference pageRef=Page.TheaterInfoFormThanks;
    	Test.setCurrentPage(pageRef);
    	TheaterInfoFormThanksController tiform=new TheaterInfoFormThanksController();
    }

}