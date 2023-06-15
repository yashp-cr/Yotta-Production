global class RenewContractsScheduler implements Schedulable
{
    global void execute (SchedulableContext SC)
    {
        RenewContractsBatch renConBatch = new RenewContractsBatch(null);
        Database.executeBatch(renConBatch,100);
    }
}