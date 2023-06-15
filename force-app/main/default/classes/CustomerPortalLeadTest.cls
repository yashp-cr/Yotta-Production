/*
 * Created by Swati Kannaujiya on 24-05-2022.
 */
@isTest
public class CustomerPortalLeadTest 
{
    @TestSetup
    static void makeData()
    {
        State__c state = new State__c();
        state.Name='Up';
        state.Country__c = 'IN';
        state.State_Code__c = '08';
        state.External_Key__c = 'IN-08';
        insert state;
        
        Lead objLead = new Lead(
        FirstName = 'Test',
        LastName = 'Test',
        Email = 'sandeep.CP@gmail.com',
        mobilephone = '9867050284',
        Country_Code__c = '91',
        Company = 'Cloudroute',
        Status = 'Open',
        Industry = 'IT&ITES',
        OnlineRegistered__c = true,
        LeadContactsAuthorityLevel__c = 'Tier 1: C Level / VP IT / Director Level / Key Decision Makers',
        YottaIndustry__c = 'Info Tech Services',
        Region__c = 'West',
        Lead_Remarks__c = 'Lead automatically created By Yotta MyAccount Portal',
        BillToSameasSupportTo__c = true,
        City__c = 'Mumbai',
        Country__c = 'IN',
        Vertical_Temp__c = 'BFSI',
        Postal_code__c = '400600',
        State__c = state.Id);
        insert objLead;
        
        Account acc = new Account();
        acc.Name = objLead.Company;
        insert acc;
        
        Contact con = new Contact();
        con.FirstName='Test1';
        con.LastName='Test2';
        con.Email = objLead.Email;
        con.Country_Code__c = '91';
        con.AccountId = acc.Id;
        insert con;
        
    } 
    @isTest static void positiveTest1()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //Test POST API
        req.requestURI = '/services/apexrest/CustomerPortalLead';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf('{"Company": "TECP","MobilePhone": "9867050284","Email":"sand.CP@gmail.com","Status": "Open","Industry": "IT&ITES","OnlineRegistered": true,"LeadContactsAuthorityLevel": "Tier 1: C Level / VP IT / Director Level / Key Decision Makers","YottaIndustry": "Info Tech Services","Region": "West","LeadRemarks": "Lead automatically created By Yotta MyAccount Portal","CountryCode": "91","BillToSameasSupportTo": true,"City": "mumbai","Country": "IN","FirstName": "sandeep","LastName": "mhatre","Vertical_Temp": "IT&ITES","Postalcode": "400600","State": "IN-08","ExternalId": "YMA-Vziw0FGFCZ0pbLEt"}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CustomerPortalLead.CreateLeadRecord();
        Test.stopTest();
        
        
    }
    
    @isTest static void positiveTest2()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //Test POST API
        req.requestURI = '/services/apexrest/CustomerPortalLead';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf('{"Company": "Cloudroute","MobilePhone": "9867050284","Email":"sandeep.CP@gmail.com","Status": "Open","Industry": "IT&ITES","OnlineRegistered": true,"LeadContactsAuthorityLevel": "Tier 1: C Level / VP IT / Director Level / Key Decision Makers","YottaIndustry": "Info Tech Services","Region": "West","LeadRemarks": "Lead automatically created By Yotta MyAccount Portal","CountryCode": "91","BillToSameasSupportTo": true,"City": "mumbai","Country": "IN","FirstName": "sandeep","LastName": "mhatre","Vertical_Temp": "IT&ITES","Postalcode": "400600","State": "IN-08","ExternalId": "YMA-Vziw0FGFCZ0pbLEt"}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CustomerPortalLead.CreateLeadRecord();
        Test.stopTest();
        
        
    }
    
    @isTest static void NegativeTest1()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //Test POST API
        req.requestURI = '/services/apexrest/CustomerPortalLead';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf('{"Company": "TECP","MobilePhone": "9867050284","Email":"sandeep.CP@gmail.com","Status": "Open","Industry": "IT&ITES","OnlineRegistered": true,"LeadContactsAuthorityLevel": "Tier 1: C Level / VP IT / Director Level / Key Decision Makers","YottaIndustry": "Info Tech Services","Region": "West","LeadRemarks": "Lead automatically created By Yotta MyAccount Portal","CountryCode": "91","BillToSameasSupportTo": true,"City": "mumbai","Country": "IN","FirstName": "sandeep","LastName": "mhatre","Vertical_Temp": "IT&ITES","Postalcode": "400600","State": "IN-13","ExternalId": "YMA-Vziw0FGFCZ0pbLEt"}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CustomerPortalLead.CreateLeadRecord();
        Test.stopTest();
        
        
    }

}