//****** Test Class for Trigger LeadTrigger ******
//****** Test Class for Class LeadTriggerHandler ******
//****** Test Class for Class AutoLeadConvertBatch ******

@isTest
public class LeadTriggerHandlerTest {
	
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
    
    public static testmethod void testAutoLeadConvert() {
        
        Campaign camp1 = TestDataFactory.createCampaign();
        Campaign camp2 = TestDataFactory.createCampaign();
        Campaign camp3 = TestDataFactory.createCampaign();
        
        insert new List<Campaign>{ camp1, camp2, camp3 };
        
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Regular Lead').getRecordTypeId();
        
        Lead newAnewC = TestDataFactory.createLead();
        newAnewC.RecordTypeId = recordTypeId;
        newAnewC.Auto_Convert__c = 'Yes';
        newAnewC.Primary_Campaign__c = camp1.Id;
        newAnewC.Secondary_Campaign__c = camp2.Id;
        newAnewC.Tertiary_Campaign__c = camp3.Id;
        newAnewC.PrimarySource__c = 'Marketing';
        newAnewC.SecondarySource__c = 'Marketing';
        newAnewC.TertiarySource__c = 'Marketing';
        
        Lead oldAnewC = TestDataFactory.createLead();
        oldAnewC.RecordTypeId = recordTypeId;
        oldAnewC.Email += 'newC';
        oldAnewC.Auto_Convert__c = 'Yes';
        oldAnewC.Primary_Campaign__c = camp1.Id;
        oldAnewC.Secondary_Campaign__c = camp2.Id;
        oldAnewC.Tertiary_Campaign__c = camp3.Id;
        oldAnewC.PrimarySource__c = 'Marketing';
        oldAnewC.SecondarySource__c = 'Marketing';
        oldAnewC.TertiarySource__c = 'Marketing';
        
        Lead oldAOldC = TestDataFactory.createLead();
        oldAOldC.RecordTypeId = recordTypeId;
        oldAOldC.Auto_Convert__c = 'Yes';
        oldAOldC.Primary_Campaign__c = camp1.Id;
        oldAOldC.Secondary_Campaign__c = camp2.Id;
        oldAOldC.Tertiary_Campaign__c = camp3.Id;
        oldAOldC.PrimarySource__c = 'Marketing';
		oldAOldC.SecondarySource__c = 'Marketing';
        oldAOldC.TertiarySource__c = 'Marketing';
        
        Lead newAOldC = TestDataFactory.createLead();
        newAOldC.RecordTypeId = recordTypeId;
        //newAOldC.Company += 'newA';
        newAOldC.Auto_Convert__c = 'Yes';
        newAOldC.Primary_Campaign__c = camp1.Id;
        newAOldC.Secondary_Campaign__c = camp2.Id;
        newAOldC.Tertiary_Campaign__c = camp3.Id;
		newAOldC.PrimarySource__c = 'Marketing';
        newAOldC.SecondarySource__c = 'Marketing';
        newAOldC.TertiarySource__c = 'Marketing';
        
        Test.startTest();
        insert new List<Lead>{newAnewC, oldAnewC, oldAOldC, newAOldC};
        /*insert newAnewC;
        insert oldAnewC;
        insert oldAOldC;
        insert newAOldC;*/
        Test.stopTest();
    }
    
    public static testmethod void testAutoLeadConvert_partner() {
        
        Account acc1 = TestDataFactory.createAccount();
        Account acc2 = TestDataFactory.createAccount();
        Account acc3 = TestDataFactory.createAccount();
        
        insert new List<Account>{ acc1, acc2, acc3 };
            
        acc1.PartnerType__c = 'Alliance Partner,Consultant Partner,Marketing';
        acc2.PartnerType__c = 'Alliance Partner,Consultant Partner,Marketing';
        acc3.PartnerType__c = 'Alliance Partner,Consultant Partner,Marketing';
        acc1.Partner_Manager__c = System.UserInfo.getUserId();
         acc2.Partner_Manager__c = System.UserInfo.getUserId();
         acc3.Partner_Manager__c = System.UserInfo.getUserId();
        
        update acc1;
        update acc2;
        update acc3;
        
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Regular Lead').getRecordTypeId();
        
        Lead newAnewC = TestDataFactory.createLead();
        newAnewC.RecordTypeId = recordTypeId;
        newAnewC.Auto_Convert__c = 'Yes';
        newAnewC.Partner_Primary__c = acc1.Id;
        newAnewC.Partner_Secondary__c = acc2.Id;
        newAnewC.Partner_Tertiary__c = acc3.Id;
        newAnewC.PrimarySource__c = 'Consultant Partner	';
        newAnewC.SecondarySource__c = 'Consultant Partner	';
        newAnewC.TertiarySource__c = 'Consultant Partner	';
        
        Lead oldAnewC = TestDataFactory.createLead();
        oldAnewC.RecordTypeId = recordTypeId;
        oldAnewC.Email += 'newC';
        oldAnewC.Auto_Convert__c = 'Yes';
        oldAnewC.Partner_Primary__c = acc1.Id;
        oldAnewC.Partner_Secondary__c = acc2.Id;
        oldAnewC.Partner_Tertiary__c = acc3.Id;
        oldAnewC.PrimarySource__c = 'Consultant Partner	';
        oldAnewC.SecondarySource__c = 'Consultant Partner	';
        oldAnewC.TertiarySource__c = 'Consultant Partner	';
        
        Lead oldAOldC = TestDataFactory.createLead();
        oldAOldC.RecordTypeId = recordTypeId;
        oldAOldC.Auto_Convert__c = 'Yes';
        oldAOldC.Partner_Primary__c = acc1.Id;
        oldAOldC.Partner_Secondary__c = acc2.Id;
        oldAOldC.Partner_Tertiary__c = acc3.Id;
        oldAOldC.PrimarySource__c = 'Consultant Partner	';
		oldAOldC.SecondarySource__c = 'Consultant Partner	';
        oldAOldC.TertiarySource__c = 'Consultant Partner	';
        
        Lead newAOldC = TestDataFactory.createLead();
        newAOldC.RecordTypeId = recordTypeId;
        //newAOldC.Company += 'newA';
        newAOldC.Auto_Convert__c = 'Yes';
        newAOldC.Partner_Primary__c = acc1.Id;
        newAOldC.Partner_Secondary__c = acc2.Id;
        newAOldC.Partner_Tertiary__c = acc3.Id;
		newAOldC.PrimarySource__c = 'Consultant Partner';
        newAOldC.SecondarySource__c = 'Consultant Partner';
        newAOldC.TertiarySource__c = 'Consultant Partner';
        
        Test.startTest();
       // insert new List<Lead>{newAnewC, oldAnewC, oldAOldC, newAOldC};
        /*insert newAnewC;
        insert oldAnewC;
        insert oldAOldC;
        insert newAOldC;*/
        Test.stopTest();
    }
}