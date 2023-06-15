/**
 * Created by CloudRoute on 31-05-2022.
 */

public class GenerateContractQueueable implements Queueable{

    private Set<Id> opportunityId;

    public GenerateContractQueueable (Set<Id> oppId){
        this.opportunityId = oppId;
    }
    public void execute(QueueableContext context){
		QuoteTriggerHandler.updateOpportunity(opportunityId);
    }
}