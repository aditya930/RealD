public with sharing class AssetRecordCreationButrtonCtl {
    public Asset curAsset{get;set;}
    public string transferRecordType{get;set;}
    public boolean promptConfirm{get;set;}
    public AssetRecordCreationButrtonCtl(apexPages.StandardController ctlr)
    {
        curAsset = (Asset)ctlr.getRecord();
        curAsset = [select Id, Status ,Screen__r.RealD_3D_Installed__c
                      from Asset 
                     where Id = :curAsset.Id];  
        promptConfirm = false;
        /*if(curAsset.Screen__r.RealD_3D_Installed__c == TRUE)//curAsset.Status == 'Scheduled' && 
           promptConfirm = true;*/
    }
    
    public PageReference createAssetTransfer()
    {
        //if(!promptConfirm)
        //{
            transferRecordType = ApexPages.currentPage().getParameters().get('transfertype');
            String fieldArgs = '';
            Asset a = [Select Id
                            , Screen__c
                            , Warehouse__c
                            , Warehouse__r.Name
                            , Product2.Name
                            , Product2.Generic_Name__c 
                            , Name
                            , Screen__r.Name
                         from Asset 
                         where Id = :curAsset.Id];
            PageReference pageRef =  new PageReference('/'+ObjectFieldIds__c.getInstance('Asset_Transfer_Record_Prefix').value__c+'/e?retURL='+'/'+a.Id);
            pageRef.getParameters().put('Name', a.Product2.Generic_Name__c + ' '+transferRecordType);
            pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.Asset__c').value__c, a.Id);
            pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.AssetName').value__c, EncodingUtil.urlEncode(a.Name,'UTF-8'));
            pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.Update_Asset__c').value__c,'true');
            
            /*
            fieldArgs += '&Name='+a.Product2.Name + ' '+transferRecordType;
            fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.Asset__c').value__c +'='+ a.Id;
            fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.AssetName').value__c +'='+ a.Name;
            fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.Update_Asset__c').value__c +'=true';
            */
            if(transferRecordType.equalsIgnoreCase('Install'))
            {
              /*
              fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.Source_Warehouse__c').value__c +'='+ a.Warehouse__c;
              fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.SourceWarehouseName').value__c +'='+ a.Warehouse__r.Name;
              fieldArgs +=  '&RecordType='+Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Install').getRecordTypeId();
              */
              pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.Source_Warehouse__c').value__c , EncodingUtil.urlEncode((a.Warehouse__c==null ?'':a.Warehouse__c),'UTF-8'));
              pageRef.getParameters().put('RecordType',Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Install').getRecordTypeId());
              pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.SourceWarehouseName').value__c,EncodingUtil.urlEncode((a.Warehouse__c==null ?'':a.Warehouse__r.Name),'UTF-8'));
              
            }
            
            if(transferRecordType.equalsIgnoreCase('Move'))
            {
              /*
              fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.SourceScreenName').value__c +'='+ a.Screen__r.Name;
              fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.Source_Screen__c').value__c +'='+ a.Screen__c;
              fieldArgs +=  '&RecordType='+Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Move').getRecordTypeId();
              */
              pageRef.getParameters().put('RecordType',Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Move').getRecordTypeId());
              if(a.Screen__c != null)
              {
                  pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.Source_Screen__c').value__c,a.Screen__c);
                  pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.SourceScreenName').value__c,EncodingUtil.urlEncode(a.Screen__r.Name,'UTF-8'));
              }
            }
            
            if(transferRecordType.equalsIgnoreCase('Warehouse+Transfer'))
            {
              /*
              fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.Source_Warehouse__c').value__c +'='+ a.Warehouse__c;
              fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.SourceWarehouseName').value__c +'='+ a.Warehouse__r.Name;
              fieldArgs +=  '&RecordType='+Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Warehouse Transfer').getRecordTypeId();
              */
              if(a.Warehouse__r.Name != null)
              {
                pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.SourceWarehouseName').value__c,EncodingUtil.urlEncode(a.Warehouse__r.Name,'UTF-8'));
                pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.Source_Warehouse__c').value__c,a.Warehouse__c);
              }
              pageRef.getParameters().put('RecordType',Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Warehouse Transfer').getRecordTypeId());
            }
            
            if(transferRecordType.equalsIgnoreCase('Return'))
            {
              /*
              fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.SourceScreenName').value__c +'='+ a.Screen__r.Name;
              fieldArgs +=  '&'+ObjectFieldIds__c.getInstance('Asset_Transfer__c.Source_Screen__c').value__c +'='+ a.Screen__c;
              fieldArgs +=  '&RecordType='+Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Return').getRecordTypeId();
              */
              pageRef.getParameters().put('RecordType',Schema.SObjectType.Asset_Transfer__c.getRecordTypeInfosByName().get('Return').getRecordTypeId());
              if(a.Screen__c != null)
              {
                  pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.Source_Screen__c').value__c,a.Screen__c);
                  pageRef.getParameters().put(ObjectFieldIds__c.getInstance('Asset_Transfer__c.SourceScreenName').value__c,EncodingUtil.urlEncode(a.Screen__r.Name,'UTF-8'));
              }
            }
            
            return pageRef;
        //}
        //else return null;
    }
    
    public PageReference cancel()
    {
        return new PageReference('/'+curAsset.Id);
    }
    
    public PageReference continueNext()
    {
        promptConfirm = false;
        return createAssetTransfer();
    }
    
    

}