public class Batch_Kill_IntegrationSCFJob implements Database.Batchable<sObject>, Database.Stateful{
    
    public String jobId ;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id From Integration_Message__c LIMIT 1');
    }   
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){/*Do Absolutely Nothing*/}    

    public void finish(Database.BatchableContext BC){
        system.abortJob( jobId );
    }    
}