@isTest
public class OppotunityTriggerHandlerTest {
    
    @testSetup
    public static void testDataSetup() {
        TestDataFactory.createTriggerCustomSettings();
    }
    
    public static testmethod void testOppShare() {
        Account objAcc = TestDataFactory.createAccount();
        Id oppId;
        Id SecId;
        
        objAcc.PartnerType__c = 'Alliance Partner';
        insert objAcc;
        objAcc.IsPartner = True;
        Update objAcc;
        List<Contact> objCon = TestDataFactory.createContact(1, objAcc.id);
        Insert objCon;
        
        Account objAccount = new Account();
        objAccount.Name = 'Test -' + String.valueOf(System.now().getTime());
        objAccount.New_Customer_Name__c = ' Name Test';
        objAccount.Name_Change_Effective_Date__c = System.today();
        objAccount.PartnerType__c = 'Alliance Partner';
        insert objAccount;
        objAccount.IsPartner = True;
        Update objAccount;
        
         Contact objCont = new Contact();
         objCont.FirstName = 'test';
         objCont.AccountId = objAccount.id;
         objCont.Email='test1@gmail.com';
         objCont.ContactType__c='Primary';
         objCont.LastName = 'Test1';
         objCont.Department='commercial';	
         objCont.Status__c = 'Active';
         objCont.MobilePhone = '9999998775';
                                     
          insert objCont;                                                
        
         Profile p = [Select ID, Name from Profile Where Name = 'Yotta Partners Profile'];

        user u = New User(
        UserName = 'test_' + math.random() + '@test.com',
        FirstName = 'Test-First',
        LastName = 'Test-Last',
        Alias = 'test',
        email = 'test' + math.random() + '@test.com',
        CommunityNickName = string.valueOf(math.random()).substring(0,6),
        ProfileID = p.id,
        TimeZoneSidKey = 'America/New_York', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        LanguageLocaleKey = 'en_US',
        ContactID = objCont.Id

        );

    insert u;
        
        
        Profile pro = [Select ID, Name from Profile Where Name = 'Yotta Partners Profile'];

        user us = New User(
        UserName = 'test_' + math.random() + '@test.com',
        FirstName = 'Test-First',
        LastName = 'Test-Last',
        Alias = 'test',
        email = 'test' + math.random() + '@test.com',
        CommunityNickName = string.valueOf(math.random()).substring(0,6),
        ProfileID = pro.id,
        TimeZoneSidKey = 'America/New_York', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        LanguageLocaleKey = 'en_US',
        ContactID = (Id.valueOf(objCon[0].Id))

        );

    insert us;
        
        Test.startTest();
        List<Opportunity> OppList = TestDataFactory.createOpportunity(1,objAcc.Id);
        List<Account> acc = [Select Id,name,IsPartner from Account where isPartner = true];
        System.debug('Partner Account' + acc);
        for(Opportunity objOpp:OppList ){
        oppId = objOpp.Id ;
        objOpp.SecondarySource__c = 'Alliance Partner';
        objOpp.PartnerSecondary__c =  acc[0].Id;
         objOpp.End_Customer_City__c = 'Delhi';
        objOpp.End_Customer_Address__c = 'test street';
        if(acc.size()>1)
            objOpp.TertiarySource__c = 'Alliance Partner';
            objOpp.PartnerTertiary__c =  acc[1].Id;
        }
       
        
       
        insert OppList;
        
        for(Opportunity objOp:OppList ){
                if(acc.size()>1){
                    objOp.TertiarySource__c = 'Sales';
                    objOp.PartnerTertiary__c =  null;
                }
            }
                update OppList;
                Test.stopTest();
    }

}