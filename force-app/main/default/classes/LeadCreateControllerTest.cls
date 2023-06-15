@isTest
public class LeadCreateControllerTest {
    
    @isTest static void testQuote(){
        
        Lead lead ;
        test.startTest();
        
        PageReference pageRef = Page.LeadCreate;
        Test.setCurrentPage(pageRef);
        
        LeadCreateController testAccPlan = new LeadCreateController();
        PageReference   objPageRef =  testAccPlan.save();

        test.stopTest();
        
    }	

}