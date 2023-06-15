public class SCFBillingGroupQueueableHandler implements Queueable{
    public List<Contract> contractList;

    public SCFBillingGroupQueueableHandler( Set<Id> contractIdSet ) {
        contractList = new List<Contract>();
        for(Id contractId : contractIdSet){
            System.debug('.......QJ Cntract Id......' + contractId);
            contractList.add(new Contract(Id = contractId));
        }
        System.debug('contractList :: '+contractList);

        if(contractList.size() > 0){
            BillingGroupHandler.generateBillingGroup(contractList);
        }
    }
    
    public void execute(QueueableContext context) {
        
    }
}