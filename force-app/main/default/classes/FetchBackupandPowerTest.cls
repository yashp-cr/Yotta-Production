@isTest(SeeAllData=true)
public class FetchBackupandPowerTest 
{

    @isTest static void positiveTest1()
    {
        Test.startTest();
		Integration_Message__c msg = new Integration_Message__c();
        msg.Webservice_Request__c='FetchProductSubscription';
        msg.Webservice_params__c='P000174,P000673,P000672';
        msg.Valid_For_Retrial__c=false;
        msg.Unique_Key__c= '12345';
        msg.Message_Type__c ='Integration';
        insert msg;  
        Test.stopTest();
        
        
    }

}