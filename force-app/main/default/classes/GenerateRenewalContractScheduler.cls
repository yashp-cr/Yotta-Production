/* ****************************************************************************************************************
 Name          : GenerateRenewalContractScheduler
 Description   : GenerateRenewalContractScheduler Apex Class is the Scheduler Class for GenerateRenewalContract
                 
 Author        : Himanshu Maheshwari (Compro Technologies)
 Creation Date : 29-June-2020
**************************************************************************************************************** */
global class GenerateRenewalContractScheduler implements Schedulable {
    global void execute (SchedulableContext SC){
        GenerateRenewalContractBatch renBatch = new GenerateRenewalContractBatch(null);
        Database.executeBatch(renBatch, 100);
    }
}