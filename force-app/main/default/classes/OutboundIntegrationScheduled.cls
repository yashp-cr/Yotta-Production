/*
*   Name        : OutboundIntegrationScheduled
*   Description : Fetch all IM Records and run integration.
*   Functions   : 
*   Author      : Nandish Shenoy
*   Create On   : 
*   |-------------------------------------------------------------------------|
*   | Version | Modified By      | Date       | Comment                       |
*   |-------------------------------------------------------------------------|
*   | 0.1     |                  |            | Initial Version of Class      |
*   |-------------------------------------------------------------------------|
*/ 
public class OutboundIntegrationScheduled implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        String query = IntegrationConstants.STR_OUTBOUNDBATCH_BASEQUERY + ' WHERE (( Integration_Status__c=\'Not Processed\' AND Document__c = null AND Contract__c != null ) OR ( Valid_for_Retrial__c=true AND Integration_Status__c=\'Failed\')) AND Webservice_Request__c = null'; 
        if( Test.isRunningTest() ) {
            query += ' AND Contract__c != null ORDER BY CREATEDDATE DESC LIMIT 1';
        }
        List<Integration_Message__c> lstIM = new List<Integration_Message__c>();
        for( Integration_Message__c objIM : (List<Integration_Message__c>)Database.query( query ) ) {
            objIM.Integration_Status__c = 'In Progress';
            if( objIM.Contract__c != null ) { objIM.Unique_Key__c = objIM.Contract__c + '_' + IntegrationConstants.STR_CONTRACT_TEMPLATE_NAME + '_InProgress_' + objIM.Name;} 
            else if( objIM.Account__c != null ) { objIM.Unique_Key__c = objIM.Account__c + '_' + IntegrationConstants.STR_ACCOUNT_TEMPLATE_NAME + '_InProgress_' + objIM.Name;} 
            else if( objIM.Contact__c != null ) {objIM.Unique_Key__c = objIM.Contact__c + '_' + IntegrationConstants.STR_CONTACT_TEMPLATE_NAME + '_InProgress_' + objIM.Name;} 
            else if( objIM.Address__c != null ) { objIM.Unique_Key__c = objIM.Address__c + '_' + IntegrationConstants.STR_ADDRESS_TEMPLATE_NAME + '_InProgress_' + objIM.Name;} 
            else if( objIM.Product2__c != null ) { objIM.Unique_Key__c = objIM.Product2__c + '_' + IntegrationConstants.STR_PRODUCT_TEMPLATE_NAME + '_InProgress_' + objIM.Name;} 
            lstIM.add( objIM );
        }
        update lstIM;
        system.debug('lstIM ' + lstIM);
        OutboundIntegrationBatch batchJob = new OutboundIntegrationBatch(lstIM);  
        if( !Test.isRunningTest()) {database.executeBatch( batchJob, 1 );}
    }
    
    public static void scheduleIntegrationJob( Integer runEvery_X_minutes ) {
        Integer minute = 0;
        String jobName = (Test.isRunningTest()) ? 'Test Job X ' : 'Integration Scheduled Job ';
        for( integer i=1; i <= Math.ceil(60/(Decimal)runEvery_X_minutes); i++ ) {
            System.schedule(jobName + i, '0 ' + minute + ' * * * ?', new OutboundIntegrationScheduled());
            minute += runEvery_X_minutes;
            if(test.isRunningTest()){
                break;
            }
        }
    }
}