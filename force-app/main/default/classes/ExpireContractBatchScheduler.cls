/* ****************************************************************************************************************
 Name          : ExpireContractBatchScheduler
 Description   : ExpireContractBatchScheduler Apex Class is the Scheduler Class for ExpireContractBatch
                 
 Author        : Himanshu Maheshwari (Compro Technologies)
 Creation Date : 23-April-2021
**************************************************************************************************************** */
global class ExpireContractBatchScheduler implements Schedulable {
    global void execute (SchedulableContext SC){
        ExpireContractBatch expBatch = new ExpireContractBatch();
        Database.executeBatch(expBatch, 100);
    }
}