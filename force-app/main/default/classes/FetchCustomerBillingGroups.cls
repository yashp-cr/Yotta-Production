/* ****************************************************************************************************************
Name          : FetchCustomerBillingGroups
Description   : Class to call custom Webservice through Composite Interface
Author        : Nandish Shenoy  
Creation Date : 28/09/2020
Modified Date : 28/09/2020
**************************************************************************************************************** */
public class FetchCustomerBillingGroups implements IntegrationExtension {
    
    /**
     * extends IntegrationExtension Interface to implement custom JSON structures.
     **/
    public void runExtension(String params, String requestId) {
        Batch_PushBillingGroupCustomerToKafka batch = new Batch_PushBillingGroupCustomerToKafka(params, requestId);
        Database.executeBatch( batch, 10 ); 
        system.debug('Called from Webservice');
    }
    
    public Object runExtension(String params){return null;}
}