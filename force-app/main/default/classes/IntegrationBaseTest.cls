@isTest
public class IntegrationBaseTest extends TriggerHandler {
    
    @testSetup
    static void setup() {
        //create trigger controller
        TriggerController__c tc = new TriggerController__c(DeactivateObjectTrigger__c = '', isActive__c = TRUE);
        insert tc;
        
        //insert account
        Account acc = new Account(Name = 'Acc Name', Industry = 'Manufacturing', YottaIndustry__c = 'Automotive', Send_to_API_Layer__c = TRUE);
        insert acc;
    }
    
    @isTest
    public static void generateRequestTemplate(){
       
        List<Account> accList = [Select Id from Account Limit 1];
        IntegrationBase baseFramework = new IntegrationBase();
        baseFramework.CreateIntegrationRequestEnvelope('Account_Topic', accList[0].Id);
    }
    
    @isTest
    public static void testCallout(){
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IntegrationBase baseFramework = new IntegrationBase();
        HttpResponse res = baseFramework.makeCallout('{caseId : 1, nbsRefId : 2, purchaseOrder : {externalId : 1}}', 'GET', 'http://example.com/example/test');
        Test.stopTest();
    }
    
    @isTest
    public static void testCalloutWithHeader(){
        Test.startTest();
        Map<string, object> header = new Map<string, object>();
        header.put('authorization','testkey');
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        IntegrationBase baseFramework = new IntegrationBase();
        HttpResponse res = baseFramework.makeCalloutWithHeader('{caseId : 1, nbsRefId : 2, purchaseOrder : {externalId : 1}}', 'GET', 'http://example.com/example/test', header);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateIM(){
        IntegrationBase baseFramework = new IntegrationBase();
        List<Account> accountList = [Select Id from Account Limit 1];
        baseFramework.createIMRecord(null, accountList[0].Id, 'Create', 'Real Time', '','','{caseId : 1, nbsRefId : 2, purchaseOrder : {externalId : 1}}', '{caseId : 1, nbsRefId : 2, purchaseOrder : {externalId : 1}}',
                             false, 'Account_Topic');
    }
    
    @isTest
    public static void testCreateMinimalistIM(){
        IntegrationBase baseFramework = new IntegrationBase();
        List<Account> accList = [Select Id from Account Limit 1];
        baseFramework.createMinimalisticIMRecord(null, accList[0].Id, 'Create', 'Real Time', '{caseId : 1, nbsRefId : 2, purchaseOrder : {externalId : 1}}', false,'Integration', '', 'Success');
    }

    @isTest
    public static void testRetrial(){
        IntegrationBase baseFramework = new IntegrationBase();
        baseFramework.validForRetrial(400,1);
    }
    
}