@isTest
public class TestAccountTriggerHandler {
	
    @testSetup
    public static void testDataSetup() {
        TestDataFactory.createTriggerCustomSettings();
    }
    
    public static testmethod void testValidPartnerUserConversion() {
   		Account objAccount = TestDataFactory.createAccount();
        insert objAccount;
        
        Test.startTest();
        objAccount.IsPartner = true;
        try {
        	update objAccount;
            system.assert(false, 'Validation not triggered');
        } catch(DMLException dmlEX) {
        	system.assert( dmlEX.getMessage().contains('Please select Partner Type before enabling it as Partner'));	    
        }    
        Test.stopTest();
    }
    
}