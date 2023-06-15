@isTest
public class LeadCreatePartnerControllerTest {
    
       @isTest static void testQuote(){
           
        Account acc = new Account(Name = 'Acc Name', Industry = 'Manufacturing', YottaIndustry__c = 'Automotive', Send_to_API_Layer__c = false,PartnerType__c = 'Alliance Partner');
        insert acc;
        
           
        acc = [Select Account_Number__c,Id from account where id = :acc.Id];
        
        Lead lead ;
        test.startTest(); 
        
        PageReference pageRef = Page.LeadCreatePartner;
        Test.setCurrentPage(pageRef);
        
        LeadCreatePartnerController testAccPlan = new LeadCreatePartnerController();
        testAccPlan.getAccNumber = acc.Account_Number__c;
        PageReference   objPageRef =  testAccPlan.save();

        test.stopTest();
        
    }	

}