/*
    Author: Rohail (Tectonic)
    Date: 4/2/2015 - mm/dd/yy
    Description: This test class is used for test coverage of controller HistoryController.
                 Reason of using see all data is that we can't created history record its readonly object.
*/

@isTest (SeeAllData=true)
public class HistoryControllerTest{
    
    public @isTest static void myTest(){
        
        HistoryController ins = new HistoryController ();
        ins.startDate = '1/2/2012';
        ins.endDate = '4/8/2015';
        ins.ExtractHistory();
    }
}