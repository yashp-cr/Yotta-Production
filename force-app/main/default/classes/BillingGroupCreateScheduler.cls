global class BillingGroupCreateScheduler implements Schedulable{
    public List<Contract> contractList;

    public BillingGroupCreateScheduler( Set<Id> contractIdSet ) {
        contractList = new List<Contract>();
        for(Id contractId : contractIdSet){
            System.debug('.......QJ Cntract Id......' + contractId);
            contractList.add(new Contract(Id = contractId));
        }

       // if(contractList.size() > 0){
       //     BillingGroupHandler.generateBillingGroup(contractList);
      //  }
    }
    
    global void execute(SchedulableContext sc){
        BillingGroupHandler.generateBillingGroup(contractList);
    } 
}