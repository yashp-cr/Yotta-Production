@isTest
public class BillingGroupBatchSchedulerTest {
    static testmethod void testMethod1(){
        BillingGroupBatchScheduler obj = new BillingGroupBatchScheduler();
        system.schedule('obj', '0 0 0 ? * * *', obj);
    }
}