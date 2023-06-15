@isTest 
public class BillingGroupSchedulerTest {
    
    
    static testMethod void testMethod1() {
        
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
        Id accountId=Id.valueOf(accountList.Id);
        
        List<Contact> lstContacts = TestDataFactory.createContact(1, accountId);
        insert lstContacts;
        
        State__c objState = new State__c();
        objState.Active__c = true;
        objState.Country__c = 'IN';
        objState.State_Code__c = 'MH';
        insert objState;
        
        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,objState.Id);
        
        insert lstAddresses;
        
        Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12', Sale_Type__c='ZTAN'
                                         );
        
        insert product1;      
        
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        
        List<SBQQ__Quote__c> lstQuotes = TestDataFactory.createQuote( 1, accountId, lstOpportunities[0].Id);
        insert lstQuotes;
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;
        
        
        Contract contract = new Contract(Status = 'Draft' , AccountId = accountId,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                         Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = lstQuotes[0].Id,
                                         StartDate= Date.newInstance(2020,05,28),Project_Manager__c = 'Renewal gfg',last_quote__c = lstQuotes[0].Id,
                                         RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance');
        insert contract;
        
        Map<Id, SBQQ__Subscription__c> bandwidthSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> childSubMap = new Map<Id, SBQQ__Subscription__c>();
        Set<Id> billingGrpIdSet = new Set<Id>();
        Set<Id> deactivateBillingGrpIdSet = new Set<Id>();
        
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,product1.Id,contract.Id);
        bundleHeaders[0].S_No__c = '2'; 
        bundleHeaders[0].Line_Sr_No__c = '2';
        bundleHeaders[0].Line_Item_Id__c = '11112';
        bundleHeaders[0].SCF_Type__c = 'Upgrade/Downgrade';
        bundleHeaders[0].SBQQ__Quantity__c = 1;
        insert bundleHeaders;  
        
        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,product1.Id,contract.Id);
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            //objSubs1.Bill_Start_Date__c = System.today()+1;
            objSubs1.SBQQ__Bundle__c = true;
            
        }
        lstChildSubs[0].S_No__c = '1.1';
        update bundleHeaders;
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            // objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Bill_Start_Date__c = System.today() -5;
            objSubs.S_No__c = '1.2';
        }
        insert lstChildSubs;
        
        
        
        Billing_Group__c billGroup1 = new Billing_Group__c();
        billGroup1.Bill_To_Account__c = accountId;
        billGroup1.Bandwidth_Type__c = 'Burstable';
        billGroup1.Status__c = 'Active';
        billGroup1.Total_Burstable_Up_To__c = 100;
        billGroup1.Total_Contracted_Value__c = 0;
        billGroup1.Support_To_Account__c = accountId;
        billGroup1.Location__c = 'IN12';
        billGroup1.External_Id__c = accountId + '-'+ 'null'+ '-'+'IN12'+'-'+'Burstable';
        System.debug('billGroup1.External_Id__c' + billGroup1.External_Id__c);
        insert billGroup1;
        
        Test.startTest();
        
        Billing_Group__c billGroup = new Billing_Group__c();
        billGroup.Bill_To_Account__c = accountId;
        billGroup.Bandwidth_Type__c = 'Data Transfer';
        billGroup.Status__c = 'Active';
        billGroup.Total_Burstable_Up_To__c = 100;
        billGroup.Total_Contracted_Value__c = 0;
        billGroup.Support_To_Account__c = accountId;
        billGroup.Location__c = 'IN12';
        billGroup.reset__c = true;
        insert billGroup;
        
        
        
        Set<Id> contractIdSet = new Set<Id>();
        contractIdSet.add(contract.Id);
        
        for(SBQQ__Subscription__c sub: bundleHeaders){        
            bandwidthSubMap.put(sub.Id,sub);
        }
        
        for(SBQQ__Subscription__c sub: lstChildSubs){        
            childSubMap.put(sub.Id,sub);
        }
        
        
        billingGrpIdSet.add(billGroup.Id);
        deactivateBillingGrpIdSet.add(billGroup1.Id);
        
        
        BillingGroupCreateScheduler sh1 = new BillingGroupCreateScheduler(contractIdSet);
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, sh1 );
        
        SCFBillingGroupQueueableHandler updater = new SCFBillingGroupQueueableHandler (contractIdSet);
        ID jobID = System.enqueueJob(updater);
        
        BillingGroupUpdateScheduler bgSchedule = new BillingGroupUpdateScheduler(bandwidthSubMap, billingGrpIdSet, deactivateBillingGrpIdSet, childSubMap);
        bgSchedule.bandwidthSubMap = bandwidthSubMap;
        bgSchedule.childSubMap = childSubMap;
        bgSchedule.billingGrpIdSet = billingGrpIdSet;
        bgSchedule.deactivateBillingGrpIdSet = deactivateBillingGrpIdSet;
        String sch2 = '0 0 23 * * ?';
        system.schedule('Test status 2 Check', sch2, bgSchedule );
        
        system.debug('===>>>Here' + [SELECT Id FROM Billing_Group__c WHERE Id IN: billingGrpIdSet LIMIT 1]);
        
        /*BillingGroupUpdateBatch b = new BillingGroupUpdateBatch(bandwidthSubMap, billingGrpIdSet, deactivateBillingGrpIdSet, childSubMap);
        b.bandwidthSubMap = bandwidthSubMap;
b.childSubMap = childSubMap;
b.billingGrpIdSet = billingGrpIdSet;
b.deactivateBillingGrpIdSet = deactivateBillingGrpIdSet;
        Database.executeBatch(b);*/
        
        List<Contract> conList = [Select Id,EndDate from Contract];
        
        
        Test.stopTest();
    }
    
    
    
}