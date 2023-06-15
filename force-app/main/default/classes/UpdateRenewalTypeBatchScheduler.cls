/* ****************************************************************************************************************
 Name          : UpdateRenewalTypeBatchScheduler
 Description   : UpdateRenewalTypeBatchScheduler Apex Class is the Scheduler Class for UpdateRenewalTypeBatch
                 
 Author        : Himanshu Maheshwari (Compro Technologies)
 Creation Date : 13-November-2020
**************************************************************************************************************** */
global class UpdateRenewalTypeBatchScheduler implements Schedulable {
    global void execute (SchedulableContext SC){
        
        UpdateRenewalTypeBatch renBatch = new UpdateRenewalTypeBatch();
        Database.executeBatch(renBatch, 100);
        
        // ExpireContractBatch expBatch = new ExpireContractBatch();
        // Database.executeBatch(renBatch, 100);
    }
}