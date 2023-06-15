/*
*   Name        : Sch_SCFContractsIntegration
*   Description : Create Integration Job after SCF Process is done
*   Functions   : Create Integration Job after SCF Process is done
*   Author      : Nandish Shenoy
*   Create On   : 
*   |-------------------------------------------------------------------------|
*   | Version | Modified By      | Date       | Comment                       |
*   |-------------------------------------------------------------------------|
*   | 0.1     |                  |            | Initial Version of Class      |
*   |-------------------------------------------------------------------------|
*/  
public class Sch_SCFContractsIntegration implements Schedulable {
    
    public Set<Id> setOpportunityIds;

    public Sch_SCFContractsIntegration( set<Id> setOpportunityIds ) {
        this.setOpportunityIds = setOpportunityIds;
    }

    public void execute(SchedulableContext SC) {
        List<Integration_Message__c> lstMessages = new List<Integration_Message__c>();
        IntegrationBase iBase = new IntegrationBase();
        for(Opportunity objOpp : [Select Id, SBQQ__AmendedContract__c, (Select Id From SBQQ__Contracts__r) From Opportunity Where Id In :setOpportunityIds ]) {
            
            Id contractId = objOpp.SBQQ__AmendedContract__c;
            if( objOpp.SBQQ__AmendedContract__c == null ) {
                contractId = objOpp.SBQQ__Contracts__r[0].Id;
            }
            Integration_Message__c objMessage = new Integration_Message__c();
            objMessage = iBase.createIMRecord( null, contractId ,'', '', '','', '', '', false, IntegrationConstants.STR_CONTRACT_TEMPLATE_NAME);
            lstMessages.add( objMessage );
            objMessage.Unique_Key__c = contractId + '_' + IntegrationConstants.STR_CONTRACT_TEMPLATE_NAME + '_' + 'Pending';
        }    
        upsert lstMessages Unique_Key__c;
        Batch_Kill_IntegrationSCFJob batchJob = new Batch_Kill_IntegrationSCFJob();  
        batchJob.jobId = SC.getTriggerId();
        database.executeBatch( batchJob, 1 );
    }  
    
}