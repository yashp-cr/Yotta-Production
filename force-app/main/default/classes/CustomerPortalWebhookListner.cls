@RestResource(urlMapping = '/CustomerPortalWebhookListner/*')
global with sharing class CustomerPortalWebhookListner {
    @HttpPost
    global static void manageBillToData(){
        try{
            //Payload in request
            String requestBody = RestContext.request.requestBody.toString();
            BillToRequestWrapper billTo = (BillToRequestWrapper)JSON.deserialize(requestBody, BillToRequestWrapper.class);
            //Creating Response Instance
            RestResponse res = RestContext.response;

            //Creating Instance of Response Wrapper
            BillToResponseWrapper billToRes = new BillToResponseWrapper();
            billToRes.bill_to_customerid = billTo.bill_to_customerid;
            Map<String,Contract> supToCustIdVsContract = new Map<String,Contract>();

            for(Contract con : [SELECT Id,AccountId,Account.Name,Account.Account_Number__c,Support_To_Account__c,Support_To_Account__r.Name,Support_To_Account__r.Account_Number__c FROM Contract WHERE Account.Account_Number__c = :billTo.bill_to_customerid or Support_To_Account__r.Account_Number__c =:billTo.bill_to_customerid]){
                System.debug('contract ---> ' + con);
                supToCustIdVsContract.put(con.Support_To_Account__r.Account_Number__c,con);
            }

            if(!supToCustIdVsContract.isEmpty()){
                for(String custId : supToCustIdVsContract.keySet()){
                    Contract con = supToCustIdVsContract.get(custId);
                    cls_support_to_customers soc = new cls_support_to_customers();
                    soc.bill_to_sfid = con.Account.Account_Number__c;
                    soc.bill_to_name = con.Account.Name;
                    soc.support_to_custid = con.Support_To_Account__r.Account_Number__c;
                    soc.support_to_customername = con.Support_To_Account__r.Name;
                    soc.support_to_cust_sfid = con.Support_To_Account__c;
                    billToRes.support_to_customers.add(soc);
                }
            }

            System.debug('billToRes.support_to_customers --->' + billToRes.support_to_customers);

            if(billToRes != null){
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(billToRes));
            }else{
                res.statusCode = 400;
            }
        } catch(Exception e){
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(e.getMessage()));
        }
    }

    public class BillToRequestWrapper{
        public String bill_to_customerid;
    }

    public class BillToResponseWrapper{
        public String bill_to_customerid;	//10603
        public cls_support_to_customers[] support_to_customers;
        public BillToResponseWrapper(){
            support_to_customers = new List<cls_support_to_customers>();
        }
    }

    public class cls_support_to_customers {
        public String bill_to_sfid;
        public String bill_to_name;
        public String support_to_custid;	//12345
        public String support_to_customername;	//ABC LTD
        public String support_to_cust_sfid;	//aCVahabaob12qc
    }
}