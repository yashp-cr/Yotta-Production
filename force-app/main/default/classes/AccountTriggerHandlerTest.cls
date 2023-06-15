@isTest
public class AccountTriggerHandlerTest {
    
    @testSetup
    public static void createData(){
        //create trigger controller
        TriggerController__c tc = new TriggerController__c(DeactivateObjectTrigger__c = '', isActive__c = TRUE);
        insert tc;
    }
    
    @isTest
    public static void createAccountAndSendToKafka(){
        
        //insert account
        Account acc = new Account(Name = 'Acc Name', Industry = 'Manufacturing', YottaIndustry__c = 'Automotive', Send_to_API_Layer__c = false);
        insert acc;
        
        //system.assertEquals(0, [Select count() from Integration_Message__c Where Account__c =: acc.Id]);
        
        Test.startTest();
        //send record to kafka by changing envelope fields
        Account objUpdatedAccount = new Account(Id=acc.Id);
        objUpdatedAccount.Industry = 'BFSI';
        objUpdatedAccount.YottaIndustry__c = 'FinTech';
        objUpdatedAccount.PartnerType__c = 'Alliance Partner';
        objUpdatedAccount.Type = 'Customer';
        objUpdatedAccount.KYC_Approval_Status__c = 'Approved';
        objUpdatedAccount.KYC_Status__c = 'Complete';
        update objUpdatedAccount;
        
        Test.stopTest();

        //system.assertEquals(1, [Select count() from Integration_Message__c Where Account__c =: objUpdatedAccount.Id]);
    }
}