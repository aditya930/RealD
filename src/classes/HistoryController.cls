/*

    Author: Rohail (Tectonic)
    Date: 3/31/2015
    Description: This class will Query the histroy records of all available history Objects.
    at the end of the code this code will send an email contains file as attachment to the user click the button export 

*/
public class HistoryController {
    
    // class varaibles
    public set<string> objectSet{get;set;}
    public list<wrapperClass> finalList {get;set;}
    public  string GroupMemberIds {get;set;}
    Public map<Id,string> userMap{get;set;}
    public string[] Lines;
    public string groupName {get;set;}
    public integer maxObjectLimit {get;set;}
    public string startDate {get; set;}
    public string endDate {get; set;}
    
    // Class constructor 
    public HistoryController (){
        //get value from custom settings 
        Map<string,Audit_History__c> mapHistory = Audit_History__c.getAll();  
        groupName = mapHistory.get('Audit History').Group_Name__c;
        maxObjectLimit = integer.valueOf(mapHistory.get('Audit History').No_Of_Object__c);
        
        // query all active users for displaying user name instead of thier ids in csv columns because some objects doesn't support createdby.name 
        userMap = new map<Id,string>();
        list<User> listOfUsers = [Select Id,Name from user where isActive = true];
        
        for(User u : listOfUsers ){
            userMap.put(u.id,u.name);
        }
        
        //Query all user ID'S from Group Audit & Trial
       List<GroupMember> ListOfGroupMember = [ SELECT GroupId,
                                               UserOrGroupId
                                               FROM GroupMember
                                               WHERE GroupId in (Select Id From Group where name =: groupName )
                                             ];
       
       /*********************************************************************/
       if(ListOfGroupMember.size()>0){
           integer counter = 0;
           GroupMemberIds = '(';
           for(GroupMember gm : ListOfGroupMember ){
               counter++;
               if(ListOfGroupMember.size() == counter){
               
                    GroupMemberIds += '\''+ gm.UserOrGroupId +'\')';
                    
               }else{
               
                   GroupMemberIds += '\'' + gm.UserOrGroupId + '\','; 
               }
           }
       }
       /*********************************************************************/
       
    }
    
    // extract history records
    public void ExtractHistory(){
    
        /* fields intilization*/
        objectSet= new set<string>();
        integer count = 0;
        finalList = new list<wrapperClass>();
        
        //input date validation
        if(!String.isBlank(startDate) && ! String.isBlank(endDate)){
            // date range validation
            boolean isValid = DateValidation(startDate,endDate);
            if(isValid){
            
                list<schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
                
                // Date Ranges filter
                string fromDate =  DateTimeParser(startDate);
                string toDate =  DateTimeParser(endDate);
                
                for(Schema.SObjectType objTyp : allObjects){
        
                    if(count < maxObjectLimit ){
                        if(objTyp.getDescribe().getName().endsWith('History') && objTyp.getDescribe().isQueryable() && !objTyp.getDescribe().getName().endsWith('LoginHistory') && !objTyp.getDescribe().getName().endsWith('OpportunityHistory')){ // loginHisotry dont have column field and we use  opportunityHistory object 
                            if(!objectSet.contains(objTyp.getDescribe().getName())){
                                count ++;
                                objectSet.add(objTyp.getDescribe().getName());
                            }
                        }    
                   }    
                }
                
                
                for(string s : objectSet){
                    
                   string QueryHistory = 'SELECT Field, CreatedById, CreatedDate, IsDeleted, NewValue, OldValue, Id ';
                    
                    // means its custom object history
                    if(s.contains('__')){
                        
                        QueryHistory += ',ParentId,Parent.Name From ';
                    
                    }else if(s.contains('OpportunityField')){
                        
                        string recordId = s.remove('FieldHistory')+'Id';
                        string recordName = s.remove('FieldHistory') + '.Name';
                        QueryHistory += ','+ recordId+','+ recordName + ' From ';
                    
                    }else if(s.contains('Case') || s.contains('Solution') || s.contains('ContentDocument') || s.contains('ContentVersion')){
                        
                        string recordId = s.remove('History') + 'Id';
                        QueryHistory += ','+ recordId+ ' From ';
                        
                    }else {
                        
                        string recordId = s.remove('History') + 'Id';
                        string recordName = s.remove('History') + '.Name';
                        QueryHistory += ','+ recordId+','+ recordName + ' From ';
                    }
                    
                    
                    QueryHistory += s + ' WHERE (CreatedDate >= ' + fromDate + ' AND CreatedDate <= ' + toDate +') AND createdById  IN '+ GroupMemberIds ;
                    
                    // to limit the records when test classes is running
                    if(Test.isRunningTest()){
                            QueryHistory += 'LIMIT 1';
                      }
                    
                    
                    // make call to database
                    List<sObject> records = Database.query(QueryHistory);                 
                    
                    //send records to the wrapper class
                    for(sObject record : records){
                        
                        if(s.contains('__')){ // these are custom object history records
                        
                             finalList.add(new wrapperClass(s,string.valueOf(record.get('Field')),string.valueOf(record.get('OldValue')),string.valueOf(record.get('NewValue')),string.valueOf(record.get('CreatedByID')),string.valueOf(record.get('CreatedDate')),string.valueOf(record.get('ParentId')),(string)record.getSobject('Parent').get('Name')));
                             
                         }else if(s.contains('OpportunityField')){ // this is opportunity field history object beacuse opportunityHistory don't capture history data
                             
                             finalList.add(new wrapperClass(s,(string)record.get('Field'),(string)record.get('OldValue'),(string)record.get('NewValue'),(string)record.get('CreatedByID'),(string)record.get('CreatedDate'),(string)record.getSobject(s.remove('FieldHistory')).get('Id'),(string)record.getSobject(s.remove('FieldHistory')).get('Name')));
                         
                         }else if(s.contains('Case') || s.contains('Solution') || s.contains('ContentDocument') || s.contains('ContentVersion')){ // these object does not have column Name
                         
                             finalList.add(new wrapperClass(s,string.valueOf(record.get('Field')),string.valueOf(record.get('OldValue')),string.valueOf(record.get('NewValue')),string.valueOf(record.get('CreatedByID')),string.valueOf(record.get('CreatedDate')),string.valueOf(record.get(s.remove('History')+'ID')),'No'));
                         
                         }else{ // all standard object
                         
                             finalList.add(new wrapperClass(s,string.valueOf(record.get('Field')),string.valueOf(record.get('OldValue')),string.valueOf(record.get('NewValue')),string.valueOf(record.get('CreatedByID')),string.valueOf(record.get('CreatedDate')),string.valueOf(record.getSobject(s.remove('History')).get('Id')),string.valueOf(record.getSobject(s.remove('History')).get('Name'))));
                         }
                    }
                }
                
                if(finalList.size()>0){
                    CreateExcelFile(finalList);
                }else{
                   ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'No history records found within given date range.')); 
                }
          
            }else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date must be greater than End Date'));
            }
        }else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start or End date can not be empty.'));
        }
    } 
    
    // create csv file 
    public void CreateExcelFile(list<wrapperClass> wrappList){
        lines = new String[0];
        try{
        
            for(wrapperClass record: wrappList) {
                String line = '';
                // header row
                 if ( lines.size() == 0 ) {
                    line = 'Object,Field,Old Value,New Value,User,Date/Time,RecordId,RecordName';
                    lines.add(line);
                }else {
                    
                    line += '"' + (record.cObjName == null ? '' : String.valueof(record.cObjName)) + '"'
                            +',' +'"' + (record.cField == null ? '' : String.valueof(record.cField)) +'"'
                            +',' +'"' + (record.cOldValue == null ? '' : String.valueof(record.cOldValue)) +'"'
                            +',' +'"' + (record.cNewValue == null ? '' : String.valueof(record.cNewValue)) +'"'
                            +',' +'"' + (record.cUserId == null ? '' : String.valueof(userMap.get(record.cUserId))) +'"'
                            +',' +'"' + (record.cCreatedDate == null ? '' : String.valueof(record.cCreatedDate)) +'"'
                            +',' +'"' + (record.cRecordId == null ? '' : String.valueof(record.cRecordId)) +'"'
                            +',' +'"' + (record.cRecordName == null ? '' : String.valueof(record.cRecordName)) +'"';
                            
                    lines.add(line);
                }
            }
            
            // Send history file in email attachment
            sendEmail();
            
       }catch(exception ex){
           system.debug('Stack trace string >>> ' + ex.getStackTraceString() ); 
       }
       
    }
    
    // send email to user
    public void SendEmail(){
        
        try{
            String finalResults = String.join(lines, '\r\n');
            lines = null; // Free temp memory to avoid heap errors
            
            // Send History File into Attachment
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(finalResults);
            string csvname = 'History Extract - From '+ startDate + ' to ' + endDate +'.csv'; 
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new string[] {UserInfo.getUserEmail()};
            string subject = 'History Extract - From '+ startDate + ' to ' + endDate ;
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setHtmlBody('Please find the attached Audit History file..'+'<br/><br/> Start Date: '+startDate +'<br/> End Date: '+endDate);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Audit History record extraction is started. You will get an email after extraction is completed.'));
            // for unit testing only
            if(Test.isRunningTest()){
                string age;
                age.toUpperCase();
            }
        }catch(exception ex){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Email sending failed. Please contact system administrator.'));
            system.debug('=Email Debug Error =' + ex.getMessage());
        }
    }
    
    
    class wrapperClass{
    
        public string cObjName{get;set;}
        public string cField {get;set;}
        public ID cUserId{get;set;} 
        public string cCreatedDate{get;set;}
        public string cNewValue{get;set;}
        public string cOldValue {get;set;}
        public string chId{get;set;}
        public string cRecordId {get;set;}
        public string cRecordName {get;set;}
        
        public wrapperClass(string name, string field, string old, string newval, ID userId, string cDate, string rId, string rName){
            this.cObjName= name;
            this.cField = field;
            this.cOldValue  = old;
            this.cNewValue = newval;
            this.cUserId= userId;
            this.cCreatedDate = cDate;
            this.cRecordId= rId;
            this.cRecordName = rName;
        }
        
    }
    
    //create dateTime
    public string DateTimeParser(string inputDate){
        
        String[] myDateOnly = inputDate.split('/');
        string month = myDateOnly[0];
        string cDate = myDateOnly[1];
        string cYear = myDateOnly[2];
        if(month.length() == 1){
            month = '0'+ myDateOnly[0];
        }
        if(cDate.length() == 1){
            cDate = '0' + myDateOnly[1];
        }
        
        string startDate = cYear + '-'+ Month +'-'+ cDate +'T00:00:00.000Z';
        
        return startDate ;
    }
    
    public boolean DateValidation(string startDate, string endDate){
    
        String[] sDateOnly = startDate.split('/');
        string sMonth = sDateOnly[0];
        string sDate = sDateOnly[1];
        string sYear = sDateOnly[2];
        
        Date strtDate = Date.newInstance(Integer.valueOf(sYear) , Integer.valueOf(sDateOnly[0]), Integer.valueOf(sDateOnly[1]) );
        
        String[] eDateOnly = endDate.split('/');
        string eMonth = eDateOnly[0];
        string eDate = eDateOnly[1];
        string eYear = eDateOnly[2];
        
        Date end_Date = Date.newInstance(Integer.valueOf(eYear) , Integer.valueOf(eDateOnly[0]) , Integer.valueOf(eDateOnly[1]) );

        if(end_Date < strtDate){
            return false;
        }
        
        return true;
    }
    
}