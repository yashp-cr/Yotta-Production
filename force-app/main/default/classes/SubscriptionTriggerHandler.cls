/* ****************************************************************************************************************
Name          : SubscriptionTriggerHandler
Description   : SubscriptionTriggerHandler Apex Class is handler class for Trigger SubscriptionTrigger. It has following functions:
1. Clone Contract Record
2. Generate Contract Number, Subscription Line Sr No & Service Id
3. Trigger record push to Kafka when Subscription is updated;

Author        : Himanshu Maheshwari (Compro Technologies)
Creation Date : 22-May-2020
**************************************************************************************************************** */
public class SubscriptionTriggerHandler extends TriggerHandler {
    
    public static Map<Id, Contract> mapIdToContractKafka = new Map<Id, Contract>();
    private static List<Integration_Request_Template__mdt> lstMdtTemplate = [SELECT All_Fields__c FROM Integration_Request_Template__mdt
                                                                             WHERE DeveloperName = 'Contract_Subscription_Object' LIMIT 1];
    
    public override void beforeInsert(){
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> contractNumberSet = new Set<String>();
        Map<Id, Contract> contractSCFMap = new Map<Id, Contract>();
        for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)trigger.new){
            
             // Added a new Logic for Renewal pricing.
            if(sub.SBQQ__Dimension__c!= null){
                sub.SBQQ__RenewalPrice__c = sub.SBQQ__QuoteLine__r.SBQQ__ListPrice__c;
            }
            //Set owner same as contract owner
            if(sub.ownerid != sub.Contract_Owner_Id__c)
                sub.ownerid = sub.Contract_Owner_Id__c;
            
            if(sub.S_No__c != NULL && !sub.S_No__c.contains('.') && sub.SBQQ__Quantity__c >= 0 && sub.SCF_Type__c != '' && sub.SCF_Type__c != NULL && sub.SBQQ__RequiredById__c == NULL){
                if(!contractIdSet.contains(sub.SBQQ__Contract__c)){
                    System.debug('...>BI<...' + sub.SCF_Type__c + '...' + sub.SBQQ__QuoteLine__c);
                    contractIdSet.add(sub.SBQQ__Contract__c);
                }
                if(!contractNumberSet.contains(sub.Contract_Number__c)){
                    contractNumberSet.add(sub.Contract_Number__c);
                }
            }
            
            if(sub.S_No__c != NULL && !sub.S_No__c.contains('.') && sub.Latest_Quote_Type__c == 'Renewal' && sub.SBQQ__RequiredById__c == NULL && sub.SCF_Type__c != NULL && sub.SCF_Type__c != '' && sub.SCF_Type__c != 'New Line'){
                if(sub.Old_Sub_Bill_Start_Date__c != NULL){
                    sub.Bill_Start_Date__c = sub.SBQQ__StartDate__c;
                }
                sub.Bill_End_Date__c = sub.SBQQ__EndDate__c;
                if(sub.Old_Sub_Tech_Start_Date__c != NULL){
                    sub.Technical_Start_Date__c = sub.SBQQ__StartDate__c;
                }
                sub.Sub_External_Id__c = sub.Line_Item_Id__c;
            }
            
            if(sub.S_No__c != NULL && !sub.S_No__c.contains('.') && sub.Latest_Quote_Type__c == 'Renewal' && sub.SBQQ__RequiredById__c == NULL && (sub.SCF_Type__c == NULL || sub.SCF_Type__c == '')){
                if(sub.Old_Sub_Bill_Start_Date__c != NULL){
                    sub.Bill_Start_Date__c = sub.SBQQ__StartDate__c;
                }
                sub.Bill_End_Date__c = sub.SBQQ__EndDate__c;
                if(sub.Old_Sub_Tech_Start_Date__c != NULL){
                    sub.Technical_Start_Date__c = sub.SBQQ__StartDate__c;
                }
                sub.Sub_External_Id__c = sub.Line_Item_Id__c;
            }
        }
        
        if(contractNumberSet.size() > 0){
            updateSerialNumber(contractNumberSet);
        }
        
        computeStatus( (List<SBQQ__Subscription__c>)trigger.new, null);
    }
    
    public override void afterInsert(){
        DateTime nextExecutionDate;
        Set<Id> contractIdSet = new Set<Id>();
        Boolean checkSCF = FALSE;
        Set<Id> billingGrpContractIdSet = new Set<Id>();
        for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)trigger.new){
            if(sub.S_No__c != NULL && !sub.S_No__c.contains('.') && sub.SCF_Type__c == 'New Line' && sub.SBQQ__RequiredById__c == NULL && sub.SBQQ__Quantity__c > 1){
                contractIdSet.add(sub.SBQQ__Contract__c);
            }
            
            if(sub.SCF_Type__c == NULL && (sub.Latest_Quote_SCF_Type__c == 'Bill Cycle Change' || sub.Latest_Quote_SCF_Type__c == 'Address Change' || sub.Latest_Quote_Type__c == 'Renewal') && sub.SBQQ__RequiredById__c == NULL && sub.Bandwidth_Type__c != NULL && sub.SBQQ__Quantity__c >= 1){
                checkSCF = TRUE;
                billingGrpContractIdSet.add(sub.SBQQ__Contract__c);
               
            }
            
            if(sub.SCF_Type__c != NULL && sub.SBQQ__RequiredById__c == NULL && sub.Bandwidth_Type__c != NULL && sub.SBQQ__Quantity__c >= 1){
                billingGrpContractIdSet.add(sub.SBQQ__Contract__c);
            	System.debug('Subscription S No.' + sub.S_No__c + sub.Id);
            }
        }
        
        //Split Quantity
        if(contractIdSet.size() > 0){
            //ContractSCFandRenewalHandler.SplitQuantity(contractIdSet);
            Boolean executeGenerateBillingGroup = FALSE;
            if(billingGrpContractIdSet.size() > 0){
                executeGenerateBillingGroup = TRUE;    
            } 
            try {
                System.enqueueJob(new ContractQuantitySplitHandler(contractIdSet, executeGenerateBillingGroup));
            }catch (Exception e){
                System.debug('Exception occured  :'+e.getCause()+'  Message  :'+e.getMessage());
            }
        }
        
        if(billingGrpContractIdSet.size() > 0 && contractIdSet.size() == 0){
            BillingGroupCreateScheduler bgSchedule = new BillingGroupCreateScheduler(billingGrpContractIdSet);
            nextExecutionDate = datetime.now().addMinutes(2);
            
            String schExp = '0 ' + nextExecutionDate.minute() + ' ' + nextExecutionDate.hour() + ' ' + nextExecutionDate.day() + ' ' + nextExecutionDate.month() + ' ? ' + nextExecutionDate.year();
            System.schedule('Billing Group Create' + nextExecutionDate, schExp, bgSchedule);
        }        
    }
    
    public override void beforeUpdate(){
        Map<Id, ContractWrapper> contractWrapMap = new Map<Id, ContractWrapper>();
        ContractWrapper contractWrap;
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id, SBQQ__Subscription__c> oldMap = (Map<Id, SBQQ__Subscription__c>)Trigger.oldMap;
        Map<Id, SBQQ__Subscription__c> newMap = (Map<Id, SBQQ__Subscription__c>)Trigger.newMap;
        Boolean initiateContractNumberGeneration = FALSE;
        System.debug('......BEFORE UPDATE EXECUTED..............' + newMap.size());
        
        for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)trigger.new){
            System.debug('sub.Latest_Quote_Type__c' + sub.Latest_Quote_Type__c);
            System.debug('Contract Id :-'+sub.SBQQ__Contract__c);
            System.debug('Contract Id :-'+sub.SBQQ__Contract__r.Contract_Number__c);
            //Set owner same as contract owner
            if(sub.ownerid != sub.Contract_Owner_Id__c)
                sub.ownerid = sub.Contract_Owner_Id__c;
            
            
            if(sub.Contract_Number__c == NULL || sub.Contract_Number__c == ''){
                initiateContractNumberGeneration = TRUE;
            }
            if(sub.SBQQ__RequiredById__c == NULL && sub.SCF_Type__c != '' && sub.SCF_Type__c != NULL && sub.SBQQ__TerminatedDate__c != NULL && sub.SBQQ__TerminatedDate__c != oldMap.get(sub.Id).SBQQ__TerminatedDate__c && oldMap.get(sub.Id).SBQQ__TerminatedDate__c == NULL){
                if(sub.SCF_Type__c == 'Price Change'){
                    //sub.Status__c = 'Deactivated';
                    if(sub.Bill_Start_Date__c < sub.SBQQ__TerminatedDate__c.addDays(1)){
                        sub.Technical_End_Date__c = sub.SBQQ__TerminatedDate__c;
                        sub.Bill_End_Date__c = sub.SBQQ__TerminatedDate__c;
                    }else{
                        sub.Technical_End_Date__c = sub.Bill_Start_Date__c;
                        sub.Bill_End_Date__c = sub.Bill_Start_Date__c;
                    }
                }else{
                    sub.Status__c = 'Under Decommission';
                }
                //sub.Status__c = 'Under Decommission';
                //sub.SCF_Type__c = '';
                //sub.Effective_date__c = NULL;
            }
            
            contractIdSet.add(sub.SBQQ__Contract__c);
        }

        if(initiateContractNumberGeneration){
            Map<Id, SBQQ__Subscription__c> oldContractSubMap = new Map<Id, SBQQ__Subscription__c>();
            for(SBQQ__Subscription__c sub : [SELECT Id, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Upgraded_Subscription_Id__c, S_No__c, SCF_Type__c, Bill_Start_Date__c, Bill_End_Date__c, SBQQ__ProductName__c, Sale_Type__c, SBQQ__Contract__c,  SBQQ__Bundle__c, Business_Unit__c, Line_Sr_No__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractIdSet]){
                if(sub.SBQQ__QuoteLine__r.Upgraded_Subscription_Id__c != NULL && sub.SBQQ__QuoteLine__r.Upgraded_Subscription_Id__c != ''){
                    oldContractSubMap.put((Id)sub.SBQQ__QuoteLine__r.Upgraded_Subscription_Id__c, NULL);
                }

                if(contractWrapMap.containsKey(sub.SBQQ__Contract__c)){
                    contractWrap = contractWrapMap.get(sub.SBQQ__Contract__c);
                } else{
                    contractWrap = new ContractWrapper(sub.SBQQ__Contract__c);
                }

                //Check Subsciption Bundle Product Business Unit
                if(sub.SBQQ__Bundle__c){
                    if(sub.Business_Unit__c == 'IN10'){
                        contractWrap.isYISLLP = TRUE;

                        //Line Serial Count for SCF - New Line
                        if(!contractWrap.serialNumberYISLLPSet.contains(sub.Line_Sr_No__c) && sub.Line_Sr_No__c != NULL && sub.Line_Sr_No__c != ''){
                            contractWrap.serialNumberYISLLP++;
                            contractWrap.serialNumberYISLLPSet.add(sub.Line_Sr_No__c);
                        }

                        if(sub.Sale_Type__c == 'ZTAN'){
                            contractWrap.soeProdPresentYISLLP = TRUE;
                        }
                    } else if(sub.Business_Unit__c == 'IN20') {
                        contractWrap.isYNSL = TRUE;

                        //Line Serial Count for SCF - New Line
                        if(!contractWrap.serialNumberYSNLSet.contains(sub.Line_Sr_No__c) && sub.Line_Sr_No__c != NULL && sub.Line_Sr_No__c != ''){
                            contractWrap.serialNumberYSNL++;
                            contractWrap.serialNumberYSNLSet.add(sub.Line_Sr_No__c);
                        }

                        if(sub.Sale_Type__c == 'ZTAN'){
                            contractWrap.soeProdPresentYNSL = TRUE;
                        }
                    }
                }

                if(newMap.containsKey(sub.Id)){
                    contractWrap.subList.add(newMap.get(sub.Id));
                }

                contractWrapMap.put(sub.SBQQ__Contract__c, contractWrap);
            }

            if(oldContractSubMap.size() > 0){
                oldContractSubMap = new Map<Id, SBQQ__Subscription__c>([SELECT Id, Bill_Start_Date__c, Bill_End_Date__c, Technical_Start_Date__c, Technical_End_Date__c FROM SBQQ__Subscription__c WHERE Id IN: oldContractSubMap.keySet()]);
            }

            System.debug('......Contract Wrap Map.....' + contractWrapMap);

            //Get Existing Contract Details
            String contractQuery = 'SELECT Id, SBQQ__Quote__r.Quote__c, ' + GetObjectDetails.getObjectFieldDetails('Contract') + ' FROM Contract WHERE Id IN: contractIdSet';
            for(Contract contract : Database.query(contractQuery)){
                if(contractWrapMap.containsKey(contract.Id)){
                    contractWrap = contractWrapMap.get(contract.Id);
                    contractWrap.cntract = contract;
                }
            }

            List<Contract> contractList = new List<Contract>();
            List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
            Contract cntrct;
            Contract clonedCntrct;
            String contractNumber;

            //Create Contract Records
            for(Id contractId : contractWrapMap.keySet()){
                contractWrap = contractWrapMap.get(contractId);
                cntrct = contractWrap.cntract;

                System.debug('cntrct.Contract_Number__c' + cntrct.Contract_Number__c);
                System.debug('cntrct' + cntrct);
                System.debug('cntrct.Business_Unit__c' + cntrct.Business_Unit__c);
                if(cntrct.Contract_Number__c == NULL && cntrct.Business_Unit__c == NULL){
                    if(contractWrap.isYISLLP){
                        cntrct.Business_Unit__c = 'IN10';
                        cntrct.Contract_Number__c = cntrct.SBQQ__Quote__r.Quote__c + '1';
                        cntrct.External_Id__c = cntrct.Contract_Number__c;
                        cntrct.SOE_Product_Available__c = contractWrap.soeProdPresentYISLLP;
                        contractList.add(cntrct);
                    }

                    if(!contractWrap.isYISLLP && contractWrap.isYNSL){
                        cntrct.Business_Unit__c = 'IN20';
                        cntrct.Contract_Number__c = cntrct.SBQQ__Quote__r.Quote__c + '1';
                        cntrct.External_Id__c = cntrct.Contract_Number__c;
                        cntrct.SOE_Product_Available__c = contractWrap.soeProdPresentYNSL;
                        contractList.add(cntrct);
                    }
                    if(contractWrap.isYISLLP && contractWrap.isYNSL){
                        clonedCntrct = cntrct.clone(false, true, false, false);
                        clonedCntrct.Business_Unit__c = 'IN20';
                        clonedCntrct.Contract_Number__c = cntrct.SBQQ__Quote__r.Quote__c + '2';
                        clonedCntrct.External_Id__c = clonedCntrct.Contract_Number__c;
                        clonedCntrct.SOE_Product_Available__c = contractWrap.soeProdPresentYNSL;
                        contractWrap.clonedCntrct = clonedCntrct;
                        contractList.add(clonedCntrct);
                    }
                }
            }
            system.debug('contractList: '+contractList);

            if(contractList.size() > 0){
                upsert contractList;
            }
            system.debug('contractList: '+contractList);

            //Update Subscription records
            System.debug('...............contractWrapMap...............' + contractWrapMap);
            for(Id contractId : contractWrapMap.keySet()){
                contractWrap = contractWrapMap.get(contractId);
                cntrct = contractWrap.cntract;
                System.debug('.....SUB LIST SIZE....' + contractWrap.subList.size());

                for(SBQQ__Subscription__c sub : contractWrap.subList){
                    System.debug('sub.Latest_Quote_Type__c' + sub.Latest_Quote_Type__c);
                    contractNumber = cntrct.Contract_Number__c;
                    if(sub.Line_Sr_No__c == NULL){
                        //Update Contract Lookup
                        if(sub.Business_Unit__c == 'IN20' && contractWrap.isYISLLP){
                            if(contractWrap.clonedCntrct != NULL){
                                sub.SBQQ__Contract__c = contractWrap.clonedCntrct.Id;
                                contractNumber = contractWrap.clonedCntrct.Contract_Number__c;
                            }
                        }
                        system.debug('contractNumber: '+ contractNumber);

                        //Update Line Serial Id & Service Id
                        System.debug('sub.Latest_Quote_Type__c' + sub.Latest_Quote_Type__c);
                        if(sub.SBQQ__Bundle__c && sub.Latest_Quote_Type__c == 'Amendment'){
                            if(sub.Business_Unit__c == 'IN10'){
                                if(sub.SBQQ__RevisedSubscription__c != NULL && sub.Revised_Subscription_Line_Sr_No__c != NULL && sub.Revised_Subscription_Line_Sr_No__c != ''){
                                    sub.Line_Sr_No__c = sub.Revised_Subscription_Line_Sr_No__c;
                                    sub.Line_Item_Id__c = sub.Revised_Subscription_Line_Item_Id__c;
                                    sub.Sub_External_Id__c = sub.Line_Item_Id__c;
                                }else{
                                    sub.Line_Sr_No__c = String.valueOf(contractWrap.serialNumberYISLLP);
                                    sub.Line_Item_Id__c = contractNumber + String.valueOf(contractWrap.serialNumberYISLLP).leftPad(4, '0');
                                    sub.Sub_External_Id__c = sub.Line_Item_Id__c;
                                }

                                if(sub.Service_Id__c == NULL){
                                    if(sub.SBQQ__RevisedSubscription__c != NULL && sub.Revised_Subscription_Service_Id__c != NULL && sub.Revised_Subscription_Service_Id__c != ''){
                                        sub.Service_Id__c = sub.Revised_Subscription_Service_Id__c;
                                    }else{
                                        sub.Service_Id__c = contractNumber + String.valueOf(contractWrap.serialNumberYISLLP).leftPad(4, '0');
                                    }
                                }
                                contractWrap.serialNumberYISLLP++;
                            }else if (sub.Business_Unit__c == 'IN20'){
                                if(sub.SBQQ__RevisedSubscription__c != NULL && sub.Revised_Subscription_Line_Sr_No__c != NULL && sub.Revised_Subscription_Line_Sr_No__c != ''){
                                    sub.Line_Sr_No__c = sub.Revised_Subscription_Line_Sr_No__c;
                                    sub.Line_Item_Id__c = sub.Revised_Subscription_Line_Item_Id__c;
                                    sub.Sub_External_Id__c = sub.Line_Item_Id__c;
                                }else{
                                    sub.Line_Sr_No__c = String.valueOf(contractWrap.serialNumberYSNL);
                                    sub.Line_Item_Id__c = contractNumber + String.valueOf(contractWrap.serialNumberYSNL).leftPad(4, '0');
                                    sub.Sub_External_Id__c = sub.Line_Item_Id__c;
                                }
                                if(sub.Service_Id__c == NULL){
                                    if(sub.SBQQ__RevisedSubscription__c != NULL && sub.Revised_Subscription_Service_Id__c != NULL && sub.Revised_Subscription_Service_Id__c != ''){
                                        sub.Service_Id__c = sub.Revised_Subscription_Service_Id__c;
                                    }else{
                                        sub.Service_Id__c = contractNumber + String.valueOf(contractWrap.serialNumberYSNL).leftPad(4, '0');
                                    }
                                }
                                contractWrap.serialNumberYSNL++;
                            }

                            //For new Contract created via SCF
                            sub.Bill_End_Date__c = sub.SBQQ__EndDate__c;
                            sub.Sub_External_Id__c = sub.Line_Item_Id__c;

                            if(sub.Latest_Quote_Type__c == 'Amendment' && (sub.Latest_Quote_SCF_Type__c == 'Bill Cycle Change' || sub.Latest_Quote_SCF_Type__C == 'Address Change')){
                                if(oldContractSubMap.containsKey(sub.Upgraded_Subscription_Id__c)){
                                    //sub.Status__c = 'Active';
                                    sub.Technical_Start_Date__c = oldContractSubMap.get(sub.Upgraded_Subscription_Id__c).Technical_Start_Date__c;
                                    if(oldContractSubMap.get(sub.Upgraded_Subscription_Id__c).Bill_Start_Date__c != NULL){
                                        if(oldContractSubMap.get(sub.Upgraded_Subscription_Id__c).Bill_Start_Date__c < sub.SBQQ__SubscriptionStartDate__c){
                                            sub.Bill_Start_Date__c = sub.SBQQ__StartDate__c;
                                        }else{
                                            sub.Bill_Start_Date__c = oldContractSubMap.get(sub.Upgraded_Subscription_Id__c).Bill_Start_Date__c;
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
            }

            /* - Need to Check
                contractList = new List<Contract>();
                for(ContractWrapper contWrap : contractWrapMap.values()){
                contractList.add(contWrap.cntract);
                if(contWrap.clonedCntrct != NULL){
                contractList.add(contWrap.clonedCntrct);
                }
                }

                System.debug('...contractList.....' + contractList);
                if(contractList.size() > 0){
                update contractList;
            }*/
        }
        
        computeComponentDates( (List<SBQQ__Subscription__c>)trigger.new, (Map<Id, SBQQ__Subscription__c>)trigger.oldMap);
        computeStatus( (List<SBQQ__Subscription__c>)trigger.new, (Map<Id, SBQQ__Subscription__c>)trigger.oldMap);
    }
    
    public class ContractWrapper{
        public Id contractId;
        public Contract cntract;
        public Contract clonedCntrct;
        public Boolean isYISLLP;
        public Boolean isYNSL;
        public Integer serialNumberYISLLP;
        public Integer serialNumberYSNL;
        public Set<String> serialNumberYISLLPSet;
        public Set<String> serialNumberYSNLSet;
        List<SBQQ__Subscription__c> subList;
        public Boolean soeProdPresentYISLLP;
        public Boolean soeProdPresentYNSL;
        
        public ContractWrapper(Id contractId){
            this.contractId = contractId;
            isYNSL = FALSE;
            isYISLLP = FALSE;
            serialNumberYISLLP = 1;
            serialNumberYSNL = 1;
            soeProdPresentYISLLP = FALSE;
            soeProdPresentYNSL = FALSE;
            subList = new List<SBQQ__Subscription__c>();
            serialNumberYISLLPSet = new Set<String>();
            serialNumberYSNLSet = new Set<String>();
        }
    }
    
    public override void afterUpdate(){
        System.debug('......AFTER UPDATE EXECUTED..............');
        computeTechnicalDates( (List<SBQQ__Subscription__c>)trigger.new, (Map<Id, SBQQ__Subscription__c>)trigger.oldMap);
        computeBillStartDate( (List<SBQQ__Subscription__c>)trigger.new, (Map<Id, SBQQ__Subscription__c>)trigger.oldMap);
        computeBillEndDates( (List<SBQQ__Subscription__c>)trigger.new, (Map<Id, SBQQ__Subscription__c>)trigger.oldMap);
        computeCancellationDate( (List<SBQQ__Subscription__c>)trigger.new, (Map<Id, SBQQ__Subscription__c>)trigger.oldMap);
        
        // Map<Id, Contract> contractSCFMap = new Map<Id, Contract>();
        // Set<Id> contractIdSet = new Set<Id>();
        Map<Id, SBQQ__Subscription__c> oldMap = (Map<Id, SBQQ__Subscription__c>)trigger.oldMap;
        //List<SBQQ__Subscription__c> bandwidthSubList = new List<SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> bandwidthSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> childSubMap = new Map<Id, SBQQ__Subscription__c>();
        Set<Id> billingGrpIdSet = new Set<Id>();
        Set<Id> deactivateBillingGrpIdSet = new Set<Id>();
        
        // for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)trigger.new){
        //     if(!childSubMap.containsKey(sub.SBQQ__RequiredById__c)){
        //         childSubMap.put(sub.SBQQ__RequiredById__c, sub);
        //     } 
        //  }
        Datetime nextExecutionDateAct;
        Datetime nextExecutionDateDeAct;
        for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)trigger.new){
            if(sub.SBQQ__RequiredById__c == null){
                //if(sub.Product_Model__c == 'Hosted Internet Bandwidth' && childSubMap.containsKey(sub.Id) && childSubMap.get(sub.Id).Bandwidth_Type__c != NULL && !sub.Variable_Product__c && ((sub.Technical_Start_Date__c != NULL && sub.Technical_Start_Date__c != oldMap.get(sub.Id).Technical_Start_Date__c) || (sub.Technical_End_Date__c != NULL && sub.Technical_End_Date__c != oldMap.get(sub.Id).Technical_End_Date__c))){
                System.debug('........Sub TSD........' + sub.Id + '----' + sub.Technical_Start_Date__c + '   -   ' + oldMap.get(sub.Id).Technical_Start_Date__c);
                System.debug('........Sub BG........' + sub.Billing_Group__c);
                if(sub.Product_Model__c == 'Hosted Internet Bandwidth' && sub.Billing_Group__c != NULL && sub.Latest_Quote_SCF_Type__c != 'Bill Cycle Change' && sub.Latest_Quote_SCF_Type__c != 'Address Change'  && sub.SCF_Type__c != 'Price Change' && sub.SBQQ__Quantity__c >= 0 && !sub.Variable_Product__c && ((sub.Technical_Start_Date__c != NULL && sub.Technical_Start_Date__c != oldMap.get(sub.Id).Technical_Start_Date__c && oldMap.get(sub.Id).Technical_Start_Date__c== null)  || (sub.Technical_End_Date__c != NULL && sub.Technical_End_Date__c != oldMap.get(sub.Id).Technical_End_Date__c && oldMap.get(sub.Id).Technical_End_Date__c == null))) {
                    //bandwidthSubList.add(sub);
                    bandwidthSubMap.put(sub.Id, sub);
                    billingGrpIdSet.add(sub.Billing_Group__c);
                    if(sub.Technical_Start_Date__c != NULL && sub.Technical_Start_Date__c != oldMap.get(sub.Id).Technical_Start_Date__c && oldMap.get(sub.Id).Technical_Start_Date__c== null) {
                        nextExecutionDateAct = datetime.now().addMinutes(3);
                    }
                    if((sub.Technical_End_Date__c != NULL && sub.Technical_End_Date__c != oldMap.get(sub.Id).Technical_End_Date__c && oldMap.get(sub.Id).Technical_End_Date__c == null)){
                        nextExecutionDateDeAct = datetime.now().addMinutes(4);   
                    }
                }
                
                //if(sub.Product_Model__c == 'Internet Bandwidth Usage' && childSubMap.containsKey(sub.Id) && childSubMap.get(sub.Id).Bandwidth_Type__c != NULL && sub.Variable_Product__c && sub.Technical_End_Date__c != NULL && sub.Technical_End_Date__c != oldMap.get(sub.Id).Technical_End_Date__c){
                if(sub.Product_Model__c == 'Internet Bandwidth Usage' && sub.Billing_Group__c != NULL && sub.SBQQ__Quantity__c >= 0 && sub.Variable_Product__c && ((sub.Technical_End_Date__c != NULL && sub.Technical_End_Date__c != oldMap.get(sub.Id).Technical_End_Date__c) || (sub.Cancellation_Date__c != null && sub.Cancellation_Date__c != oldMap.get(sub.Id).Cancellation_Date__c))){
                    bandwidthSubMap.put(sub.Id, sub);
                    if(sub.SCF_Type__c != 'Price Change')
                        deactivateBillingGrpIdSet.add(sub.Billing_Group__c);
                    billingGrpIdSet.add(sub.Billing_Group__c);
                    nextExecutionDateDeAct = datetime.now().addMinutes(4);  
                }
            }
        }
        
        if(billingGrpIdSet.size() > 0 || deactivateBillingGrpIdSet.size() > 0){
            //BillingGroupHandler.updateBillingGroup(bandwidthSubMap, billingGrpIdSet, deactivateBillingGrpIdSet, childSubMap);
            if(nextExecutionDateAct != null){
                BillingGroupUpdateScheduler bgSchedule = new BillingGroupUpdateScheduler(bandwidthSubMap, billingGrpIdSet, deactivateBillingGrpIdSet, childSubMap);
                
                String schExp = '0 ' + nextExecutionDateAct.minute() + ' ' + nextExecutionDateAct.hour() + ' ' + nextExecutionDateAct.day() + ' ' + nextExecutionDateAct.month() + ' ? ' + nextExecutionDateAct.year();
                //String schExp = '0 ' + nextExecutionDate.minute() + ' ' + nextExecutionDate.hour() + ' * * ?';
                System.schedule('Billing Group Update' + nextExecutionDateAct, schExp, bgSchedule);
            }
            if(nextExecutionDateDeAct != null){
                BillingGroupUpdateScheduler bgSchedule = new BillingGroupUpdateScheduler(bandwidthSubMap, billingGrpIdSet, deactivateBillingGrpIdSet, childSubMap);
            
                String schExp = '0 ' + nextExecutionDateDeAct.minute() + ' ' + nextExecutionDateDeAct.hour() + ' ' + nextExecutionDateDeAct.day() + ' ' + nextExecutionDateDeAct.month() + ' ? ' + nextExecutionDateDeAct.year();
                //String schExp = '0 ' + nextExecutionDate.minute() + ' ' + nextExecutionDate.hour() + ' * * ?';
                system.schedule('Billing Group Update' + nextExecutionDateDeAct, schExp, bgSchedule);
            }
        }
        
        filterContractsToSendToKafka( (List<SBQQ__Subscription__c>)trigger.new, (Map<Id, SBQQ__Subscription__c>)trigger.oldMap );
        
        // for(SBQQ__Subscription__c sub : [SELECT Id, S_No__c, SCF_Type__c, SBQQ__ProductName__c, Sale_Type__c, SBQQ__Contract__c,  SBQQ__Bundle__c, Business_Unit__c, Line_Sr_No__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractIdSet]){
        //     System.debug('...CQ AU...' + sub.S_No__c + '--' + sub.SBQQ__ProductName__c + '----' + sub.SCF_Type__c);
        // }
        
        // if(contractSCFMap.size() > 0){
        //     //ContractTriggerHandler.SplitSubscriptionQuantity(contractSCFMap);
        // }
    }
    
    /* ================= Old Code of ComputeBillDates from 1st Phase of CPQ before SCF ====================
    public void computeBillDates(List<SBQQ__Subscription__c> lstTriggerNew, Map<Id, SBQQ__Subscription__c> mapTriggerOld) {
        Set<Id> contractIds = new Set<Id>();
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        List<SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>();
        Map<id, Date> contractStartDateMap = new Map<id, Date>();
        Map<id, Date> contractEndDateMap = new Map<id, Date>();
        Map<id,SBQQ__Subscription__c> parentSubMap = new Map<id,SBQQ__Subscription__c>();
        Set<id> childSubIdSet = new Set<id>();

        //---get contract ids of subscriptions whose Bill Start Dates are changed---
        for(SBQQ__Subscription__c sub : lstTriggerNew){
        if(sub.Bill_Start_Date__c != mapTriggerOld.get(sub.Id).Bill_Start_Date__c)
        contractIds.add(sub.SBQQ__Contract__c);
        }

        //---get contract & subscription records---
        contractMap = new Map<id, Contract>([select id, StartDate, EndDate, ContractTerm, StatusCode from Contract where id in: contractIds]);
        newSubList = [select id, SBQQ__ProductName__c, SBQQ__Bundle__c, SBQQ__RequiredById__c, Bill_Start_Date__c, Bill_End_Date__c, SBQQ__SubscriptionStartDate__c, SBQQ__SubscriptionEndDate__c, Technical_Start_Date__c,
        Technical_End_Date__c, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c, SBQQ__Contract__c, SBQQ__SegmentIndex__c from SBQQ__Subscription__c where SBQQ__Contract__c in :contractIds];

        for(SBQQ__Subscription__c sub:newSubList){
        if(sub.SBQQ__Bundle__c){
        if(contractMap.get(sub.SBQQ__Contract__c).StatusCode != 'Activated' && sub.Bill_Start_Date__c != null && (!contractStartDateMap.containsKey(sub.SBQQ__Contract__c) || contractStartDateMap.get(sub.SBQQ__Contract__c) > sub.Bill_Start_Date__c))
        contractStartDateMap.put(sub.SBQQ__Contract__c, sub.Bill_Start_Date__c);
        if(sub.Bill_Start_Date__c != null)
        parentSubMap.put(sub.id, sub);
        }
        }
        system.debug('contractStartDateMap: '+contractStartDateMap);
        for(Contract c : contractMap.values()){
        system.debug('Before==> ID: '+ c.id + ', Contract Term: '+ c.ContractTerm + ', Start Date: '+ c.StartDate + ', End Date: '+ c.EndDate);
        if(contractStartDateMap.containsKey(c.id))
        c.StartDate = contractStartDateMap.get(c.id);
        system.debug('After===> ID: '+ c.id + ', Contract Term: '+ c.ContractTerm + ', Start Date: '+ c.StartDate + ', End Date: '+ c.EndDate);
        contractEndDateMap.put(c.id, c.StartDate.addMonths(c.ContractTerm).addDays(-1));            
        }

        for(SBQQ__Subscription__c sub : newSubList){
        System.debug('sub.SBQQ__Bundle__c' + sub.SBQQ__Bundle__c);
        System.debug('parentSubMap.containsKey(sub.SBQQ__RequiredById__c)' + parentSubMap.containsKey(sub.SBQQ__RequiredById__c));
        if(!sub.SBQQ__Bundle__c && parentSubMap.containsKey(sub.SBQQ__RequiredById__c)){
        System.debug('sub.SBQQ__Bundle__c' + sub.SBQQ__Bundle__c);
        sub.Technical_Start_Date__c = parentSubMap.get(sub.SBQQ__RequiredById__c).Technical_Start_Date__c;
        sub.Technical_End_Date__c = parentSubMap.get(sub.SBQQ__RequiredById__c).Technical_End_Date__c;
        sub.Bill_Start_Date__c = parentSubMap.get(sub.SBQQ__RequiredById__c).Bill_Start_Date__c;
        //sub.Bill_End_Date__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
        //sub.Bill_End_Date__c = parentSubMap.get(sub.SBQQ__RequiredById__c).Bill_End_Date__c;
        sub.SBQQ__SubscriptionStartDate__c = parentSubMap.get(sub.SBQQ__RequiredById__c).SBQQ__SubscriptionStartDate__c;
        //sub.SBQQ__SubscriptionEndDate__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
        if(sub.SBQQ__SegmentIndex__c == 1)
        sub.SBQQ__SegmentStartDate__c = sub.Bill_Start_Date__c;
        else
        sub.SBQQ__SegmentStartDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate.addYears(sub.SBQQ__SegmentIndex__c.intValue()-1);
        sub.SBQQ__SegmentEndDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate.addYears(sub.SBQQ__SegmentIndex__c.intValue()).addDays(-1);
        if(sub.SBQQ__SegmentEndDate__c > contractEndDateMap.get(sub.SBQQ__Contract__c))
        sub.SBQQ__SegmentEndDate__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
        }
        else if(parentSubMap.containsKey(sub.id)){
        //sub.Bill_End_Date__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
        sub.SBQQ__SubscriptionStartDate__c = sub.Bill_Start_Date__c;
        //sub.SBQQ__SubscriptionEndDate__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
        //System.debug('Parent Finalized Billing Date' + sub.Finalized_Billing_Dates__c);
        }
        sub.Bill_End_Date__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
        sub.SBQQ__SubscriptionEndDate__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
        }

        //c.StartDate = contractBillStartDate;
        //try{
        update contractMap.values();
        update newSubList;
        //}
        //catch(exception e){
        //errorMessage = e.getMessage();
        //}
    }*/
    
    public void computeBillStartDate(List<SBQQ__Subscription__c> lstTriggerNew, Map<Id, SBQQ__Subscription__c> mapTriggerOld) {
        Set<Id> contractIds = new Set<Id>();
        Set<Id> triggerredSubIds = new Set<Id>();
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        List<Contract> updateContractList = new List<Contract>();
        List<SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> updateSubList = new List<SBQQ__Subscription__c>();
        Map<id, Date> contractStartDateMap = new Map<id, Date>();
        Map<id, Date> contractEndDateMap = new Map<id, Date>();
        Map<id,SBQQ__Subscription__c> parentSubMap = new Map<id,SBQQ__Subscription__c>();
        Map<id,SBQQ__Subscription__c> activeContractSubMap = new Map<id,SBQQ__Subscription__c>();
        Map<id,SBQQ__Subscription__c> noBSDParentSubMap = new Map<id,SBQQ__Subscription__c>();
        Set<id> childSubIdSet = new Set<id>();
        
        //---get contract ids of subscriptions whose Bill Start Dates are changed---
        System.debug(LoggingLevel.INFO, '.....EXECUTED');
        for(SBQQ__Subscription__c sub : lstTriggerNew){
            if(sub.SBQQ__Bundle__c && sub.Bill_Start_Date__c != mapTriggerOld.get(sub.Id).Bill_Start_Date__c){
                contractIds.add(sub.SBQQ__Contract__c);
                triggerredSubIds.add(sub.id);
            }
        }
        
        System.debug(LoggingLevel.INFO, '.....EXECUTED.................' + contractIds);
        if(contractIds.size() > 0){
            //---get contract & subscription records---
            contractMap = new Map<id, Contract>([select id, StartDate, EndDate, ContractTerm, StatusCode from Contract where id in: contractIds]);
            newSubList = [SELECT id, SBQQ__ProductName__c, SBQQ__Bundle__c, SBQQ__RequiredById__c, Bill_Start_Date__c, Bill_End_Date__c, SBQQ__SubscriptionStartDate__c, SBQQ__SubscriptionEndDate__c, Technical_Start_Date__c,
                          Technical_End_Date__c, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c, SBQQ__Contract__c, SBQQ__SegmentLabel__c from SBQQ__Subscription__c where SBQQ__Contract__c in :contractIds];
            
            for(SBQQ__Subscription__c sub:newSubList){
                if(sub.SBQQ__Bundle__c){
                    if(contractMap.get(sub.SBQQ__Contract__c).StatusCode != 'Activated'){
                        if(sub.Bill_Start_Date__c != null && (!contractStartDateMap.containsKey(sub.SBQQ__Contract__c) || contractStartDateMap.get(sub.SBQQ__Contract__c) > sub.Bill_Start_Date__c))
                            contractStartDateMap.put(sub.SBQQ__Contract__c, sub.Bill_Start_Date__c);
                        if(sub.Bill_Start_Date__c != null)
                            parentSubMap.put(sub.id, sub);
                        if(sub.Bill_Start_Date__c == null)
                            noBSDParentSubMap.put(sub.id, sub);
                    }
                    else if(triggerredSubIds.contains(sub.id)){
                        activeContractSubMap.put(sub.id, sub);
                    }
                }
            }
            system.debug('contractStartDateMap: '+contractStartDateMap);
            for(Contract c : contractMap.values()){
                if(contractStartDateMap.containsKey(c.id)){
                    system.debug('Before 1==> ID: '+ c.id + ', Contract Term: '+ c.ContractTerm + ', Start Date: '+ c.StartDate + ', End Date: '+ c.EndDate);
                    c.StartDate = contractStartDateMap.get(c.id);
                    c.Status = 'Activated';
                    system.debug('Before 2==> ID: '+ c.id + ', Contract Term: '+ c.ContractTerm + ', Start Date: '+ c.StartDate + ', End Date: '+ c.EndDate);
                    updateContractList.add(c);
                }
                //system.debug('After===> ID: '+ c.id + ', Contract Term: '+ c.ContractTerm + ', Start Date: '+ c.StartDate + ', End Date: '+ c.EndDate);
                contractEndDateMap.put(c.id, c.StartDate.addMonths(c.ContractTerm).addDays(-1));            
            }
            
            for(SBQQ__Subscription__c sub : newSubList){
                //System.debug('sub.SBQQ__Bundle__c' + sub.SBQQ__Bundle__c);
                //System.debug('parentSubMap.containsKey(sub.SBQQ__RequiredById__c)' + parentSubMap.containsKey(sub.SBQQ__RequiredById__c));
                //------Dates for Bundles under Active Contract where BSD is stamped in current Transaction-----
                if(activeContractSubMap.containsKey(sub.id)){
                    sub.Bill_End_Date__c = contractMap.get(sub.SBQQ__Contract__c).EndDate;
                    sub.SBQQ__SubscriptionStartDate__c = sub.Bill_Start_Date__c;
                    sub.SBQQ__SubscriptionEndDate__c = sub.Bill_End_Date__c;
                    updateSubList.add(sub);
                }
                //------Dates for components under the Bundles under Active Contract where BSD is stamped in current Transaction-----
                if(!sub.SBQQ__Bundle__c && activeContractSubMap.containsKey(sub.SBQQ__RequiredById__c)){
                    sub.Bill_Start_Date__c = activeContractSubMap.get(sub.SBQQ__RequiredById__c).Bill_Start_Date__c;
                    sub.Bill_End_Date__c = contractMap.get(sub.SBQQ__Contract__c).EndDate;
                    sub.SBQQ__SubscriptionStartDate__c = sub.Bill_Start_Date__c;
                    sub.SBQQ__SubscriptionEndDate__c = sub.Bill_End_Date__c;
                    if(sub.SBQQ__SegmentLabel__c != null && sub.SBQQ__SegmentLabel__c != ''){
                        if(Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1)) == 1)
                            sub.SBQQ__SegmentStartDate__c = sub.Bill_Start_Date__c;
                        else
                            sub.SBQQ__SegmentStartDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate.addYears(Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1))-1);
                        sub.SBQQ__SegmentEndDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate.addYears(Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1))).addDays(-1);
                        if(sub.SBQQ__SegmentEndDate__c > contractMap.get(sub.SBQQ__Contract__c).EndDate)
                            sub.SBQQ__SegmentEndDate__c = contractMap.get(sub.SBQQ__Contract__c).EndDate;
                    }
                    updateSubList.add(sub);
                }
                //------Dates for all the Bundles under Inactive Contract where BSD is stamped-----
                if(parentSubMap.containsKey(sub.id)){
                    sub.SBQQ__SubscriptionStartDate__c = sub.Bill_Start_Date__c;
                    sub.Bill_End_Date__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
                    sub.SBQQ__SubscriptionEndDate__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
                    updateSubList.add(sub);
                }
                //------Dates for all the Components under all the bundles under Inactive Contract where BSD is stamped -----
                if(!sub.SBQQ__Bundle__c && parentSubMap.containsKey(sub.SBQQ__RequiredById__c)){
                    //System.debug('sub.SBQQ__Bundle__c' + sub.SBQQ__Bundle__c);
                    /*sub.Technical_Start_Date__c = parentSubMap.get(sub.SBQQ__RequiredById__c).Technical_Start_Date__c;
                    sub.Technical_End_Date__c = parentSubMap.get(sub.SBQQ__RequiredById__c).Technical_End_Date__c;
                    */
                    sub.Bill_Start_Date__c = parentSubMap.get(sub.SBQQ__RequiredById__c).Bill_Start_Date__c;
                    sub.Bill_End_Date__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
                    sub.SBQQ__SubscriptionStartDate__c = sub.Bill_Start_Date__c;
                    sub.SBQQ__SubscriptionEndDate__c = sub.Bill_End_Date__c;
                    if(Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1)) == 1)
                        sub.SBQQ__SegmentStartDate__c = sub.Bill_Start_Date__c;
                    else
                        sub.SBQQ__SegmentStartDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate.addYears(Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1))-1);
                    sub.SBQQ__SegmentEndDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate.addYears(Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1))).addDays(-1);
                    if(sub.SBQQ__SegmentEndDate__c > contractEndDateMap.get(sub.SBQQ__Contract__c))
                        sub.SBQQ__SegmentEndDate__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
                    updateSubList.add(sub);
                }
                if(noBSDParentSubMap.containsKey(sub.id) || noBSDParentSubMap.containsKey(sub.SBQQ__RequiredById__c)){
                    System.debug('Inside NOBSD  : '+sub.id);
                    sub.Bill_End_Date__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
                    sub.SBQQ__SubscriptionStartDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate;
                    sub.SBQQ__SubscriptionEndDate__c = sub.Bill_End_Date__c;
                    try {
                        if (!sub.SBQQ__Bundle__c) {
                            System.debug('INSIDE NOBSDNOTBUNDLE  :' + sub.id);
                            if (Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1)) == 1) {

                                sub.SBQQ__SegmentStartDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate;
                                System.debug('In If Sub Details: ' + sub);
                            } else {
                                sub.SBQQ__SegmentStartDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate.addYears(Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1)) - 1);
                                System.debug('In Else Sub Details: ' + sub);
                            }
                            sub.SBQQ__SegmentEndDate__c = contractMap.get(sub.SBQQ__Contract__c).StartDate.addYears(Integer.valueOf(sub.SBQQ__SegmentLabel__c.right(1))).addDays(-1);
                            if (sub.SBQQ__SegmentEndDate__c > contractEndDateMap.get(sub.SBQQ__Contract__c))
                                sub.SBQQ__SegmentEndDate__c = contractEndDateMap.get(sub.SBQQ__Contract__c);
                        }
                        updateSubList.add(sub);
                    }catch (Exception e){
                        System.debug('Exception Occured :'+e.getLineNumber()+'  Message '+e.getMessage()+'  Cause  '+e.getCause());
                    }
                }
            }
            System.debug('.....Sub List....~~~' + updateSubList);
            System.debug('.....Contract List....~~~' + updateContractList);
            update updateContractList;
            update updateSubList;
        }
    }
    
    public void computeTechnicalDates(List<SBQQ__Subscription__c> lstTriggerNew, Map<Id, SBQQ__Subscription__c> mapTriggerOld) {
        Map<Id, SBQQ__Subscription__c> TSDChangedSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> TEDChangedSubMap = new Map<Id, SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> updateSubList = new List<SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> TEDChangedSubMap2;
        Set<String> serviceIdSet = new Set<String>();
        
        //---get ids of bundle subscriptions whose Technical Start/End Dates are changed---
        for(SBQQ__Subscription__c sub : lstTriggerNew){
            if(sub.SBQQ__Bundle__c && sub.Technical_Start_Date__c != mapTriggerOld.get(sub.Id).Technical_Start_Date__c)
                TSDChangedSubMap.put(sub.id, sub);
            if(sub.SBQQ__Bundle__c && sub.Technical_End_Date__c != mapTriggerOld.get(sub.Id).Technical_End_Date__c)
                TEDChangedSubMap.put(sub.id, sub);
        }
        
        
        if(!TSDChangedSubMap.isEmpty() || !TEDChangedSubMap.isEmpty()){
            if(!TEDChangedSubMap.isEmpty())
                TEDChangedSubMap2 = new Map<Id, SBQQ__Subscription__c>([select id, Technical_End_Date__c, SBQQ__Contract__r.Last_Quote__c, Service_Id__c from SBQQ__Subscription__c where id in :TEDChangedSubMap.keySet()]);
            //---get component subscription records---
            newSubList = [select id, SBQQ__Bundle__c, SBQQ__RequiredById__c, Technical_Start_Date__c, Technical_End_Date__c, Service_Id__c, SBQQ__QuoteLine__r.SBQQ__Quote__c  from SBQQ__Subscription__c where SBQQ__RequiredById__c in :TSDChangedSubMap.keySet() OR SBQQ__RequiredById__c in :TEDChangedSubMap.keySet() OR (Service_Id__c in :serviceIdSet and id not in :TEDChangedSubMap.keySet())];
            for(SBQQ__Subscription__c sub : newSubList){
                if(TSDChangedSubMap.keySet().contains(sub.SBQQ__RequiredById__c)){
                    sub.Technical_Start_Date__c = TSDChangedSubMap.get(sub.SBQQ__RequiredById__c).Technical_Start_Date__c;
                    updateSubList.add(sub);
                }
                if(TEDChangedSubMap.keySet().contains(sub.SBQQ__RequiredById__c)){
                    sub.Technical_End_Date__c = TEDChangedSubMap.get(sub.SBQQ__RequiredById__c).Technical_End_Date__c;
                    updateSubList.add(sub);
                }
                if(serviceIdSet.contains(sub.Service_Id__c)){
                    for (SBQQ__Subscription__c sub2 : TEDChangedSubMap2.values()) {
                        if(sub.Service_Id__c == sub2.Service_Id__c && sub.SBQQ__QuoteLine__r.SBQQ__Quote__c == sub2.SBQQ__Contract__r.Last_Quote__c){
                            sub.Technical_End_Date__c = sub2.Technical_End_Date__c;
                            updateSubList.add(sub);
                        }
                    }
                }
            }
            update updateSubList;
        }
    }
    
    public void computeBillEndDates(List<SBQQ__Subscription__c> lstTriggerNew, Map<Id, SBQQ__Subscription__c> mapTriggerOld) {
        Map<Id, SBQQ__Subscription__c> BEDChangedSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> BEDChangedSubMap2;
        List<SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> updateSubList = new List<SBQQ__Subscription__c>();
        Set<String> serviceIdSet = new Set<String>();
        
        //---get ids of bundle subscriptions whose Bill End Dates are changed---
        for(SBQQ__Subscription__c sub : lstTriggerNew){
            if(sub.SBQQ__Bundle__c && sub.Bill_End_Date__c !=null && sub.Bill_End_Date__c != mapTriggerOld.get(sub.Id).Bill_End_Date__c && sub.SBQQ__TerminatedDate__c != NULL){
                BEDChangedSubMap.put(sub.id, sub);
                serviceIdSet.add(sub.Service_Id__c);
            }
        }
        
        if(!BEDChangedSubMap.isEmpty()){
            BEDChangedSubMap2 = new Map<Id, SBQQ__Subscription__c>([select id, Bill_End_Date__c, SBQQ__Contract__r.Last_Quote__c, Service_Id__c from SBQQ__Subscription__c where id in :BEDChangedSubMap.keySet()]);
            
            //---get component subscription records and stamp Bill End Dates from their Bundles---
            newSubList = [select id, SBQQ__Bundle__c, SBQQ__RequiredById__c, Bill_End_Date__c, SBQQ__TerminatedDate__c, SBQQ__SubscriptionStartDate__c, Service_Id__c, SBQQ__QuoteLine__r.SBQQ__Quote__c from SBQQ__Subscription__c where SBQQ__TerminatedDate__c != NULL AND (id in :BEDChangedSubMap.keySet() OR SBQQ__RequiredById__c in :BEDChangedSubMap.keySet() OR Service_Id__c in :serviceIdSet)];
            for(SBQQ__Subscription__c sub : newSubList){
                if(BEDChangedSubMap.keySet().contains(sub.id)){
                    //if(sub.SBQQ__TerminatedDate__c != NULL){
                    if(sub.SBQQ__SubscriptionStartDate__c == sub.SBQQ__TerminatedDate__c.addDays(1))
                        sub.SBQQ__SubscriptionStartDate__c = sub.Bill_End_Date__c.addDays(1);
                    sub.SBQQ__TerminatedDate__c = sub.Bill_End_Date__c;
                    updateSubList.add(sub);
                    //}
                }
                else if(BEDChangedSubMap.keySet().contains(sub.SBQQ__RequiredById__c)){
                    //if(sub.SBQQ__TerminatedDate__c != NULL){
                    sub.Bill_End_Date__c = BEDChangedSubMap.get(sub.SBQQ__RequiredById__c).Bill_End_Date__c;
                    system.debug('Errored Subscription: id='+ sub.id+ ', BED='+ sub.Bill_End_Date__c+ ', Required BY='+ sub.SBQQ__RequiredById__c);
                    if(sub.SBQQ__SubscriptionStartDate__c == sub.SBQQ__TerminatedDate__c.addDays(1))
                        sub.SBQQ__SubscriptionStartDate__c = sub.Bill_End_Date__c.addDays(1);
                    sub.SBQQ__TerminatedDate__c = sub.Bill_End_Date__c;
                    updateSubList.add(sub);
                    //}
                }
                else if(serviceIdSet.contains(sub.Service_Id__c)){
                    for (SBQQ__Subscription__c sub2 : BEDChangedSubMap2.values()) {
                        if(sub.Service_Id__c == sub2.Service_Id__c && sub.SBQQ__QuoteLine__r.SBQQ__Quote__c == sub2.SBQQ__Contract__r.Last_Quote__c){
                            sub.Bill_End_Date__c = sub2.Bill_End_Date__c;
                            if(sub.SBQQ__SubscriptionStartDate__c == sub.SBQQ__TerminatedDate__c.addDays(1))
                                sub.SBQQ__SubscriptionStartDate__c = sub.Bill_End_Date__c.addDays(1);
                            sub.SBQQ__TerminatedDate__c = sub.Bill_End_Date__c;
                            updateSubList.add(sub);
                        }
                    }
                }
            }
            update updateSubList;
        }
    }
    
    public void computeCancellationDate(List<SBQQ__Subscription__c> lstTriggerNew, Map<Id, SBQQ__Subscription__c> mapTriggerOld) {
        Map<Id, SBQQ__Subscription__c> CancellationDateSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> CancellationDateSubMap2;
        List<SBQQ__Subscription__c> newSubList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> updateSubList = new List<SBQQ__Subscription__c>();
        Set<String> serviceIdSet = new Set<String>();
        
        //---get ids of bundle subscriptions where Cancellation Date is populated from Tussom---
        for(SBQQ__Subscription__c sub : lstTriggerNew){
            if(sub.SBQQ__Bundle__c && mapTriggerOld.get(sub.Id).Cancellation_Date__c == null && sub.Cancellation_Date__c != null)
            {
                CancellationDateSubMap.put(sub.id, sub);
                serviceIdSet.add(sub.Service_Id__c);
            }
        }
        
        if(!CancellationDateSubMap.isEmpty()){
            CancellationDateSubMap2 = new Map<Id, SBQQ__Subscription__c>([select id, Cancellation_Date__c, SBQQ__Contract__r.Last_Quote__c, Service_Id__c from SBQQ__Subscription__c where id in :CancellationDateSubMap.keySet()]);
            //---get component subscription records and stamp Bill End Dates from their Bundles---
            newSubList = [select id, Status__c, SBQQ__Bundle__c, SBQQ__RequiredById__c, Bill_End_Date__c, SBQQ__TerminatedDate__c, Cancellation_Date__c, SBQQ__SubscriptionStartDate__c, Service_Id__c, SBQQ__QuoteLine__r.SBQQ__Quote__c from SBQQ__Subscription__c where SBQQ__TerminatedDate__c != NULL AND (id in :CancellationDateSubMap.keySet() OR SBQQ__RequiredById__c in :CancellationDateSubMap.keySet() OR Service_Id__c in :serviceIdSet)];
            for(SBQQ__Subscription__c sub : newSubList){
                if(CancellationDateSubMap.keySet().contains(sub.id)){
                    //if(sub.SBQQ__TerminatedDate__c != NULL){
                    //sub.Bill_End_Date__c = sub.Cancellation_Date__c;
                    if(sub.SBQQ__SubscriptionStartDate__c == sub.SBQQ__TerminatedDate__c.addDays(1))
                        sub.SBQQ__SubscriptionStartDate__c = sub.Cancellation_Date__c.addDays(1);
                    sub.SBQQ__TerminatedDate__c = sub.Cancellation_Date__c;
                    sub.Status__c = 'Cancelled';
                    updateSubList.add(sub);
                    //}
                }
                else if(CancellationDateSubMap.keySet().contains(sub.SBQQ__RequiredById__c)){
                    //if(sub.SBQQ__TerminatedDate__c != NULL){
                    sub.Cancellation_Date__c = CancellationDateSubMap.get(sub.SBQQ__RequiredById__c).Cancellation_Date__c;
                    if(sub.SBQQ__SubscriptionStartDate__c == sub.SBQQ__TerminatedDate__c.addDays(1))
                        sub.SBQQ__SubscriptionStartDate__c = CancellationDateSubMap.get(sub.SBQQ__RequiredById__c).Cancellation_Date__c.addDays(1);
                    sub.SBQQ__TerminatedDate__c = sub.Cancellation_Date__c;
                    sub.Status__c = 'Cancelled';
                    updateSubList.add(sub);
                    //}
                }
                else if(serviceIdSet.contains(sub.Service_Id__c)){
                    for (SBQQ__Subscription__c sub2 : CancellationDateSubMap2.values()) {
                        if(sub.Service_Id__c == sub2.Service_Id__c && sub.SBQQ__QuoteLine__r.SBQQ__Quote__c == sub2.SBQQ__Contract__r.Last_Quote__c){
                            sub.Cancellation_Date__c = sub2.Cancellation_Date__c;
                            if(sub.SBQQ__SubscriptionStartDate__c == sub.SBQQ__TerminatedDate__c.addDays(1))
                                sub.SBQQ__SubscriptionStartDate__c = sub.Cancellation_Date__c.addDays(1);
                            sub.SBQQ__TerminatedDate__c = sub.Cancellation_Date__c;
                            sub.Status__c = 'Cancelled';
                            updateSubList.add(sub);
                        }
                    }
                }
            }
            update updateSubList;
        }
    }
    
    //================= Compute Dates on Components if BSD, BED & TSD are populated on the Bundle on Creation ==================
    //========== Especially on Price Change SCF, Bill Address Change SCF, Bill Cycle Change SCF and Renewal Contracts ==========
    public void computeComponentDates(List<SBQQ__Subscription__c> lstTriggerNew, Map<Id, SBQQ__Subscription__c> mapTriggerOld) {
        System.debug('......computeComponentDates EXECUTED..............');
        //Map<Id, SBQQ__Subscription__c> ComponentSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> BundleSubMap = new Map<Id, SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> componentSubList = new List<SBQQ__Subscription__c>();
        Set<Id> bundleIdSet = new Set<Id>();
        
        //---get ids of Component subscriptions where RequiredById is populated in current transaction---
        for(SBQQ__Subscription__c sub : lstTriggerNew){
            System.debug(LoggingLevel.INFO, '......SUB Details..............' + sub.SBQQ__ProductName__c + '---' + sub.SBQQ__Bundle__c + '---' + mapTriggerOld.get(sub.Id).SBQQ__RequiredById__c + '---' + sub.SBQQ__RequiredById__c);
            if(!sub.SBQQ__Bundle__c && mapTriggerOld.get(sub.Id).SBQQ__RequiredById__c == null && sub.SBQQ__RequiredById__c != null){
                System.debug('......SUB Details..............' + sub.SBQQ__Bundle__c + '---' + mapTriggerOld.get(sub.Id).SBQQ__RequiredById__c + '---' + sub.SBQQ__RequiredById__c);
                //ComponentSubMap.put(sub.SBQQ__RequiredById__c, sub);
                componentSubList.add(sub);
                bundleIdSet.add(sub.SBQQ__RequiredById__c);
            }
        }
        
        if(!componentSubList.isEmpty()){
            //---get Bundle subscription records and stamp Dates on their Components---
            BundleSubMap = new Map<Id, SBQQ__Subscription__c>([select id, Bill_Start_Date__c, Bill_End_Date__c, SBQQ__SubscriptionStartDate__c, SBQQ__SubscriptionEndDate__c, Technical_Start_Date__c, Technical_End_Date__c from SBQQ__Subscription__c where id in : bundleIdSet and (Bill_Start_Date__c!=null or Bill_End_Date__c!=null or Technical_Start_Date__c!=null or Technical_End_Date__c!=null)]);
            if(!BundleSubMap.isEmpty()){
                for(SBQQ__Subscription__c sub : componentSubList){
                    if(BundleSubMap.keySet().contains(sub.SBQQ__RequiredById__c)){
                        if(BundleSubMap.get(sub.SBQQ__RequiredById__c).Technical_Start_Date__c!=null)
                            sub.Technical_Start_Date__c = BundleSubMap.get(sub.SBQQ__RequiredById__c).Technical_Start_Date__c;
                        if(BundleSubMap.get(sub.SBQQ__RequiredById__c).Bill_Start_Date__c!=null)
                            sub.Bill_Start_Date__c = BundleSubMap.get(sub.SBQQ__RequiredById__c).Bill_Start_Date__c;
                        if(BundleSubMap.get(sub.SBQQ__RequiredById__c).SBQQ__SubscriptionStartDate__c!=null)
                            sub.SBQQ__SubscriptionStartDate__c = BundleSubMap.get(sub.SBQQ__RequiredById__c).SBQQ__SubscriptionStartDate__c;
                        if(BundleSubMap.get(sub.SBQQ__RequiredById__c).SBQQ__SubscriptionEndDate__c!=null)
                            sub.SBQQ__SubscriptionEndDate__c = BundleSubMap.get(sub.SBQQ__RequiredById__c).SBQQ__SubscriptionEndDate__c;
                        if(BundleSubMap.get(sub.SBQQ__RequiredById__c).Technical_End_Date__c!=null)
                            sub.Technical_End_Date__c = BundleSubMap.get(sub.SBQQ__RequiredById__c).Technical_End_Date__c;
                        if(BundleSubMap.get(sub.SBQQ__RequiredById__c).Bill_End_Date__c!=null)
                            sub.Bill_End_Date__c = BundleSubMap.get(sub.SBQQ__RequiredById__c).Bill_End_Date__c;
                    }
                }
            }
        }
    }
    
    public void computeStatus(List<SBQQ__Subscription__c> lstTriggerNew, Map<Id, SBQQ__Subscription__c> mapTriggerOld) {
        for(SBQQ__Subscription__c sub : lstTriggerNew){
            if(mapTriggerOld != null){
                //====Mark Status Decommissioned on TED update=====
                if(sub.Technical_End_Date__c != null && mapTriggerOld.get(sub.id).Technical_End_Date__c == null && sub.SBQQ__TerminatedDate__c != null && sub.Status__c!='Deactivated')
                    sub.Status__c='Decommissioned';
                
                //====Mark Status Under Delivery on IR Number update=====
                if(sub.IR_Number__c != null && mapTriggerOld.get(sub.id).IR_Number__c == null && sub.Technical_Start_Date__c == null)
                    sub.Status__c='Under Delivery';
                
                //====Mark Status Commission on TSD update=====
                if(sub.Technical_Start_Date__c != null && mapTriggerOld.get(sub.id).Technical_Start_Date__c == null && sub.Bill_Start_Date__c == null && sub.SBQQ__TerminatedDate__c==null)
                    sub.Status__c='Commission';
                
                //====Mark Status Active on BSD update====
                if(sub.Bill_Start_Date__c != null && mapTriggerOld.get(sub.id).Bill_Start_Date__c == null  && sub.SBQQ__TerminatedDate__c==null)
                    sub.Status__c='Active';
            } else{
                //====Mark Status Commission=====
                if(sub.Technical_Start_Date__c != null && sub.Bill_Start_Date__c == null  && sub.SBQQ__TerminatedDate__c==null)
                    sub.Status__c='Commission';
                
                //====Mark Status Active====
                if(sub.Bill_Start_Date__c != null && sub.SBQQ__TerminatedDate__c==null)
                    sub.Status__c='Active';
            }
        }
    }
    
    
    //checks if value for a particular field has changed
    public Boolean isUpdated(Id recordId, String fieldName){
        //Anupam: Please change Trigger.oldMap and Trigger.newMap references. Please pass lstTriggerNew and mapTriggerOld variables instead.
        Object oldValue = (Object)((SBQQ__Subscription__c)(Trigger.oldMap.get(recordId))).get(fieldName);
        Object newValue = (Object)((SBQQ__Subscription__c)(Trigger.newMap.get(recordId))).get(fieldName);
        if(oldValue != newValue)
            return true;
        else
            return false;
    }
    
    private Boolean isFieldChanged( SBQQ__Subscription__c sObjNew, SBQQ__Subscription__c sObjOld) {
        /*if( !Boolean.valueOf(sObj.get('Is_Ready_for_Integration__c'))) {
        return false;
        } else {
        if( trigger.isInsert ) {
        return true;
        }
        }*/
                /*for(String fieldName : setFields ){
        if(!String.isBlank(fieldName.trim()) && !fieldName.contains('.') && isUpdated(sObj.Id, fieldName.trim())){
        return true;  
        }
        }*/
        return (sObjNew.Bill_Start_Date__c != sObjOld.Bill_Start_Date__c) || (sObjNew.Bill_End_Date__c != sObjOld.Bill_End_Date__c) ||
            (sObjNew.Technical_Start_Date__c != sObjOld.Technical_Start_Date__c) || (sObjNew.Technical_End_Date__c != sObjOld.Technical_End_Date__c) ||
            (sObjNew.Cancellation_Date__c != sObjOld.Cancellation_Date__c) || (sObjNew.Status__c != sObjOld.Status__c);
    }
    
    private void filterContractsToSendToKafka( List<SBQQ__Subscription__c> lstTriggerNew, Map<Id, SBQQ__Subscription__c> mapTriggerOld ) {
        mapIdToContractKafka = new Map<Id, Contract>();
        for( SBQQ__Subscription__c objSubscription : lstTriggerNew ) {
            SBQQ__Subscription__c objNewSubscription = objSubscription;
            SBQQ__Subscription__c objOldSubscription = mapTriggerOld.get( objSubscription.Id );
            if( isFieldChanged(objSubscription, objOldSubscription) ) {
                mapIdToContractKafka.put(objSubscription.SBQQ__Contract__c, new Contract( Id=objSubscription.SBQQ__Contract__c,  Send_To_API_Layer__c=TRUE));
            }
        } 
        if( !mapIdToContractKafka.isEmpty() ) {
            update mapIdToContractKafka.values();
        }
    }
    
    /*
    * Update Serial Number on Amemdment contract on same contract
    */
    public static void updateSerialNumber(Set<String> contractIdSet){
        Map<String, Integer> lineitemNumberMap = new Map<String, Integer>();
        Map<String, SBQQ__Subscription__c> oldSubMap = new Map<String, SBQQ__Subscription__c>();
        
        List<SBQQ__Subscription__c> subList = [SELECT Id, SCF_Type__c,Contract_Number__c, SBQQ__Quantity__c, Bill_Start_Date__c, Bill_End_Date__c, Technical_Start_Date__c, Technical_End_Date__c, SBQQ__Contract__c, SBQQ__ProductName__c, Line_Item_Id__c, Line_Sr_No__c, Service_Id__c, Sub_External_Id__c, Line_Sr_No_Formula__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__r.Contract_Number__c IN: contractIdSet AND SBQQ__RequiredById__c = NULL ORDER BY Line_Sr_No_Formula__c NULLS LAST];
        
        for(SBQQ__Subscription__c sub : subList){
            if(!lineitemNumberMap.containsKey(sub.Contract_Number__c)){
                lineitemNumberMap.put(sub.Contract_Number__c, 0);
            }
            
            if(sub.Line_Sr_No__c != NULL && sub.Line_Sr_No__c != ''){
                lineitemNumberMap.put(sub.Contract_Number__c, Integer.valueOf(sub.Line_Sr_No__c));
            }
            
            if(sub.SCF_Type__c == 'Price Change' && sub.SBQQ__Quantity__c > 0){
                oldSubMap.put(sub.Service_Id__c, sub);
            }
        }
        
        if(lineitemNumberMap.size() == 0){
            for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)trigger.new){
                if(!sub.S_No__c.contains('.') && sub.Line_Sr_No__c != NULL){
                    if(lineitemNumberMap.containsKey(sub.Contract_Number__c)){
                        if(sub.Line_Sr_No_Formula__c > lineitemNumberMap.get(sub.Contract_Number__c)){
                            lineitemNumberMap.put(sub.Contract_Number__c, Integer.valueOf(sub.Line_Sr_No__c));
                        }
                    }else{
                        lineitemNumberMap.put(sub.Contract_Number__c, Integer.valueOf(sub.Line_Sr_No__c));
                    }
                    
                    if(sub.SCF_Type__c == 'Price Change' && sub.Latest_Quote_Type__c == 'Renewal' && sub.SBQQ__Quantity__c == 0){
                        oldSubMap.put(sub.Service_Id__c, sub);
                    }
                }
            }
        }
        
        System.debug('...Line Map...' + lineitemNumberMap);
        System.debug('...Price Change Map...' + oldSubMap);
        Integer lineSrNo;
        if(lineitemNumberMap.size() > 0){
            for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)trigger.new){
                if(!sub.S_No__c.contains('.') && sub.SCF_Type__c != '' && sub.SBQQ__RequiredById__c == NULL && sub.Line_Sr_No__c == NULL){
                    if(lineitemNumberMap.containsKey(sub.Contract_Number__c)){
                        lineSrNo = lineitemNumberMap.get(sub.Contract_Number__c) + 1;
                        sub.Line_Sr_No__c = String.valueOf(lineSrNo);
                        sub.Line_Item_Id__c = sub.Contract_Number__c + String.valueOf(lineSrNo).leftPad(4, '0');
                        sub.Sub_External_Id__c = sub.Line_Item_Id__c;
                        sub.Status__c = 'Deployment Pending';
                        
                        if(sub.Service_Id__c == NULL){
                            sub.Service_Id__c = sub.Line_Item_Id__c;
                        }
                        
                        lineitemNumberMap.put(sub.Contract_Number__c, lineSrNo);
                    }
                }
                
                if(!sub.S_No__c.contains('.') && sub.SCF_Type__c == 'Price Change' && sub.SBQQ__RequiredById__c == NULL){
                    if(sub.Latest_Quote_Type__c == 'Amendment'){
                        if(oldSubMap.containsKey(sub.Service_Id__c) && sub.SBQQ__OriginalQuoteLine__c == NULL){
                            // Commented due to SIT requirement, Downstream System need new External Id for new line.
                            //sub.Sub_External_Id__c = sub.Line_Item_Id__c;
                            sub.Technical_Start_Date__c = oldSubMap.get(sub.Service_Id__c).Technical_Start_Date__c;
                            if(oldSubMap.get(sub.Service_Id__c).Bill_Start_Date__c < sub.SBQQ__SubscriptionStartDate__c){
                                sub.Bill_Start_Date__c = sub.SBQQ__SubscriptionStartDate__c;
                            }else{
                                sub.Bill_Start_Date__c = oldSubMap.get(sub.Service_Id__c).Bill_Start_Date__c;
                            }
                            sub.Bill_End_Date__c = oldSubMap.get(sub.Service_Id__c).Bill_End_Date__c;
                        }
                    }
                }
                
                /*
                if(sub.Latest_Quote_Type__c == 'Renewal' && sub.SBQQ__Quantity__c > 0){
                    if(sub.SCF_Type__c == 'Price Change' || sub.Required_By_SCF_Type__c == 'Price Change'){
                        sub.Technical_Start_Date__c = sub.SBQQ__StartDate__c;
                        sub.Bill_Start_Date__c = sub.SBQQ__StartDate__c;
                        sub.Bill_End_Date__c = sub.SBQQ__EndDate__c;
                    }
                }

                if(sub.Latest_Quote_Type__c == 'Renewal' && sub.SBQQ__Quantity__c == 0){
                    sub.SBQQ__TerminatedDate__c = sub.SBQQ__StartDate__c;
                    if(sub.SCF_Type__c == 'Price Change' || sub.Required_By_SCF_Type__c == 'Price Change'){
                        sub.Bill_End_Date__c = sub.SBQQ__StartDate__c;
                        sub.Technical_End_Date__c = sub.SBQQ__StartDate__c;
                    }
                }
                */
                
                if(!sub.S_No__c.contains('.') && sub.Latest_Quote_Type__c == 'Renewal' && sub.SBQQ__Quantity__c > 0){
                    if(sub.SCF_Type__c == 'Price Change'){
                        sub.Technical_Start_Date__c = sub.SBQQ__StartDate__c;
                        sub.Bill_Start_Date__c = sub.SBQQ__StartDate__c;
                        sub.Bill_End_Date__c = sub.SBQQ__EndDate__c;
                    }
                }
                
                if(sub.Latest_Quote_Type__c == 'Renewal' && sub.SBQQ__Quantity__c == 0){
                    sub.SBQQ__TerminatedDate__c = sub.SBQQ__StartDate__c;
                    if(!sub.S_No__c.contains('.') && sub.SCF_Type__c == 'Price Change'){
                        sub.Bill_End_Date__c = sub.SBQQ__StartDate__c;
                        sub.Technical_End_Date__c = sub.SBQQ__StartDate__c;
                    }
                }
                
                if(!sub.S_No__c.contains('.') && sub.SCF_Type__c != '' && sub.SBQQ__RequiredById__c == NULL && sub.SBQQ__TerminatedDate__c != NULL){
                    if(sub.SCF_Type__c == 'Price Change'){
                        sub.Status__c = 'Deactivated';
                    }else{
                        sub.Status__c = 'Under Decommission';
                    }
                }
            }
        }
    }
}