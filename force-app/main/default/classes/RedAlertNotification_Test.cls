@isTest
public class RedAlertNotification_Test {
@isTest
    Public static  void redAlertNotificationTest() {
      Test.startTest();
        Account acc = new Account(Name = 'cloudroute solution',Type = 'Private Limited',Industry= 'Education');
        insert acc;
        Opportunity opp = new Opportunity(  StageName = 'Qualification',       
                                                Name = 'Amendment for contract #00007239',                     
                                                Probability = 10,                           
                                                Infrastructure_Details__c = 'Test classes',
                                                CurrencyIsoCode = 'INR',
                                                TenderRFP__c = 'Yes',
                                                Promoter_s_Support_Required__c = 'No',
                                                 SupportTo__c = acc.ID,
                                                CloseDate = Date.parse('06/07/2022'),
                                                Amount = 45678,
                                                PoliticalAlignment__c = 'Positive', 
                                                SalesConfidence__c= 'Reasonably Confident',
                                                 Type = 'Existing Business', 
                                                Region__c = 'west',
                                                Vertical__c = 'Manufacturing',
                                                YottaIndustry__c = 'Apparel & Fashion',
                                                Location__c = 'IN11',
                                                PrimarySource__c='Sales',
                                                 AccountId = acc.ID);
                                               
                                                         
                 insert opp;
        RedAlertNotification.sendNotificationEmail(new List<String>{'{\"recordId\" : \"'+opp.Id+'\", \"emailBody\" : \"' + 'test' + '\"}'});
             test.stopTest();
        
          }
    
}