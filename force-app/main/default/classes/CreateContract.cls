public class CreateContract {
    
    @future
    public static void UpdateAsContracted(Set<Id> orderIdSet){
        List<Order> orderList = new List<Order>();
        for(Order Ord : [SELECT Id, Status From Order WHERE Id IN: orderIdSet]){
            ord.SBQQ__Contracted__c = TRUE;
            ord.SBQQ__ContractingMethod__c = 'Single Contract';
            orderList.add(ord);
        }
        
        if(orderList.size() > 0){
            update orderList;
        }
    }	
}