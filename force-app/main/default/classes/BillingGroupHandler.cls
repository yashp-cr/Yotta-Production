/* ****************************************************************************************************************
Name          : BillingGroupHandler
Description   : BillingGroupHandler Apex Class is handler class for Billing Group creation, updation, deactivation

Author        : Himanshu Maheshwari (Compro Technologies)
Creation Date : 22-May-2020
**************************************************************************************************************** */
public with sharing class BillingGroupHandler {
    /*
    * 1. Create Billing Group record
    * 2. Update Subscription record with Billing Group
    */
    public static void generateBillingGroup(List<Contract> billingGroupContractList){
        Map<String, SBQQ__Subscription__c> billingGroupSubMap = new Map<String, SBQQ__Subscription__c>();
        Map<String, Billing_Group__c> billingGroupMap = new Map<String, Billing_Group__c>();
        List<Billing_Group__c> billingGroupList = new List<Billing_Group__c>();
        Map<String, SBQQ__Subscription__c> varSubMap = new Map<String, SBQQ__Subscription__c>();
        System.debug('BillingGroupHandler Called');
        
        List<SBQQ__Subscription__c> bandwidthSubscriptionList = [SELECT Id,SCF_Type__c, S_No__c, SBQQ__RequiredById__c,Base_Value__c,SBQQ__Bundle__c, Variable_Product__c , SBQQ__ProductOption__c, SBQQ__Contract__c,Technical_Start_Date__c,Technical_End_Date__c, SBQQ__Contract__r.AccountId, SBQQ__Contract__r.Support_To_Account__c, Location__c, Billing_Group__c, SBQQ__Quantity__c, SBQQ__SegmentIndex__c, Component_Quantity__c, Burstable_Upto__c, Burstable_upto_bundle__c, SBQQ__Product__c, SBQQ__Product__r.Model_Name__c, Product_Family__c, Product_Line__c, SBQQ__ProductName__c, Bandwidth_Type__c, SBQQ__TerminatedDate__c,Status__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: billingGroupContractList AND Bandwidth_Type__c != NULL AND (SBQQ__Product__r.Model_Name__c = 'Hosted Internet Bandwidth' OR SBQQ__Product__r.Model_Name__c = 'Internet Bandwidth Usage') AND SBQQ__Quantity__c >= 0 ORDER BY Bundle_Id__c ,SBQQ__RequiredById__c NULLS LAST];
        for(SBQQ__Subscription__c sub : bandwidthSubscriptionList){
            if(sub.Bandwidth_Type__c != NULL && !sub.Variable_Product__c && !billingGroupSubMap.containsKey(sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c)){
                billingGroupSubMap.put((sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c), sub);
                System.debug('subbbbb' + sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c );
            }
            
            //  if(sub.Variable_Product__c && (sub.Bandwidth_Type__c == NULL || sub.Bandwidth_Type__c == '') && !varSubMap.containsKey(sub.SBQQ__Contract__c)){    
            if(sub.Variable_Product__c && !varSubMap.containsKey(sub.SBQQ__Contract__c) && sub.SBQQ__Bundle__c  ){  
                varSubMap.put(sub.SBQQ__Contract__c+'_' + sub.Bandwidth_Type__c, sub);
            }
        }
        
        if(billingGroupSubMap.size() > 0){
            for(Billing_Group__c billingGrp : [SELECT Id, Bandwidth_Type__c, Bill_To_Account__c, Support_To_Account__c,Valid_From__c, Location__c, Total_Contracted_Value__c, Total_Burstable_Up_To__c, External_Id__c FROM Billing_Group__c WHERE External_Id__c IN: billingGroupSubMap.keySet()]){
                billingGroupMap.put(billingGrp.External_Id__c, billingGrp);
            }
        }
        
        
        Billing_Group__c billingGrp;
        Decimal Burstablequantity = 0;
        Id BillGroupId;
        Decimal Dataquantity = 0;
        Decimal compQ = 0;
        Decimal BurstableUpto = 0;
        Decimal TotalContractedVal = 0;
        for(SBQQ__Subscription__c sub : bandwidthSubscriptionList){
            if(sub.Bandwidth_Type__c != NULL){
                System.debug('......Bandwidth_Type__c......' + sub.Bandwidth_Type__c);
                if(billingGroupMap.containsKey(sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c)){
                    billingGrp = billingGroupMap.get(sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c);
                    if(sub.SBQQ__RequiredById__c == null){
                        BillGroupId = billingGrp.Id;
                        System.debug('BillGroupId' + BillGroupId);
                        billingGrp.Contract__c = sub.SBQQ__Contract__c;
                        if(varSubMap.containsKey(sub.SBQQ__Contract__c+'_' + sub.Bandwidth_Type__c)){
                            billingGrp.Variable_Bandwidth__c = varSubMap.get(sub.SBQQ__Contract__c+'_' + sub.Bandwidth_Type__c).Id;
                        }
                    }
                }
                else{
                    billingGrp = new Billing_Group__c();
                    billingGrp.Bandwidth_Type__c = sub.Bandwidth_Type__c;
                    billingGrp.Contract__c = sub.SBQQ__Contract__c;
                    
                    if(varSubMap.containsKey(sub.SBQQ__Contract__c+'_' + sub.Bandwidth_Type__c)){
                        billingGrp.Variable_Bandwidth__c = varSubMap.get(sub.SBQQ__Contract__c+'_' + sub.Bandwidth_Type__c).Id;
                    }
                    billingGrp.Bill_To_Account__c = sub.SBQQ__Contract__r.AccountId;
                    billingGrp.Support_To_Account__c = sub.SBQQ__Contract__r.Support_To_Account__c;
                    billingGrp.Location__c = sub.Location__c;
                    billingGrp.Total_Burstable_Up_To__c = 0;
                    billingGrp.Total_Contracted_Value__c = 0;
                    billingGrp.Status__c = 'Active';
                    // billingGrp.Valid_From__c = System.today();
                    billingGrp.External_Id__c = sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c;
                    //billingGroupMap.put(billingGrp.External_Id__c, billingGrp);
                }
                
                billingGroupMap.put(billingGrp.External_Id__c, billingGrp);   
            }
            System.debug('SUB BG Before......Id: ' + sub.Id + ' BG: ' + sub.Billing_Group__c);
            if(billingGrp != NULL && sub.SBQQ__RequiredById__c == NULL && !sub.S_No__c.contains('.') && sub.Billing_Group__c == NULL && sub.SBQQ__TerminatedDate__c == NULL){
                // System.debug('......SUB BG......Id: ' + sub.Id + 'BG: ' + sub.Billing_Group__c);
                sub.Billing_Group__r = new Billing_Group__c(External_Id__c = billingGrp.External_Id__c);
            }
            System.debug('SUB BG After...... S. No.: ' + sub.S_No__c + ',BG: ' + sub.Billing_Group__c + ', Id: ' + sub.Id + ', Sub.Status: '+sub.Status__c + ', Sub.techStartDate: ' + sub.Technical_Start_Date__c);
        }
        
        if(billingGroupMap.size() > 0){
            upsert billingGroupMap.values();
        }
        
        if(bandwidthSubscriptionList.size() > 0){
            update bandwidthSubscriptionList;
        }
    
        if(BillGroupId != null){
            List<SBQQ__Subscription__c> SubList = [SELECT Id,Name,SCF_Type__c, S_No__c, SBQQ__RequiredById__c,Base_Value__c,SBQQ__Bundle__c, Variable_Product__c , SBQQ__ProductOption__c, SBQQ__Contract__c,Technical_Start_Date__c,Technical_End_Date__c, SBQQ__Contract__r.AccountId, SBQQ__Contract__r.Support_To_Account__c, Location__c, Billing_Group__c, SBQQ__Quantity__c, SBQQ__SegmentIndex__c, Component_Quantity__c, Burstable_Upto__c, Burstable_upto_bundle__c, SBQQ__Product__c, SBQQ__Product__r.Model_Name__c, Product_Family__c, Product_Line__c, SBQQ__ProductName__c, Bandwidth_Type__c, SBQQ__TerminatedDate__c,Status__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: BillGroupId AND Bandwidth_Type__c != NULL AND (SBQQ__Product__r.Model_Name__c = 'Hosted Internet Bandwidth' OR SBQQ__Product__r.Model_Name__c = 'Internet Bandwidth Usage') AND SBQQ__Quantity__c >= 0 ORDER BY Bundle_Id__c ,SBQQ__RequiredById__c NULLS LAST];
            for(SBQQ__Subscription__c sub : SubList){
                System.debug('SUB in Subs For...... S. No.: ' + sub.S_No__c + ',BG: ' + sub.Billing_Group__c + ', Id: ' + sub.Id + ', Sub.Status: '+sub.Status__c + ', Sub.techStartDate: ' + sub.Technical_Start_Date__c);
                if(sub.Bandwidth_Type__c != NULL){
                    System.debug('Sub S No. in BG calculations: ' + sub.S_No__c);
                	System.debug('......Bandwidth_Type__c......' + sub.Bandwidth_Type__c);
                    if(billingGroupMap.containsKey(sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c)){
                        billingGrp = billingGroupMap.get(sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c);
                        if(sub.SBQQ__RequiredById__c == null){                        
                            billingGrp.Status__c = 'Active';
                            billingGrp.Contract__c = sub.SBQQ__Contract__c;
                            if(varSubMap.containsKey(sub.SBQQ__Contract__c+'_' + sub.Bandwidth_Type__c)){
                                billingGrp.Variable_Bandwidth__c = varSubMap.get(sub.SBQQ__Contract__c+'_' + sub.Bandwidth_Type__c).Id;
                                System.debug('billingGrp.Variable_Bandwidth__c' + billingGrp.Variable_Bandwidth__c);
                            }
                            if(!sub.Variable_Product__c) {
                                if(sub.Status__c == 'Active'){
                                    billingGrp.Valid_From__c = sub.Technical_Start_Date__c;
                                    billingGrp.reset__c = true;
                                }
                            }
                            
                            	System.debug('SUB Before BG Calculations...... S. No.: ' + sub.Billing_Group__c + ', Id: ' + sub.Id +' Name '+ sub.Name + ', Sub.Status: '+sub.Status__c + ', Sub.techStartDate: ' + sub.Technical_Start_Date__c);
                                if(!sub.Variable_Product__c && sub.Technical_Start_Date__c != null && sub.Technical_End_Date__c == null){
                                    System.debug('Technical_Start_Date__c' + sub.Technical_Start_Date__c);
                                    if(billingGrp.Bandwidth_Type__c == 'Burstable' && sub.status__c == 'Active'){
                                        Burstablequantity += sub.Base_Value__c;
                                        System.debug('Burstable Quantity'+ Burstablequantity);
                                        billingGrp.Total_Contracted_Value__c = Burstablequantity;
                                        System.debug('Burstablequantity' + Burstablequantity);
                                    }
                                    else if(billingGrp.Bandwidth_Type__c == 'Data Transfer'){
                                        Dataquantity += sub.Base_Value__c;
                                        billingGrp.Total_Contracted_Value__c =  Dataquantity;
                                        System.debug('Dataquantity' + Dataquantity);
                                    }
                                }
                                
                                if(billingGrp.Bandwidth_Type__c == 'Burstable'){
                                    if(!sub.Variable_Product__c && sub.Technical_Start_Date__c != null && sub.Technical_End_Date__c == null){
                                        billingGrp.reset__c=true;
                                        if(compQ == 0){
                                            compQ = sub.Base_Value__c ;
                                            BurstableUpto = sub.Burstable_upto_bundle__c;
                                            System.debug('compQ' + compQ);
                                            System.debug('BurstableUpto' + BurstableUpto);
                                        } else if(compQ < sub.Base_Value__c){
                                            compQ = sub.Base_Value__c;
                                            BurstableUpto = sub.Burstable_upto_bundle__c;
                                            System.debug('compQ' + compQ);
                                            System.debug('BurstableUpto' + BurstableUpto);
                                        }
                                        billingGrp.Total_Burstable_Up_To__c = BurstableUpto;
                                    }
                                }
                            
                        }
                    }
                }
            }
        }
        
        if(billingGroupMap.size() > 0){
            upsert billingGroupMap.values();
        }
        
        if(bandwidthSubscriptionList.size() > 0){
            update bandwidthSubscriptionList;
        }
    
}

    /*
    * Update Billing Group Total Contracted Value and Total Burstable Value
    */
    public static void updateBillingGroup(Map<Id, SBQQ__Subscription__c> bandwidthSubMap, Set<Id> billingGrpIdSet, Set<Id> deactivateBillingGrpIdSet, Map<Id, SBQQ__Subscription__c> childSubMap){
        Billing_Group__c billingGrp;
        List<Billing_Group__c> billingGroupList = new List<Billing_Group__c>();
        SBQQ__Subscription__c bundleSub;
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        Map<Id,List<SBQQ__Subscription__c>> subMap = new Map<Id,List<SBQQ__Subscription__c>>();
        Set<Id> bundlesubsSet = new set<Id>();
        //Map<Id,Id> bundleBillGroupMap = new Map<Id,Id>();
        Map<Id,List<SBQQ__Subscription__c>> bundleBillGroupMap = new Map<Id,List<SBQQ__Subscription__c>>();
        Map<Id, Decimal> maxQSubMap = new  Map<Id, Decimal>();
        Decimal compQ = 0;
        Decimal BurstableUpto = 0;
        Decimal Quantity = 0;
        Integer count = 0;
        Integer ActiveBillingGroupCount=0;
        
        for(SBQQ__Subscription__c sub :[Select Id, Bandwidth_Type__c, Technical_End_Date__c,Burstable_upto_bundle__c,Base_Value__c, Billing_Group__c, SBQQ__RequiredById__c, Component_Quantity__c, S_No__c, Status__c, Technical_Start_Date__c from SBQQ__Subscription__c  WHERE Billing_Group__c IN: billingGrpIdSet and (Status__c != 'Cancelled' and Status__c != 'Decommissioned' and Status__c != 'Deactivated' and Status__c != 'Expired' and Status__c != 'Renewed' and Status__c != 'Deployment Pending')]){
            // bundleBillGroupMap.put(sub.Billing_Group__c,sub);
            System.debug('in 1st for...... S. No.: ' + sub.S_No__c + ', Id: ' + sub.Id + ', Sub.Status: '+sub.Status__c + ', Sub.techStartDate: ' + sub.Technical_Start_Date__c);
            if(sub.Technical_End_Date__c == null){ 
                if(bundleBillGroupMap.containsKey(sub.Billing_Group__c)){
                    subList = bundleBillGroupMap.get(sub.Billing_Group__c);
                    subList.add(sub) ;  
                    bundleBillGroupMap.put(sub.Billing_Group__c, subList);
                }
                else{
                    bundleBillGroupMap.put(sub.Billing_Group__c, new List<SBQQ__Subscription__c> { sub });
                }
            }
        }
        
        Map<Id, Billing_Group__c> billingGroupMap = new Map<Id, Billing_Group__c>([SELECT Id, Status__c,Valid_From__c , Bandwidth_Type__c, Contract__c, Bill_To_Account__c, Support_To_Account__c, Location__c, Total_Burstable_Up_To__c, Total_Contracted_Value__c FROM Billing_Group__c WHERE Id IN: billingGrpIdSet]);
        
        for(SBQQ__Subscription__c sub : [SELECT Id, Billing_Group__c, Base_Value__c, Component_Quantity__c,Bill_Start_Date__c, Status__c, SBQQ__RequiredById__c, Variable_Product__c, Technical_End_Date__c, Technical_Start_Date__c, SBQQ__Quantity__c, Burstable_Upto__c,Burstable_upto_bundle__c, S_No__c FROM SBQQ__Subscription__c WHERE Bandwidth_Type__c != NULL AND (Id IN: bandwidthSubMap.keySet())]){
            // System.debug('sub.SBQQ__RequiredById__c' + sub.SBQQ__RequiredById__c);
            System.debug('in 2nd for...... S. No.: ' + sub.S_No__c + ', Id: ' + sub.Id + ', Sub.Status: '+sub.Status__c + ', Sub.techStartDate: ' + sub.Technical_Start_Date__c);
            billingGrp = billingGroupMap.get(sub.Billing_Group__c);
            billingGrp.reset__c = true;

            for(SBQQ__Subscription__c su : [SELECT Id,Name,Billing_Group__c FROM SBQQ__Subscription__c where Status__c in ('Active','Deployment Pending','Under Delivery','Contracted','Under Delivery','Decommissioned','Renewed') and Id = :sub.Id and Billing_Group__c = :sub.Billing_Group__c]){
                ActiveBillingGroupCount++;
            }
            System.debug('Deactivate Billing group map'+deactivateBillingGrpIdSet);
            if(ActiveBillingGroupCount>0){
                System.debug('Inside Active');
                billingGrp.Status__c='Active';
            }else if(deactivateBillingGrpIdSet.contains(sub.Billing_Group__c) && ActiveBillingGroupCount==0){
                billingGrp.Status__c = 'Inactive';
                System.debug('Inside Inactive');
            }
            
            if(!sub.Variable_Product__c) {
                if(sub.Status__c == 'Active'){
                    billingGrp.Valid_From__c = sub.Technical_Start_Date__c;
                }
                
                if(billingGrp.Bandwidth_Type__c == 'Burstable'){

                        if (compQ < sub.Base_Value__c) {
                            compQ = sub.Base_Value__c;
                            BurstableUpto = sub.Burstable_upto_bundle__c;
                        }


                        if (sub.Technical_End_Date__c != NULL || (sub.Status__c == 'Renewed' && sub.Bill_Start_Date__c != null )) {
                            billingGrp.reset__c = true;
                            // if (sub.Technical_End_Date__c != NULL || (sub.Status__c == 'Renewed' && sub.Bill_Start_Date__c != null )) {

                            billingGrp.Total_Contracted_Value__c -= sub.Base_Value__c;
                            System.debug('sub.===' + sub.Base_Value__c);
                            System.debug('billingGrp.Total_Contracted_Value__c' + billingGrp.Total_Contracted_Value__c);
                            if (bundleBillGroupMap.size() > 0) {
                                if (billingGrp.Total_Burstable_Up_To__c == sub.Burstable_upto_bundle__c) {
                                    subList = bundleBillGroupMap.get(sub.Billing_Group__c);
                                    for (SBQQ__Subscription__c subVal : subList) {
                                        if (compQ < subVal.Base_Value__c) {
                                            compQ = subVal.Base_Value__c;
                                            billingGrp.Total_Burstable_Up_To__c = subVal.Burstable_upto_bundle__c;
                                        }
                                    }
                                    System.debug('billingGrp.Total_Contracted_Value__c' + billingGrp.Total_Burstable_Up_To__c);
                                }

                            } else {
                                billingGrp.Total_Burstable_Up_To__c = BurstableUpto;
                            }
                        } else if (sub.Status__c == 'Renewed') {
                            billingGrp.Total_Contracted_Value__c -= sub.Base_Value__c; // subtract total contracted value from billing group if it is in renewed state.
                        } else {
                            billingGrp.Total_Contracted_Value__c += sub.Base_Value__c;
                            System.debug('sub.---' + sub.Base_Value__c);
                        }

                    if(billingGrp.Total_Burstable_Up_To__c < BurstableUpto){
                        billingGrp.Total_Burstable_Up_To__c = BurstableUpto;
                    }   
                }   
                else if(billingGrp.Bandwidth_Type__c == 'Data Transfer'){
                    System.debug('Calculations Before...... S. No.: ' + sub.S_No__c + ', Id: ' + sub.Id + ', Status: '+sub.Status__c + ', techStartDate: ' + sub.Technical_Start_Date__c + ', BG Contracted Value: ' + billingGrp.Total_Contracted_Value__c);
            		System.debug('sub.Technical_End_Date__c' + sub.Technical_End_Date__c);
                    // if(sub.Technical_End_Date__c != NULL || (sub.Status__c == 'Renewed' && sub.Bill_Start_Date__c != null )){
                    if(sub.Technical_End_Date__c != NULL || (sub.Status__c == 'Renewed' && sub.Bill_Start_Date__c != null )){
                        billingGrp.reset__c = true;
                        
                        billingGrp.Total_Contracted_Value__c -= sub.Base_Value__c;
                        System.debug('sub.Base_Value__c--' + sub.Base_Value__c);
                    }
                    else {
                        //billingGrp.reset__c = true;
                        billingGrp.Total_Contracted_Value__c += sub.Base_Value__c;
                    }
                    System.debug('billingGrp.Total_Contracted_Value__c' + billingGrp.Total_Contracted_Value__c);
                }
            }
        }
        if(billingGroupMap.size() > 0){
            upsert billingGroupMap.values();
        }
    }
}