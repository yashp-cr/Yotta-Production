public class SOFWrapperClass {
    public class YearWiseWrapper {
        public YearWiseWrapper() {

            this.totalOTC = 0;
            this.arc = 0;
            this.totalYearSum = 0;
            this.totalARC = 0;
            
            bundleProductWrapperMap = new Map<String, List<ProductWrapper>>();
            prodWrapKeySet = new Set<String>();
            prodWrapMap = new Map<String, ProductWrapper>();
            otcTotalMap = new Map<String,Decimal>();
            recTotalMap = new Map<String,Decimal>();
            
         //   bundleProductWrapperMap = new Map<Id, ProductWrapper>();
            bundleProductWrapperList = new List<ProductWrapper>();
            locationDeliveryAddressMap = new Map<String, String>();
        }

        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public Decimal totalOTC {get; set;}
        public Decimal arc {get; set;}
        public Decimal totalARC {get; set;}
        public Decimal totalYearSum {get; set;}
        public Integer refNo {get; set;}
        public String SegmentLabelYear {get; set;}
        public Map<String,Decimal> otcTotalMap{get; set;}
        public Map<String,Decimal> recTotalMap{get;set;}
        public Map<String,ProductWrapper> prodWrapMap {get;set;}
        public Map<String,List<ProductWrapper>> bundleProductWrapperMap {get; set;}
        public Set<String> prodWrapKeySet {get;set;}
        public Map<String, String> locationDeliveryAddressMap {get; set;}
       // public Map<Id, ProductWrapper> bundleProductWrapperMap {get; set;}
        public List<ProductWrapper> bundleProductWrapperList {get; set;}
    }


    public class ProductWrapper {

        public ProductWrapper() {
            this.productDescription = '';
            this.mrcUnit = 0;
            this.mrcTotal = 0;
            this.otcUnit = 0;
            this.otcTotal = 0;
            this.vrcCharge = 0;
            this.type = '';
            this.productLine = '';
            this.productFamily = '';
            this.Remarks = '';
            this.productModel = '';
            qty = 0;
            //componentProdList = new List<ProductWrapper>();
        }

        public Decimal quoteLineRef {get; set;}
        public String productDescription {get; set;} //
        public String productLine {get; set;}
        public Decimal otcUnit {get; set;}
        public Decimal otcTotal {get; set;}
        public Decimal mrcUnit {get; set;} //
        public Decimal mrcTotal {get; set;} //
        public Decimal vrcCharge {get; set;} //
        public String vrcUOM {get; set;} //
        //second table
        public String productFamily {get; set;}
        public String Remarks {get; set;}
        
        public String productModel {get; set;}
        public String sacCode {get; set;}
        public String deliveryLocation {get; set;}
        public Decimal qty {get; set;}
        public String type {get; set;}
        public SBQQ__QuoteLine__c quoteLine {get; set;}
        public String billingCurrency {get; set;}
        //public List<ProductWrapper> componentProdList {get; set;}
    }
}