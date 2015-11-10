public class NewReturnLogController {

    Public NewReturnLogController(ApexPages.StandardController rlog){}


public Flow.Interview.New_Return_Log currentFlow {get;set;}

public String newRecordID() {
if (currentFlow==null) return '';
else return currentFlow.var_ReturnLogRecordID;
}

public PageReference getnewReturnLog(){
PageReference p = new PageReference('/' + newRecordID());
p.setRedirect(true);
return p;
}

}