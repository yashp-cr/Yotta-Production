/**
 * Created by CloudRoute on 24-06-2022.
 */

@RestResource(urlMapping = '/CustomerPortalGetOrderDetails/*')
global with sharing class CustomerPortalGetOrderDetails {
    @HttpPost
    global static void manageBillToData() {
        try {
            //Payload in request
            String requestBody = RestContext.request.requestBody.toString();
            String query;
            RequestWrapper billTo = (RequestWrapper) JSON.deserialize(requestBody, RequestWrapper.class);
            //Creating Response Instance
            RestResponse res = RestContext.response;
            System.debug('REquest ==' + billTo);

            Integration_Request_Template__mdt intReqTemCont = [SELECT MasterLabel,All_Fields__c,Json_Field_Names__c FROM Integration_Request_Template__mdt WHERE DeveloperName = 'Contract_Topic' LIMIT 1];
            Integration_Request_Template__mdt intReqTemSub = [SELECT MasterLabel,All_Fields__c,Json_Field_Names__c FROM Integration_Request_Template__mdt WHERE DeveloperName = 'Contract_Subscription_Object' LIMIT 1];
            Map<Id, List<SBQQ__Subscription__c>> mapBundleIdToComponentIds = new Map<Id, List<SBQQ__Subscription__c>>();
            Map<Id, List<Asset>> mapBundleIdToOTC = new Map<Id, List<Asset>>();

            for (SBQQ__Subscription__c objSubs : [
                    SELECT Id, SBQQ__SegmentLabel__c, SBQQ__SegmentStartDate__c, SBQQ__RequiredById__c,
                            SBQQ__SegmentEndDate__c,
                            SBQQ__Dimension__r.Dimension_Type__c, Currency_Sensitive_Line__c
                    FROM SBQQ__Subscription__c
                    WHERE (SBQQ__Contract__r.Contract_Number__c IN :billTo.sof_no OR SBQQ__Contract__r.Account.Account_Number__c IN  :billTo.bill_to_customerid OR SBQQ__Contract__r.Support_To_Account__r.Account_Number__c IN :billTo.support_to_customerid)
                    AND SBQQ__Quantity__c >= 0 AND SBQQ__Dimension__c != NULL AND SBQQ__RequiredById__c != NULL
            ]) {

                if (!mapBundleIdToComponentIds.containsKey(objSubs.SBQQ__RequiredById__c)) {
                    mapBundleIdToComponentIds.put(objSubs.SBQQ__RequiredById__c, new List<SBQQ__Subscription__c>{
                            objSubs
                    });
                } else {
                    mapBundleIdToComponentIds.get(objSubs.SBQQ__RequiredById__c).add(objSubs);
                }
            }

            system.debug('====' + mapBundleIdToComponentIds.keySet());

            for (Asset objAsset : [
                    SELECT Id, Final_Unit_Price__c, Final_Net_Price__c, SBQQ__RequiredBySubscription__c, Currency_Conversion_Factor__c
                    FROM Asset
                    WHERE SBQQ__RequiredBySubscription__c IN :mapBundleIdToComponentIds.keySet()
            ]) {

                if (!mapBundleIdToOTC.containsKey(objAsset.SBQQ__RequiredBySubscription__c)) {
                    mapBundleIdToOTC.put(objAsset.SBQQ__RequiredBySubscription__c, new List<Asset>{
                            objAsset
                    });
                } else {
                    mapBundleIdToOTC.get(objAsset.SBQQ__RequiredBySubscription__c).add(objAsset);
                }
            }
            Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
            List<String> billCustomerId = billTo.bill_to_customerid;
            query = 'SELECT ' + intReqTemCont.All_Fields__c + ',Account.Account_Number__c, Account.Name, Original_Contract__c,' +
                    'Support_To_Account__r.Name,Support_To_Account__r.Account_Number__c,' +
                    ' (SELECT sbqq__quoteline__r.name,id,s_no__c,sbqq__product__c,cancellation_date__c,line_sr_no__c,partner_commission__c,sales_rep_commission__c,sbqq__contract__c,name,service_id__c,'+
                    'bundle_description__c,delivery_location_address__c,sbqq__subscriptionstartdate__c,sbqq__subscriptionenddate__c,technical_start_date__c,technical_end_date__c,sbqq__terminateddate__c,'+
                    'status__c,final_net_price__c,sbqq__quantity__c,sbqq__quoteline__c,original_line_sr_no__c,sbqq__originalquoteline__c,ir_number__c,dr_number__c,dr_status__c,ir_status__c,bill_start_date__c,'+
                    'bill_end_date__c, scf_type__c,line_item_id__c,sub_external_id__c,bill_from__c,billing_currency__c,Billing_to_be_done_Online__c,Remarks__c ,'+
                    'SBQQ__Product__r.CI_Mapping_Required__c,toLabel(Location__c),' +
                    'SBQQ__Product__r.Product_Line_Text__c,SBQQ__Product__r.Product_Family_Text__c,SBQQ__Product__r.Name,' +
                    'SBQQ__Product__r.Sale_Type_Label__c,SBQQ__Product__r.Unit_of_Measurement__c,SBQQ__Product__r.HSN_SAC_Code__c,' +
                    'SBQQ__Product__r.Product_Code__c FROM SBQQ__Subscriptions__r WHERE SBQQ__RequiredById__c = NULL AND Status__c <> \'Renewed\') ' +
                    'FROM Contract WHERE Status IN (\'Approved\',\'Activated\',\'Expired\',\'Cancelled\',\'Deactivated\') AND ';

            if (!billTo.sof_no.isEmpty()) {
                List<String> SOFNO = billTo.sof_no;
                query += ' Contract_Number__c IN :SOFNO AND';
            }
            if (org.IsSandbox) {
                query += ' (Account.Account_Number__c IN :billCustomerId OR Account.Account_Number_SIT__c IN :billCustomerId)';
            }else{
                query += ' Account.Account_Number__c IN :billCustomerId';
            }
            if (!billTo.support_to_customerid.isEmpty() && org.IsSandbox){
                List<String> SupporttoCustId = billTo.support_to_customerid;
                query += ' AND (Support_To_Account__r.Account_Number__c IN :SupporttoCustId OR Account.Account_Number_SIT__c IN :SupporttoCustId)';
            }else if(!billTo.support_to_customerid.isEmpty()){
            List<String> SupporttoCustId = billTo.support_to_customerid;
            query += ' AND Support_To_Account__r.Account_Number__c IN :SupporttoCustId';
        }

            List<CustomerPortalResponseWrapper> listcprw = new List<CustomerPortalResponseWrapper>();

            for (Contract cont : Database.query(query)) {
                CustomerPortalResponseWrapper cprw = new CustomerPortalResponseWrapper();

                cprw.Id = cont.Id;
                cprw.accountid = cont.AccountId;
                cprw.POC = cont.POC__c;
                cprw.external_id = cont.External_Id__c;
                cprw.rc_advance_payment_term_sos = cont.RC_Advance_Payment_Term_SOS__c;
                cprw.online = cont.Online__c;
                cprw.original_contract = cont.Original_Contract__c;
                cprw.project_manager = cont.Project_Manager__c;
                cprw.total_grand_total = (Integer) cont.Total_Grand_Total__c;
                cprw.customer_authorised_signatory = cont.Customer_Authorised_Signatory__c;
                cprw.customer_billing_contact = cont.Customer_Billing_Contact__c;
                cprw.customer_tech_spoc = cont.Customer_Tech_SPOC__c;
                cprw.contract_currency = cont.Contract_Currency__c;
                cprw.enddate = String.valueOf(cont.EndDate);
                cprw.startdate = String.valueOf(cont.StartDate);
                cprw.contract_tenure_years = (Integer) cont.Contract_Tenure_Years__c;
                cprw.contract_tenure_months = (Integer) cont.Contract_Tenure_Months__c;
                cprw.contract_tenure_days = (Integer) cont.Contract_Tenure_Days__c;
                cprw.bill_to_address = cont.Bill_To_Address__c;
                cprw.customer_po_date = String.valueOf(cont.Customer_PO_Date__c);
                cprw.customer_po = cont.Customer_PO__c;
                cprw.support_to_account = cont.Support_To_Account__c;
                cprw.scf_type = cont.SCF_Type__c;
                cprw.business_unit = cont.Business_Unit__c;
                cprw.credit_period = cont.Credit_Period__c;
                cprw.contract_number = cont.Contract_Number__c;
                cprw.bill_to_customerid = cont.Account.Account_Number__c;
                cprw.bill_to_customername = cont.Account.Name;
                cprw.support_to_customerid = cont.Support_To_Account__r.Account_Number__c;
                cprw.support_to_customername = cont.Support_To_Account__r.Name;


                if (!cont.SBQQ__Subscriptions__r.isEmpty()) {

                    for (SBQQ__Subscription__c Sub : cont.SBQQ__Subscriptions__r) {
                        CustomerPortalResponseWrapper.cls_ContractLines contLine = new CustomerPortalResponseWrapper.cls_ContractLines();
                        contLine.id = sub.Id;
                        contLine.location = sub.Location__c;
                        contLine.billing_currency = sub.Billing_Currency__c;
                        contLine.sub_external_id = sub.Sub_External_Id__c;
                        contLine.line_item_id = sub.Line_Item_Id__c;
                        contLine.scf_type = sub.SCF_Type__c;
                        contLine.original_line_sr_no = sub.Original_Line_Sr_No__c;
                        contLine.status = sub.Status__c;
                        contLine.technical_end_date = String.ValueOf(sub.Technical_End_Date__c);
                        contLine.technical_start_date = String.ValueOf(sub.Technical_Start_Date__c);
                        contLine.billenddate = String.ValueOf(sub.Bill_End_Date__c);
                        contLine.billstartdate = String.ValueOf(sub.Bill_Start_Date__c);
                        contLine.delivery_location_address = sub.Delivery_Location_Address__c;
                        contLine.bundle_description = sub.Bundle_Description__c;
                        contLine.service_id = sub.Service_Id__c;
                        contLine.sbqq_contract = sub.SBQQ__Contract__c;
                        contLine.cancellation_date = String.ValueOf(sub.Cancellation_Date__c);
                        contLine.line_sr_no = sub.Line_Sr_No__c;
                        CustomerPortalResponseWrapper.cls_pricing price = new CustomerPortalResponseWrapper.cls_pricing();

                        if (mapBundleIdToComponentIds.get(Sub.Id) != null) {
                            for (SBQQ__Subscription__c objSubs : mapBundleIdToComponentIds.get(Sub.Id)) {
                                Map<String, CustomerPortalResponseWrapper.outputJSON> MRC;
                                Map<String, CustomerPortalResponseWrapper.outputJSON> VRC;
                                String segmentLabel = objSubs.SBQQ__SegmentLabel__c.replaceAll('\\s+', '_');
                                String strPriceDimension = objSubs.SBQQ__Dimension__r.Dimension_Type__c.toLowerCase();
                                if(strPriceDimension == 'mrc'){
                                    MRC = price.mrc;
                                }else if(strPriceDimension == 'vrc'){
                                    VRC = price.vrc;
                                }
                                CustomerPortalResponseWrapper.outputJSON obj = new CustomerPortalResponseWrapper.outputJSON();
                                if (strPriceDimension == 'vrc') {
                                    obj.pricing = objSubs.Currency_Sensitive_Line__c;
                                } else {
                                    obj.pricing = math.round(objSubs.Currency_Sensitive_Line__c);
                                }
                                obj.startDate = objSubs.SBQQ__SegmentStartDate__c;
                                obj.endDate = objSubs.SBQQ__SegmentEndDate__c;
                                if(strPriceDimension == 'vrc'){
                                    VRC.put(segmentLabel, obj);
                                    price.vrc = VRC;
                                } else if(strPriceDimension == 'mrc'){
                                    MRC.put(segmentLabel, obj);
                                    price.mrc = MRC;
                                }
                            }
                            Decimal OTC = 0;
                            OTC.setScale(2);
                            System.debug('mapBundleIdToOTC.get(Sub.Id)' + mapBundleIdToOTC.get(Sub.Id));
                            System.debug('Sub  === ' + Sub);

                            if (!mapBundleIdToOTC.isEmpty() && mapBundleIdToOTC.get(Sub.Id) != null) {
                                System.debug('mapBundleIdToOTC.get(Sub.Id)' + mapBundleIdToOTC.get(Sub.Id));

                                for (Asset tempAsset : mapBundleIdToOTC.get(Sub.Id)) {

                                    if (tempAsset.Final_Net_Price__c != null) OTC += math.round(tempAsset.Currency_Conversion_Factor__c * tempAsset.Final_Net_Price__c);
                                    price.otc = OTC;
                                }
                            }

                            contLine.pricing = price;
                            if (sub.SBQQ__Product__c != null) {
                                CustomerPortalResponseWrapper.cls_sbqq_product prod = new CustomerPortalResponseWrapper.cls_sbqq_product();
                                prod.cI_mapping_required = sub.SBQQ__Product__r.CI_Mapping_Required__c;
                                prod.product_line_text = sub.SBQQ__Product__r.Product_Line_Text__c;
                                prod.product_family_text = sub.SBQQ__Product__r.Product_Family_Text__c;
                                prod.sale_type_label = sub.SBQQ__Product__r.Sale_Type_Label__c;
                                prod.unit_of_measurement = sub.SBQQ__Product__r.Unit_of_Measurement__c;
                                prod.hsn_sac_code = sub.SBQQ__Product__r.HSN_SAC_Code__c;
                                prod.product_code = sub.SBQQ__Product__r.Product_Code__c;
                                prod.name = sub.SBQQ__Product__r.Name;
                                prod.id = sub.SBQQ__Product__c;

                                contLine.product = prod;
                            }
                            cprw.ContractLines.add(contLine);
                        }
                    }
                }
                listcprw.add(cprw);
            }
            System.debug('JSON ==' + JSON.serialize(listcprw));
            if (listcprw != null) {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(listcprw));
            } else {
                res.statusCode = 400;
            }
        } catch (Exception e) {
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(e.getLineNumber() + ' --- ' + e.getMessage()));
        }
    }

    public class RequestWrapper {
        public String[] bill_to_customerid;
        public String[] sof_no;
        public String[] support_to_customerid;
    }


}