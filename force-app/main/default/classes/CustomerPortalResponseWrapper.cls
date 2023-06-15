/**
 * Created by CloudRoute on 24-06-2022.
 */

public class CustomerPortalResponseWrapper {

    public CustomerPortalResponseWrapper(){
        this.ContractLines = new List<cls_ContractLines>();
    }

    public cls_ContractLines[] ContractLines;
    public String POC;    //No
    public String external_id;    //1031291
    public String rc_advance_payment_term_sos;    //Monthly in Advance
    public boolean online;
    public String original_contract;
    public String project_manager;
    public Integer total_grand_total;    //610080
    public String customer_authorised_signatory;    //0031m00000Mt5ReAAJ
    public String customer_billing_contact;    //0031m00000N7ny2AAB
    public String customer_tech_spoc;    //0031m00000N7ny2AAB
    public String contract_currency;    //INR
    public String enddate;    //2024-05-31
    public String startdate;    //2022-06-01
    public Integer contract_tenure_years;    //2
    public Integer contract_tenure_months;    //0
    public Integer contract_tenure_days;    //0
    public String bill_to_address;    //a1u1m0000001rkPAAQ
    public String customer_po_date;
    public String customer_po;
    public String support_to_account;    //0011m00000K8ko8AAB
    public String id;    //8001m000000HEA6AAO
    public String accountid;    //0011m00000K8ko8AAB
    public String scf_type;
    public String account_manager;    //rshetty@yotta.com
    public String business_unit;    //IN10
    public String credit_period;    //7 days
    public String contract_number;    //1031291
    public String bill_to_customerid;    //10630
    public String bill_to_customername;    //ABC Ltd
    public String support_to_customerid;    //10630
    public String support_to_customername;    //ABC Ltd

    public class cls_ContractLines {
        public cls_sbqq_product product;
        public cls_pricing pricing;
        public String location;    //IN12
        public String billing_currency;    //USD
        public String bill_from;    //IN12
        public String sub_external_id;    //10312910007
        public String line_item_id;    //10312910007
        public String scf_type;
        public String original_line_sr_no;
        public String status;    //Deployment Pending
        public String technical_end_date;
        public String technical_start_date;
        public String billenddate;
        public String billstartdate;
        public String delivery_location_address;    //IN12
        public String bundle_description;    //Qty - 1.00, UoM - Unit, Fiber - FCSAN Fabric with DUAL Redundant Port of 32G for Host Connectivity This does not include HBA / NIC availability., , Qty - 50.00, UoM - GB, Performance BLOCK Storage Volume on SSD Disk Minimum Pack of 50 GB and available in multiples units of 50GB Pack
        public String service_id;    //10312910007
        public String sbqq_contract;    //8001m000000HEA6AAO
        public String cancellation_date;
        public String line_sr_no;    //7
        public String id;    //a191m000001Fn0hAAC
    }

    public class cls_sbqq_product {
        public String cI_mapping_required;    //No
        public String product_line_text;    //STORAGE AS A SERVICE
        public String product_family_text;    //Yotta Cloud
        public String sale_type_label;    //Sale of Service
        public String unit_of_measurement;    //EA
        public String hsn_sac_code;    //998315
        public String product_code;    //P000111
        public String name;    //Block Storage
        public String id;    //01t1m000000OmF4AAK
    }

    public class cls_pricing {
        public Decimal otc;    //0
        public Map<String, CustomerPortalResponseWrapper.outputJSON> mrc;
        public Map<String, CustomerPortalResponseWrapper.outputJSON> vrc;
        public cls_pricing(){
            this.mrc = new Map<String, CustomerPortalResponseWrapper.outputJSON>();
            this.vrc = new Map<String, CustomerPortalResponseWrapper.outputJSON>();
            this.otc = 0.00;
        }
    }

    public class outputJSON {
        public Decimal pricing ;
        public Date startDate ;
        public Date endDate ;
    }

}