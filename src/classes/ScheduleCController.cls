public class ScheduleCController {
    //controls how many Schedule line items are displayed on page 1
    public Integer FIRST_BREAK = 4;
    //controls how many Schedule line items are displayed on subsequent pages
    private static Integer SUBSEQ_BREAKS = 5;
    public Id circuitId{get;set;}
    
    public ScheduleCController()
    {
        circuitId = System.currentPageReference().getParameters().get('id');
        FIRST_BREAK = 4;
    }
    
    public class pageBrokenScheduleLines
    {
        public Asset[] assets{get;set;}
        pageBrokenScheduleLines(Asset[] a)
        {
            assets = a;
        }
    }
    
    public List<pageBrokenScheduleLines> pagesBrokenScheduleLines;
    
    
    public Circuits__c getCircuit() {
        Circuits__c cir = new Circuits__c();
        for (Circuits__c c: [select id, Effective_Date_of_Agreement__c, Date_of_Schedule__c, Licensee__c, RealD_Entity__c, Signer__c, Schedule_Name__c, Signer_Title__c, Schedule_Type__c, New_Agreement_Format__c, Termination_Date__c 
                        FROM Circuits__c
                       WHERE id = :circuitId])

                        {
                                cir=c;
                        }
                        return cir;
    }    
    
                       
    public list<Asset> getAssets() {
        return[select Account.Schedule_C_Name_Location__c, id, Name, Product_Name__c, InstallDate, UsageEndDate, Renewal_Term_End_Date__c, SerialNumber, Screen__r.Auditorium_Number__c, Screen__r.RealD_3D_Installed__c, Product2.Include_in_Cinema_Systems_Count__c 
                        FROM Asset 
                       WHERE Screen__r.RealD_3D_Installed__c = TRUE 
                         AND Product2.Include_in_Cinema_Systems_Count__c = TRUE  
                         AND Account.Circuit__c=:circuitId
                    ORDER BY Account.Schedule_C_Name_Location__c];
    }
 
    public String getName() {
        return 'ScheduleCController';
    }
    
    //splits the Schedule lines into an approximate number of rows that can be 
    //displayed per page
    public List<pageBrokenScheduleLines> getScheduleLinesForPrinting()
    {
        pagesBrokenScheduleLines = new List<pageBrokenScheduleLines>();
        
        Asset[] pageOfSchedules = new Asset[]{};
        Integer counter = 0;
        
        boolean firstBreakFound = false;
           boolean setSubSeqBreak = false;        
        Integer breakPoint = FIRST_BREAK;
        //pageBrokenScheduleLines page = new pageBrokenScheduleLines();
        for(Asset q: getAssets())
        {
          
          if(counter <= breakPoint)
          {
             pageOfSchedules.add(q);
             counter++; 
          }
          if(counter == breakPoint)
          {
             if (!firstBreakFound) 
             {
                firstBreakFound = true;
                   setSubSeqBreak  = true;
             }
             counter = 0;
             Asset[] p = new Asset[]{};
             p.addAll(pageOfSchedules);
             pagesBrokenScheduleLines.add(new pageBrokenScheduleLines(p));
             pageOfSchedules.clear();
             //page = new pageBrokenScheduleLines();
          }
          if(setSubSeqBreak) 
             {
                breakPoint = SUBSEQ_BREAKS;
                setSubSeqBreak = false;
             }
        }
        //if we have finished looping and have some Schedules left let's assign them
        if(!pageOfSchedules.isEmpty())
        {
              Asset[] p = new Asset[]{};
              p.addAll(pageOfSchedules);
              pagesBrokenScheduleLines.add(new pageBrokenScheduleLines(p));
        }
              
        return pagesBrokenScheduleLines;
    }

}