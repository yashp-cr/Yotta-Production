@isTest
public class ContractSCFandRenewalHandlerTest {
     @testSetup
    public static void createData(){
        
          //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
        Id accountId=Id.valueOf(accountList.Id);
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        
        State__c state = new State__c();
        state.Name = 'Delhi';
        state.State_Code__c = '101';
        state.Country__c = 'IN';
        insert state;

        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,state.id);
        insert lstAddresses;
        
         List<Contact> lstContacts = TestDataFactory.createContact(1, accountId);
        insert lstContacts;
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;
        
        Sbqq__Quote__c quote1 = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote1;
        
        List<Contract> contractList = new List<Contract>();
        Contract contract1 = new Contract( AccountId = accountId,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                         Business_Unit__c='IN10' ,SBQQ__Quote__c = quote1.Id,ContractTerm = 13,
                                         StartDate= Date.newInstance(2020,01,06),Project_Manager__c = 'Renewal Opportunity gfg',last_quote__c = quote1.Id,
                                         RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance',Status ='Draft' , SBQQ__RenewalQuoted__c =false,name = 'test',
                                        Currency_Conversion_Factor__c = 1,Bill_To_Address__c =lstAddresses[0].Id,
                                         Billing_Currency__c = 'INR',Document_Status__c='Complete',
                                         OMT_Approval_Status__c = 'Not-Submitted', Contract_Currency__c='INR',  Customer_Billing_Contact__c = lstContacts[0].Id,
                                         Customer_Authorised_Signatory__c = lstContacts[0].Id, Customer_Exec_Mgmt_Contact__c = lstContacts[0].Id, Customer_SPoC__c =lstContacts[0].Id,
                                         Customer_Tech_SPOC__c = lstContacts[0].Id,External_Id__c = '123',Contract_Number__c = '123',Is_SCF_Generated__c = true,
                                          SBQQ__AmendmentStartDate__c = quote1.SBQQ__StartDate__c,
                                         Contract_Tenure_Years__c=1, Contract_Tenure_Months__c=1, Contract_Tenure_Days__c=0,  
                                         OTC_Advance_Payment_Term_SOS__c='100%', 
                                         Credit_Period__c='7 days', SBQQ__RenewalForecast__c	=false
                                        );
        contractList.add(contract1);
        
        Contract contract2 = new Contract( AccountId = accountId,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                         Business_Unit__c='IN10' ,SBQQ__Quote__c = quote.Id,ContractTerm = 13,
                                         StartDate= Date.newInstance(2020,01,06),Project_Manager__c = 'Renewal Opportunity gfg',last_quote__c = quote.Id,
                                         RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance',Status ='Draft' , SBQQ__RenewalQuoted__c =false,name = 'test',
                                        Currency_Conversion_Factor__c = 1,Bill_To_Address__c =lstAddresses[0].Id,
                                         Billing_Currency__c = 'INR',Document_Status__c='Complete',External_Id__c = '1223',Contract_Number__c = '1223',Is_SCF_Generated__c = true,
                                          SBQQ__AmendmentStartDate__c = quote.SBQQ__StartDate__c,
                                         OMT_Approval_Status__c = 'Not-Submitted', Contract_Currency__c='INR',  Customer_Billing_Contact__c = lstContacts[0].Id,
                                         Customer_Authorised_Signatory__c = lstContacts[0].Id, Customer_Exec_Mgmt_Contact__c = lstContacts[0].Id, Customer_SPoC__c =lstContacts[0].Id,
                                         Customer_Tech_SPOC__c = lstContacts[0].Id,
                                         Contract_Tenure_Years__c=1, Contract_Tenure_Months__c=1, Contract_Tenure_Days__c=0,  
                                         OTC_Advance_Payment_Term_SOS__c='100%', 
                                         Credit_Period__c='7 days', SBQQ__RenewalForecast__c	=false
                                        );
        contractList.add(contract2);
        
        
        insert contractList;
        
         for(Opportunity opp: lstOpportunities){
            opp.SBQQ__AmendedContract__c = contractList[0].Id;
            opp.SBQQ__RenewedContract__c = contractList[0].Id;
        }
        update lstOpportunities;
        
           Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        
        insert product1;
        
         Sbqq__Dimension__c priceDimension1 =  new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'MRC',	SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        
        List<Sbqq__Dimension__c> priceDimensionList = new List<Sbqq__Dimension__c>();
        priceDimensionList.add(priceDimension1);
  
        
        
        
        
        insert priceDimensionList;
        
        quote.SBQQ__Type__c = 'Amendment';
        quote1.SBQQ__Type__c = 'Renewal';
      
        update quote;
         List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',	Service_Id__c = 'abab',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             SBQQ__Dimension__c=priceDimension1.Id,
                                                             StartMonth__c = 1
                                                            );
        parentQuoteLineList.add(parent1);
         Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',	Service_Id__c = 'abab',
                                                             SBQQ__Quote__c = quote1.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             SBQQ__Dimension__c=priceDimension1.Id,
                                                             StartMonth__c = 1
                                                            );
         parentQuoteLineList.add(parent2);
        insert parentQuoteLineList;
        
         
        
       // for(sbqq__quoteline__c qline: parentQuoteLineList){
         //   qline.SCF_Type__c = 'Address Change';
        //}                    
          //  update parentQuoteLineList;
                    
          List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(30,accountId,product1.Id,contractList[0].Id);
        insert bundleHeaders; 
        
        List<Sbqq__Subscription__c> bundleHeaders1 = TestDataFactory.createSubscription(30,accountId,product1.Id,contractList[1].Id);
        insert bundleHeaders1;
        
        for(Sbqq__Subscription__c sub: bundleHeaders){
            sub.SBQQ__Bundle__c = true;
            sub.Effective_date__c = system.today();
             
            sub.Bill_Start_Date__c = Date.newInstance(2020,01,06);
            sub.IR_Number__c = '122';
            sub.Service_Id__c ='abab';
            sub.SBQQ__RenewalQuantity__c = 2;
            sub.Technical_Start_Date__c = null;
           // sub.Sub_External_Id__c = 'aa';
        }
        for(Sbqq__Subscription__c sub: bundleHeaders1){
            sub.SBQQ__Bundle__c = true;
            sub.SCF_Type__c = 'New Line';
            sub.Status__c = 'Amendment in progress';
            sub.Effective_date__c = system.today();
            sub.Bill_Start_Date__c = Date.newInstance(2020,01,06);
            sub.IR_Number__c = '122';
            sub.Service_Id__c ='abab';
            sub.SBQQ__RenewalQuantity__c = 2;
            sub.Technical_Start_Date__c = System.today();
            sub.Bill_Start_Date__c = null;
        }
        update bundleHeaders1;
        update bundleHeaders;
        
        
       parentQuoteLineList[0].SBQQ__UpgradedSubscription__c = bundleheaders[0].Id;
       parentQuoteLineList[1].SBQQ__UpgradedSubscription__c = bundleheaders1[0].Id;
        
        update parentQuoteLineList;
        
        quote.SCF_Type__c = 'Address Change';
         quote.Original_Master_Contract_Id__c = contractList[1].Id;
              update quote;
        
        quote1.SCF_Type__c = 'Address Change';
         quote1.Original_Master_Contract_Id__c = contractList[0].Id;
              update quote1;
   
    }
    
    @isTest
    public static void ContractTriggerTest(){
        List<Contract> con = [Select Id,External_Id__c from Contract];
        List<Sbqq__quote__c> quote = [Select Id from sbqq__quote__c];
        List<Sbqq__quoteline__c> quoteline = [Select Id from sbqq__quoteline__c];
        List<Id> cont = new List<Id>();
        cont.add(con[0].Id);
        Map<Id, String> contractMap = new Map<Id, String>();
        Map<Id, String> contractMap1 = new Map<Id, String>();
        Map<Id, Id> contractQuoteIdMap = new Map<Id,Id>();
        Set<Id> conId = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> quoteLineIdSet = new Set<Id>();
        for(Contract cont1: con){
            if(cont1.External_Id__c == '1223'){
        contractMap.put(cont1.Id,'Amendment');
               
            }
            else{
               contractMap.put(cont1.Id,'Renewal'); 
            }
        conId.add(cont1.Id);
            for(Sbqq__quote__c quo: quote){
        contractQuoteIdMap.put(quo.Id,cont1.Id);
                contractMap1.put(quo.Id,'Address Change');
        quoteIdSet.add(quo.Id);
            }
        }
        for(Sbqq__quoteline__c qline: quoteline){
        quoteLineIdSet.add(qline.Id);
        
            }
        
        ContractSCFandRenewalHandler.updateContract(contractMap,contractQuoteIdMap,contractMap1);
        ContractSCFandRenewalHandler.splitQuantity(conId);
       // ContractSCFandRenewalHandler.updateContract(contractMap, contractQuoteIdMap);
        ContractSCFandRenewalHandler.updateSCFTypeRenewalContract(cont);
        ContractSCFandRenewalHandler.updateSubscriptionInfo(quoteLineIdSet);
        ContractSCFandRenewalHandler.deactivateOldContract(quoteIdSet, conId);
                   
        
    }

}