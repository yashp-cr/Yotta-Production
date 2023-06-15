/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-15-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-15-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class GenerateContract {

    @AuraEnabled
    public static void createContract(Id quoteId) {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c, POC__c,Contracted__c,Validate_Commission_Model__c,SBQQ__Opportunity2__r.Partner_Commision_Model__c,Partner_Commision_Model__c, SBQQ__Status__c, SBQQ__Type__c, SCF_Type__c,SBQQ__Opportunity2__r.POC_Stage__c,SBQQ__Opportunity2__r.Approx_Order_Value__c,SBQQ__Opportunity2__r.POC__c,SBQQ__Opportunity2__r.StageName FROM SBQQ__Quote__c WHERE Id =: quoteId];
        if(quote != NULL){
            String query;

            if(quote.SBQQ__Type__c == 'Quote'){
                query = 'SELECT Id FROM Document__c WHERE Object__c = \'Quote\' AND Quote__c =: quoteId AND Document_Category__c = \'Quote\' AND Document__c = \'Proposal Quote\'';
            }else if(quote.SBQQ__Type__c == 'Amendment'){
                query = 'SELECT Id FROM Document__c WHERE Object__c = \'Quote\' AND Quote__c =: quoteId AND Document_Category__c = \'SCF\' AND Document__c = \'SCF Quote\'';
            }else if(quote.SBQQ__Type__c == 'Renewal'){
                query = 'SELECT Id FROM Document__c WHERE Object__c = \'Quote\' AND Quote__c =: quoteId AND Document_Category__c = \'Quote\' AND Document__c = \'Renewal Quote\'';
            }

            List<Document__c> docuList = Database.query(query);
            System.debug('DocuList :'+ docuList);


            if(docuList.size() == 0 && quote.SBQQ__Type__c != 'Amendment' && quote.SBQQ__Type__c != 'Renewal'){
                throw new AuraHandledException('Please generate and send Quote PDF before generating the Contract');
            }
            if(quote.POC__c == 'Yes' && quote.SBQQ__Opportunity2__r.POC__c == 'Yes' && (quote.SBQQ__Opportunity2__r.POC_Stage__c == null || quote.SBQQ__Opportunity2__r.Approx_Order_Value__c == null))
            {
                throw new AuraHandledException('Please Select POC Stage and Approx Order Value in Opportunity');
            }
        }

        //Check for Variable Bandwidth Product
        GenerateContract.checkVariableBandwidthProduct(quote);
        //Check for optional/inactive product
        GenerateContract.checkOptionalorInactiveProduct(quote);
        GenerateContract.PartnerCommissioncheck(quote);

        if(quote.Contracted__c){
            throw new AuraHandledException('Quote is already Contracted.');
        } else{
            try{
                Approval.UnlockResult ur = Approval.unlock(quote.id);
                // //In case of Transfer of Service - Delete Quote Line where SCF Type is Blank
                // if(quote.SBQQ__Type__c == 'Amendment' && quote.SCF_Type__c == 'Transfer of Service'){
                //     List<SBQQ__QuoteLine__c> quoteLineToDeleteList = [SELECT Id, SCF_Type__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id AND SCF_Type__c = '' AND SBQQ__RequiredBy__r.SCF_Type__c = ''];
                //     system.debug('quoteLineToDeleteList ==> '+ quoteLineToDeleteList);
                //     if(quoteLineToDeleteList.size() > 0){
                //         delete quoteLineToDeleteList;
                //     }
                // }
                quote.Contracted__c = TRUE;
                quote.Contract_Generation_Date__c = System.today();
                update quote;
                System.debug('quote' + quote);
            }catch(DmlException ex){
                //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
                //we can get from DmlException

                //Get All DML Messages
                String msg = '';
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    //Get Validation Rule & Trigger Error Messages
                    msg =+ ex.getDmlMessage(i) +  '\n' ;
                }
                //throw DML exception message
                if (!Test.isRunningTest()) {
                    throw new AuraHandledException(msg);
                }

            }catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    /*
    Method to check if optional/inactive product exits in the quote
    */
    public static void checkOptionalorInactiveProduct(SBQQ__Quote__c quote){

        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,S_No__c,SBQQ__Product__r.IsActive,SBQQ__Optional__c,Quote_Type__c,SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id]; // added for scf quote
        Integer notoptionalcount = 0;
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
            if(!quoteLine.SBQQ__Product__r.IsActive && quoteLine.Quote_Type__c <> 'Amendment'){
                throw new AuraHandledException('Contract cannot be generated, the product with line no.' + quoteline.S_No__c + ' is inactive');
            }
            if(quoteLine.SBQQ__RequiredBy__c == NULL){
                System.debug('quoteLine.Id' + quoteLine.Id);
                System.debug('quoteLine.SBQQ__Optional__c' + quoteLine.SBQQ__Optional__c);
                if(!quoteLine.SBQQ__Optional__c){
                    notoptionalcount = notoptionalcount + 1;
                }
            }
            System.debug('notoptionalcount' + notoptionalcount);


        }
        if(notoptionalcount == 0){
            throw new AuraHandledException('Contract cannot be generated, all products are marked as Optional');

        }
    }


    /*
    Method to check if variable bandwidth product exits in the Billing Group
    */
    public static void checkVariableBandwidthProduct(SBQQ__Quote__c quote){

        Set<String> bandwidthSet = new Set<String>();
        Set<String> variableBandwidthSet = new Set<String>();
        Set<String> billingGrpList = new Set<String>();
        Boolean checkSCF = False;
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,Quote_Type__c,SBQQ__Quantity__c, Bandwidth_Type__c,SCF_Type__c, Variable_Product__c,S_No__c,SBQQ__Product__r.IsActive,SBQQ__Optional__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SCF_Type__c, SBQQ__SegmentIndex__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__Product__c, Account__c, Support_To_Customer__c, Location__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id AND Bandwidth_Type__c != NULL];
        Integer notoptionalcount = 0;
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){

            if(!quoteLine.SBQQ__Product__r.IsActive && quoteLine.Quote_Type__c <> 'Amendment'){
                throw new AuraHandledException('Contract cannot be generated, the product having line no.' + quoteline.S_No__c + 'is inactive');
            }
            if(quoteLine.SBQQ__RequiredBy__c == NULL){
                if(!quoteLine.SBQQ__Optional__c){
                    notoptionalcount = notoptionalcount + 1;
                }
            }

            System.debug('notoptionalcount' + notoptionalcount);
            if(notoptionalcount == 0){
                throw new AuraHandledException('Contract cannot be generated, all products are marked as Optional');
            }

            if(quoteLine.SBQQ__RequiredBy__c != NULL){
                if(!quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Burstable' && (quoteLine.Quote_Type__c == 'Quote' || quoteLine.SBQQ__Quantity__c > 0)){
                    bandwidthSet.add(quoteLine.Bandwidth_Type__c);
                }

                if(!quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Data Transfer' && (quoteLine.Quote_Type__c == 'Quote' || quoteLine.SBQQ__Quantity__c > 0)){
                    bandwidthSet.add(quoteLine.Bandwidth_Type__c);
                }

                if(quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Burstable'){
                    variableBandwidthSet.add(quoteLine.Bandwidth_Type__c);
                }

                if(quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Data Transfer'){
                    variableBandwidthSet.add(quoteLine.Bandwidth_Type__c);
                }
            }
        }

        for(Billing_Group__c billingGrp : [SELECT Id, Bandwidth_Type__c, Bill_To_Account__c, Support_To_Account__c, Location__c, External_Id__c FROM Billing_Group__c WHERE Bill_To_Account__c =: quote.SBQQ__Account__c AND Status__c = 'Active']){
            billingGrpList.add(billingGrp.External_Id__c);
        }

        System.debug('.....BANDWIDTH SET......' + bandwidthSet);
        System.debug('.....variableBandwidth SET......' + variableBandwidthSet);

        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            if(quoteLine.SBQQ__RequiredBy__c == null && quoteLine.SCF_Type__c != 'Deactivation' && quoteLine.SCF_Type__c != 'Upgrade/Downgrade' && quoteLine.SCF_Type__c!= 'New Line' && quoteLine.SCF_Type__c!= 'Price Change' && quoteLine.SCF_Type__c != 'Cancellation'){
                checkSCF = true;
            }
            //----criteria changed by sumeet on 21st july for BZ #349-----
            //if (quoteLine.Variable_Product__c && billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c) && quoteLine.SCF_Type__c != 'Deactivation' && quoteLine.SCF_Type__c != 'Cancellation' &&  quoteLine.SCF_Type__c != null){
            if (quoteLine.Variable_Product__c && billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c) && quoteLine.SCF_Type__c == 'New Line' && quoteLine.SCF_Type__c != null){
                //System.debug('quoteLine.SCF_Type__c ' + quoteLine.SCF_Type__c );
                //System.debug('quoteLine.Variable_Product__c' + quoteLine.Variable_Product__c);
                throw new AuraHandledException('You have already purchased ' + quoteLine.SBQQ__ProductName__c + '. Please remove it to proceed further.');
            }

            if(!quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Burstable' && !variableBandwidthSet.contains(quoteLine.Bandwidth_Type__c) && !billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c)){
                throw new AuraHandledException('Please add variable bandwidth also along with Hosted BURSTABLE IBW');
            }

            if(!quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Data Transfer' && !variableBandwidthSet.contains(quoteLine.Bandwidth_Type__c) && !billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c)){
                throw new AuraHandledException('Please add variable bandwidth also along with Data Transfer Bandwidth');
            }

            if(!quoteLine.Variable_Product__c && quoteLine.SBQQ__Quantity__c > 0 && quoteLine.Bandwidth_Type__c == 'Burstable' && !bandwidthSet.contains(quoteLine.Bandwidth_Type__c)){
                throw new AuraHandledException('You cannot purchase ' + quoteLine.SBQQ__ProductName__c + ' without purchasing Hosted BURSTABLE IBW');
            }

            if(!quoteLine.Variable_Product__c && quoteLine.SBQQ__Quantity__c > 0 && quoteLine.Bandwidth_Type__c == 'Data Transfer' && !bandwidthSet.contains(quoteLine.Bandwidth_Type__c)){
                throw new AuraHandledException('You cannot purchase ' + quoteLine.SBQQ__ProductName__c + ' without purchasing Hosted Data Transfer IBW on 1G NW Port');
            }
        }
    }

    public static void PartnerCommissioncheck( SBQQ__Quote__c quote){
        if (quote.Partner_Commision_Model__c == null && quote.SBQQ__Opportunity2__r.Partner_Commision_Model__c !=null && quote.SBQQ__Type__c == 'Quote' && quote.POC__c == 'No') {
            throw new AuraHandledException('Kindly select the Partner Commssion Model');
        }else if(quote.SBQQ__Type__c == 'Quote' && quote.Validate_Commission_Model__c	== false  && quote.POC__c == 'No' &&
                (quote.Partner_Commision_Model__c != null || quote.SBQQ__Opportunity2__r.Partner_Commision_Model__c != null) &&
                (quote.Partner_Commision_Model__c.contains('Model') || quote.SBQQ__Opportunity2__r.Partner_Commision_Model__c.contains('Model'))){
            throw new AuraHandledException('Please ask Partner Manager to validate Partner Commission');
        }
    }
}