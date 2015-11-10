public with sharing class TIFHomepageController 
{
    public PageReference redirectTo { public get; private set; }
    
    public TIFHomepageController()
    {
        redirectTo=null;
        
        if(TheaterInfoFormController.getLoggedInStatus())
            redirectTo=Page.TheaterInfoForm;
    }
    
    public PageReference getRedirectTo() {
        return redirectTo;
    }  
    
    static testMethod void testController()
    {    	
    	PageReference pageRef=Page.TIFHomepage;
    	Test.setCurrentPage(pageRef);
    	TIFHomepageController tiform=new TIFHomepageController();
    	tiform.getRedirectTo();
    }      
}