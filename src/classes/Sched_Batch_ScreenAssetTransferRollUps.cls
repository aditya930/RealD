global class Sched_Batch_ScreenAssetTransferRollUps implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
         Batch_ScreenAssetTransferRollUps b
                = new Batch_ScreenAssetTransferRollUps(); 
          database.executebatch(b);
    }
}