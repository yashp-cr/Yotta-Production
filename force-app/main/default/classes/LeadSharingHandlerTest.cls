@isTest
public class LeadSharingHandlerTest {
	
    @testSetup
    public static void testDataSetup() {
        TestDataFactory.createTriggerCustomSettings();
    }
    
    public static testmethod void testLeadShare() {
    	Lead objLead = TestDataFactory.createLead();
        objLead.OwnerId = [Select Id from Group where Name='IS Team' And Type='Queue'].Id;
        User objUser = [Select Id from User where Profile.Name='B2BMA Integration User' And isActive=true LIMIT 1];
        Test.startTest();
        system.runAs(objUser){
            insert objLead;
        }
        system.assertEquals(1, [Select count() from LeadShare where LeadId =: objLead.Id and RowCause='Manual' And UserOrGroupId=:objUser.Id]);
        Test.stopTest();
        
        objLead.Creator__c = UserInfo.getUserId();
        update objLead;
        system.assertEquals(1, [Select count() from LeadShare where LeadId =: objLead.Id and RowCause='Manual' And UserOrGroupId=:objLead.Creator__c]);
    }
    
}