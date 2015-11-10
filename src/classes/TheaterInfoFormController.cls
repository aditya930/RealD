public with sharing class TheaterInfoFormController 
{
    public TIF__c tif { public get; public set; }
    public boolean blnShowMeasurements { public get; public set; }
    
    public TheaterInfoFormController(ApexPages.StandardController controller) 
    {
        System.debug('CONSTRUCTING: '+tif);
        
        blnShowMeasurements=true;
        tif=(TIF__c)controller.getRecord();
            
        if(getLoggedInStatus())
        {
            try
            {
                List<TIF__c> lTif=[SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Auditorium_Number__c,Billing_Street_1__c, Billing_City__c, Billing_State_Province__c,  Billing_Zip_Postal_Code__c,Billing_Country__c, Comments__c, Contact_Name__c, DC_Equipment_Install_Date__c, DC_Equipment_Installer__c, DC_Service_Provider__c, Digital_Projector_Make_Model__c, Digital_Server_Make_and_Model__c, Distance_from_floor_to_bottom_of_window__c, Dist_floor_to_center_of_proj_lens__c, Distance_from_port_window_to_end_of_proj__c, Exhibitor_Owner__c, Fax__c, Flat_1_85_Picture_Height__c, Flat_1_85_Picture_Width__c, Is_Port_Window_Sized_Right__c, Masking_Movement__c, Number_of_Seats__c, Phone__c, Port_window_clear_opening_height__c, Port_window_clear_opening_width__c, Port_Window_Information_UoM__c, Product__c, Projection_Throw_Distance__c, Request_Date__c, Scope_2_39_Picture_Height__c, Scope_2_39_Picture_Width__c, Screen_Height__c, Screen_Width__c, Shipping_Street_1__c, Shipping_City__c,  Shipping_State_Province__c,  Shipping_Zip_Postal_Code__c, Shipping_Country__c,Silver_Screen_Manufacturer__c, Silver_Screen_Install_Date__c, The_name_and_type_of_port_window_glass__c, Theater_Email__c, Theatre_Name__c, UoM__c, Thickness_Depth_of_projector_win_wall__c, Record_Completed__c, Form_Status__c FROM TIF__c WHERE Record_Completed__c=false AND OwnerId=:UserInfo.getUserId() LIMIT 1];
             
                if(lTif.size()>0)
                	tif=lTif.get(0);
            }
            catch(Exception e) 
            {
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'An Error occured while attempting to load data'+e.getMessage()));
            }
        }

        if(tif==null)
        {
            tif=new TIF__c(Product__c='Unknown');        
        }

        checkProduct();
        System.debug('CONSTRUCTED: '+tif);        
    }
    
    public static String getUserLicense()
    {
        Profile p=[SELECT ID,Name,UserLicense.Name FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1];
        
        if(p!=null)
            return p.UserLicense.Name;
        
        return '';
    }
    
    public static boolean getLoggedInStatus()
    {
        String str=getUserLicense();
    System.debug('user license: '+str);
        if(str.equalsIgnoreCase('Guest User License') ) //Theater Information Form Profile
            return false;
            
        return true;
    }
    
    public PageReference checkProduct()
    {
        blnShowMeasurements=false;
        
        if(tif.Product__c==null)
            tif.Product__c='Unknown';

        if(tif.Product__c=='Unknown')
          blnShowMeasurements=true;
          
        return null;
    }
    
    public PageReference copyBillingToShipping()
    {
        tif.Shipping_City__c=tif.Billing_City__c;
        tif.Shipping_Country__c =tif.Billing_Country__c;
        tif.Shipping_State_Province__c =tif.Billing_State_Province__c;
        tif.Shipping_Street_1__c =tif.Billing_Street_1__c;
        tif.Shipping_Zip_Postal_Code__c =tif.Billing_Zip_Postal_Code__c;
        return null;
    }
    
    public PageReference saveAndSubmit()
    {
        tif.Record_Completed__c=true;
        tif.Form_Status__c='Submitted';
        return save();
    }
    
    public PageReference save()
    {
        try
        {
            if(!getLoggedInStatus())
                tif.Record_Completed__c=true;
            
            if(tif.Id==null)
                insert tif;
            else
                update tif;
                
            PageReference p=Page.TheaterInfoFormThanks;
            p.getParameters().put('state',(tif.Record_Completed__c?'1':'0'));
            
            if(getLoggedInStatus())   
                return p;
            else
                return Page.TheaterInfoFormAnonThanks;
        }
        catch(Exception e)
        {
            tif.Record_Completed__c=false;
            tif.Form_Status__c='Draft';
            System.debug(e);
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'An Error occured while attempting to save data'+e.getMessage()));
        }
        
        return null;
    }
    
    static testMethod void testController()
    {    	
    	PageReference pageRef = Page.TheaterInfoForm;
    	Test.setCurrentPage(pageRef);
    	TheaterInfoFormController tiform=new TheaterInfoFormController(new ApexPages.StandardController(new TIF__c(Theatre_Name__c='testform',Auditorium_Number__c=1.0)));
    	tiform.save();
    	
    	TheaterInfoFormController.getLoggedInStatus();
    	tiform.checkProduct();
    	tiform.copyBillingToShipping();
    	tiform.saveAndSubmit();
    }

}