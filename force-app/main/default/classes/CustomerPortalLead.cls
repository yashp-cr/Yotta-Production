/**
 * Created by CloudRoute on 24-05-2022.
 */


@RestResource(urlMapping = '/CPLeadCreate/*')
global with sharing class CustomerPortalLead {

    @HttpPost
    global static void CreateLeadRecord() {
        ResponseWrapper resWrap = new ResponseWrapper();
        List<Lead> convertLeads =  new List<Lead>();

        try {
            Account AccountCreated;
            RestResponse res = RestContext.response;
            Contact ContactCreated;
            String requestBody = RestContext.request.requestBody.toString();
            LeadWrapper leadWrap = (LeadWrapper) JSON.deserialize(requestBody, LeadWrapper.class);
            /*System.debug('State ' + leadWrap);
            System.debug('Country ' + leadWrap.Country);
            State__c sat = [SELECT Id FROM State__c WHERE External_Key__c = :leadWrap.State];*/
            Lead newLead = new Lead();
            newLead.Company = leadWrap.Company;
            newLead.Email = leadWrap.Email;
            newLead.Status = leadWrap.Status;
            newLead.Industry = leadWrap.Industry;
            newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Regular Lead').getRecordTypeId();
            newLead.OnlineRegistered__c = leadWrap.OnlineRegistered;
            newLead.Country__c = leadWrap.Country;
            newLead.BillToSameasSupportTo__c = leadWrap.BillToSameasSupportTo;
            newLead.Region__c = leadWrap.Region;
            newLead.FirstName = leadWrap.FirstName;
            newLead.LastName = leadWrap.LastName;
            newLead.City__c = leadWrap.City;
            newLead.Phone = leadWrap.Phone;
            newLead.Postal_code__c = leadWrap.Postalcode;
            newLead.External_Id__c = leadWrap.ExternalId;
            newLead.Website = leadWrap.Website;
            newLead.PAN__c = leadWrap.PAN;
            newLead.Fax = leadWrap.Fax;
            newLead.Company_Type__c = leadWrap.CompanyType;
            newLead.Country_Code__c = leadWrap.CountryCode;
            newLead.Lead_Remarks__c = leadWrap.LeadRemarks;
            newLead.YottaIndustry__c = leadWrap.YottaIndustry;
            newLead.LeadContactsAuthorityLevel__c = leadWrap.LeadContactsAuthorityLevel;
            newLead.Description = leadWrap.Description;
            newLead.MobilePhone = leadWrap.MobilePhone;
            newLead.Contact_External_Id__c = leadWrap.ContactExternalId;
            newLead.Address_External_Id__c = leadWrap.AddressExternalId;
            newLead.State_External_Key__c = leadWrap.State;
            /*if (sat != null) {
                newLead.State__c = sat.Id;
            }*/

            System.debug('New Lead: --' + newLead);
            insert newLead;

            convertLeads.add(newLead);
            //Auto Lead Convert
            /*List<Database.LeadConvertResult> lcr = ConvertLead.Autoconvert(new List<Lead>{
                    newLead
            });*/

            Set<String> leadCompanies = new Set<String>();
            Set<String> leadEmails = new Set<String>();
            for(Lead l: convertLeads){
                leadCompanies.add(l.Company);
                leadEmails.add(l.Email);
            }

            List<Account> accountList = [Select id, name,(Select id, AccountId, Email from Contacts where email =: leadEmails) from Account where name =: leadCompanies];
            system.debug('accountList' + accountList);
            Map<String, Id> accountNameIdMap = new Map<String, Id>();
            Map<String, Contact> contactEmailMap = new Map<String, Contact>();
            for(Account a:accountList){
                accountNameIdMap.put(a.name.toLowercase(), a.id);
                for(Contact c: a.Contacts){
                    contactEmailMap.put(c.Email.toLowercase(), c);
                }
            }
            

            List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
            for(Lead currentlead : convertLeads){
                //if(!(accountNameIdMap.containsKey(currentlead.Company) && contactEmailMap.containsKey(currentlead.Email))){
                if(!contactEmailMap.containsKey(currentlead.Email.toLowercase()) || (contactEmailMap.containsKey(currentlead.Email.toLowercase()) && accountNameIdMap.containsKey(currentlead.Company.toLowercase()) && contactEmailMap.get(currentlead.Email.toLowercase()).AccountId == accountNameIdMap.get(currentlead.Company.toLowercase()))){
                    Database.LeadConvert Leadconvert = new Database.LeadConvert();
                    Leadconvert.setLeadId(currentlead.id);
                    Leadconvert.setConvertedStatus('Assigned to Sales');
                    if(accountNameIdMap.containsKey(currentlead.Company.toLowercase()))
                        Leadconvert.setAccountId(accountNameIdMap.get(currentlead.Company.toLowercase()));
                    if(contactEmailMap.containsKey(currentlead.Email.toLowercase()))
                        Leadconvert.setContactId(contactEmailMap.get(currentlead.Email.toLowercase()).id);
                    Leadconvert.setDoNotCreateOpportunity(TRUE);

                    MassLeadconvert.add(Leadconvert);
                }
            }
            if (!MassLeadconvert.isEmpty()) {
                List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);


                if (!lcr.isEmpty()) {
                    AccountCreated = [SELECT Id,Account_Number__c,(SELECT Id,Contact_Id__c FROM Contacts WHERE Id = :lcr[0].getContactId()) FROM Account WHERE Id = :lcr[0].getAccountId()];
                    ContactCreated = AccountCreated.Contacts;
                }
            }
            System.debug('Account Created'+AccountCreated);
            System.debug('Contact Created'+ContactCreated);
            System.debug('Account Created - Debug'+newLead.ConvertedAccount.Account_Number__c);
            System.debug('Contact Created - Debug'+newLead.ConvertedContact.Contact_Id__c);

            resWrap.Success = true;
            resWrap.Message = 'Lead Created:'+ newLead.Id;
            resWrap.LeadExternalId = newLead.External_Id__c;
            resWrap.AccountNumber = AccountCreated.Account_Number__c == null ? 'Empty' : AccountCreated.Account_Number__c;
            resWrap.ContactNumber = ContactCreated.Contact_Id__c == null ? 'Empty' : ContactCreated.Contact_Id__c;


            if(resWrap != null){
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(resWrap));
            }else{
                res.statusCode = 400;
            }

        } catch (Exception e) {
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(e.getMessage()));
        }
    }

    public class ResponseWrapper {
        public boolean Success;
        
        public String Message;
        public String LeadExternalId;
        public String AccountNumber;
        public String ContactNumber;
    }


    public class LeadWrapper {
        public String Company;    //XYZ Tests101 Company
        public String MobilePhone;    //9004732556
        public String Email;    //testv15g@gmail.com
        public String Status;    //Open
        public String Industry;    //Manufacturing
        public boolean OnlineRegistered;
        public String LeadContactsAuthorityLevel;    //Tier 1: C Level / VP IT / Director Level / Key Decision Makers
        public String YottaIndustry;    //Automotive
        public String Country;    //IN
        public String Region;    //West
        public String LeadRemarks;    //Test
        public String CountryCode;    //91
        public String CompanyType;    //Private Limited
        public String FirstName;    //Test
        public String LastName;    //Lead
        public String Vertical_Temp;    //Manufacturing
        public String Postalcode;    //421306
        public String State;    //a2I1m0000004JkMEAU
        public String City;
        public String Description;
        public String Fax;
        public String PAN;
        public String Phone;
        public String Website;
        public String ExternalId;
        public Boolean BillToSameasSupportTo;
        public String ContactExternalId;
        public String AddressExternalId;

    }

}