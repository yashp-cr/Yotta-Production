/* ****************************************************************************************************************
Name          : Batch_PushBillingGroupCustomerToKafka
Description   : Pushes billing group data for all customers to Kafka
Author        : Nandish Shenoy  
Creation Date : 1/10/2020
Modified Date : 1/10/2020
**************************************************************************************************************** */
public with sharing class FetchBillingSOFs implements IntegrationExtension {
    
    public void runExtension(String params, String requestId) {
        Batch_PushBillingGroupSOFsToKafka batch = new Batch_PushBillingGroupSOFsToKafka( params, requestId );
        Database.executeBatch( batch);
    }
    
    public Object runExtension(String params){return null;}
}