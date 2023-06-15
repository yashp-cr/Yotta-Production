@isTest
public class OpportunityTriggerHandlerTest {
    
    @testSetup
    public static void testDataSetup() {
        TestDataFactory.createTriggerCustomSettings();
    }
    
    public static testmethod void testOppShare() {
        Account objAcc = TestDataFactory.createAccount();
        Id oppId;
        Id SecId;
        
        objAcc.PartnerType__c = 'Alliance Partner';
        objAcc.Partner_Manager__c = '0052u000000Ehr2AAC';
        insert objAcc;
        objAcc.IsPartner = True;
        Update objAcc;
        
        Contact objCon = new Contact();
        objCon.AccountId = objAcc.id;
        objCon.Email='test@gmail.com';
        objCon.ContactType__c='Primary';
        objCon.FirstName = 'Test';
        objCon.LastName = 'Test';
        objCon.Department='commercial';	
        objCon.Status__c = 'Active';
        objCon.MobilePhone = '9999998875';
        
        insert objCon;
        
        Account objAccount = new Account();
        objAccount.Name = 'Test -' + String.valueOf(System.now().getTime());
        // objAccount.New_Customer_Name__c = ' Name Test';
        //objAccount.Name_Change_Effective_Date__c = System.today();
        objAccount.PartnerType__c = 'Alliance Partner';
        objAccount.Partner_Manager__c = objAcc.Partner_Manager__c;
        insert objAccount;
        objAccount.IsPartner = True;
        Update objAccount;
        
        Contact objCont = new Contact();
        objCont.AccountId = objAccount.id;
        objCont.Email='test1@gmail.com';
        objCont.ContactType__c='Primary';
        objCont.FirstName = 'Test';
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
            ContactID = objCon.Id
            
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
            objOpp.End_Customer_Address__c = 'Mumbai';
            objOpp.End_Customer_City__c = 'Mumbai';
            objOpp.Partner_Commision_Model__c = 'TP';
           
            
            if(acc.size()>1){
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
            
            
            
            /* SBQQ__Quote__c Quote = new SBQQ__Quote__c();
             Quote.Use_Transfer_Price__c = true;
             Quote.Partner_Commision_Model__c = 'TP';
             Quote.SBQQ__Primary__c = true ;
             Quote.SBQQ__Opportunity2__c = objOpp.Id;
             Quote.SBQQ__Type__c = 'Amendment';
             insert Quote;
            
             Opportunity opp = new Opportunity();
             opp.SBQQ__PrimaryQuote__c = Quote.SBQQ__Type__c;
             insert opp; */
           
                Test.stopTest();
            }
        }
        
        
    }