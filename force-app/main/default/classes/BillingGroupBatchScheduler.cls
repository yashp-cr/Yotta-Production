global class BillingGroupBatchScheduler implements Schedulable {
    global void execute (SchedulableContext SC){
        Batch_BillingGroupUpdate expBatch = new Batch_BillingGroupUpdate();
        Database.executeBatch(expBatch, 100);
    }
}