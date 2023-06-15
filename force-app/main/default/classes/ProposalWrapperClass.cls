public class ProposalWrapperClass {

    public class YearWiseWrapper {
        public YearWiseWrapper() {
            this.totalOTC = 0;
            this.arc = 0;
            this.totalYearSum = 0;
            this.totalARC = 0;
            groupWrapMap = new Map<String, GroupWiseProductWrapper>();
        }

        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public Integer refNo {get; set;}
        public Decimal totalOTC {get; set;}
        public Decimal arc {get; set;}
        public Decimal totalARC {get; set;}
        public Decimal totalYearSum {get; set;}

        public Map<String, GroupWiseProductWrapper> groupWrapMap {get; set;}
    }

    public class GroupWiseProductWrapper {
        public String groupName {get; set;}
        public String groupId {get; set;}
        public Decimal yearWiseRC {get; set;}
        public Decimal yearWiseOTC {get; set;}
        public String key {get; set;}
        //public SBQQ__QuoteLine__c quoteLine {get; set;}
        public Map<String,ProductWrapper> prodWrapMap {get;set;}
        public Map<String,List<ProductWrapper>> bundleProductWrapperMap {get; set;}
        public Set<String> prodWrapKeySet {get;set;}
        public Map<String,Decimal> otcTotalMap{get; set;}
        public Map<String,Decimal> recTotalMap{get;set;}
        public List<ProductWrapper> bundleProductWrapperList {get; set;}
        //public Map<String, Integer> otcTotalMap{get;set;}
       // public Map<String, Integer> recTotalMap{get;set;}

        public GroupWiseProductWrapper() {
            bundleProductWrapperMap = new Map<String, List<ProductWrapper>>();
            otcTotalMap = new Map<String,Decimal>();
            prodWrapKeySet = new Set<String>();
            recTotalMap = new Map<String,Decimal>();
            prodWrapMap = new Map<String, ProductWrapper>();
            bundleProductWrapperList = new List<ProductWrapper>();
            this.yearWiseRC = 0;
            this.yearWiseOTC = 0;
        }
    }

    public class ProductWrapper {
        public ProductWrapper() {
            this.Remarks = '';
            this.productDescription = '';
            this.productLine = '';
            this.mrcUnit = 0;
            this.mrcTotal = 0;
            this.otcUnit = 0;
            this.otcTotal = 0;
            this.otcLineTotal = 0;
            this.recLineTotal = 0;
            this.vrcCharge = 0;
            this.productFamily = '';
            this.serialNumber = 0;
            this.productBundleName = '';
        }

        public Decimal otcUnit {get; set;}       
        public Decimal serialNumber {get; set;}
        public Decimal otcTotal {get; set;}
        public Decimal mrcUnit {get; set;} //
        public Decimal mrcTotal {get; set;} //
        public Decimal vrcCharge {get; set;} //
        public Decimal otcLineTotal {get; set;} //
        public Decimal recLineTotal {get; set;} 
        public String vrcUOM {get; set;} //
        //second table
        public String productFamily {get; set;}
        public String productBundleName {get; set;}
        public String productDescription {get; set;}
        public String remarks {get; set;}
        public String productLine {get; set;}//
        public String UOM {get; set;}
        public Decimal qty {get; set;}
        public String deliveryLocation {get; set;}
        public SBQQ__QuoteLine__c quoteLine {get; set;}
    }


    public class GroupWrapper {
        public String groupName {get; set;}
        public String groupId {get; set;}
        public Decimal groupWiseOTC {get; set;}
        public Decimal groupWiseTotal {get; set;}
        public Decimal groupWiseTot {get; set;}
        public 	Decimal groupOtc{get;set;}
        public Decimal groupWiseRec {get; set;}
        public Decimal allGroupSum {get; set;}
        public Decimal allGroupOtc {get; set;}
        public Map<String, ChargeTypeWrapper> chargeWrapperMap {get; set;}
        public List<ChargeTypeWrapper> chargeWrapperList{get;set;}
        public Map<Integer, GroupYearWrapper> groupYearWrapperMap {get; set;}

        public GroupWrapper(Integer startYear, Decimal noOfYears) {
            this.groupOtc = 0;
            this.groupWiseTot = 0;
            this.groupWiseOTC = 0;
            this.groupWiseTotal = 0;
            this.groupWiseRec = 0;
            this.allGroupSum = 0;
            this.allGroupOtc = 0;
            chargeWrapperMap = new Map<String, ChargeTypeWrapper>();
            chargeWrapperList = new List<ChargeTypeWrapper>();
            groupYearWrapperMap = new Map<Integer , GroupYearWrapper>();

            for (Integer i = 0 ; i < noOfYears - 1 ; i++) {
                groupYearWrapperMap.put((startYear + i), new GroupYearWrapper((startYear + i)));
            }
        }
    }

    public class ChargeTypeWrapper {
        public String typeOfCharge {get; set;}
        public Map<String, productFamilyWrapper> familyWrapperMap {get; set;}
        

        public ChargeTypeWrapper() {
            familyWrapperMap = new Map<String, productFamilyWrapper>();
        }
    }

    public class productFamilyWrapper {
        public String family {get; set;}
        public Decimal qty {get; set;}
        public String uom {get; set;}
        public Decimal otc {get; set;}
        public Decimal productFamilyTotal {get; set;}
        public Decimal productTotal{get; set;}
        public Map<Integer, yearWrapper> yearWrapperMap {get; set;}

        public productFamilyWrapper(String family, Integer startYear, Decimal noOfYears) {
            this.family = family;
            this.otc = 0;
            this.productFamilyTotal = 0;
            this.productTotal = 0;
            yearWrapperMap = new Map<Integer, yearWrapper>();

            for (Integer i = 0 ; i < noOfYears ; i++) {
                yearWrapperMap.put((startYear + i), new yearWrapper((startYear + i)));
            }
        }
    }
    
     public class SummaryTotalWrap {
        public String yearLabel1 {get; set;}
        public Map<String, Decimal> monthTotalMap {get;set;}

        public SummaryTotalWrap(String key) {
            
            monthTotalMap = new Map<String, Decimal>(); 
            
        }
    }
    
      public class productFamilyWrapper1 {
        public String family {get; set;}
        public Decimal qty {get; set;}
        public String uom {get; set;}
        public Map<String, Decimal> monthTotalMap {get;set;}
        public Decimal otc {get; set;}
        public Decimal productFamilyTotal {get; set;}
        public Set<String> yearLabelKeySet {get;set;}
        public Map<Integer, yearWrapper> yearWrapperMap {get; set;}
        public Map<String, monthWrapper> monthWrapperMap {get; set;}
       
        public Map<String,Map<String, monthWrapper>> summaryMap {get; set;}

        public productFamilyWrapper1(String family,Decimal startMonth,Decimal noOfMonths) {
            this.family = family;
            this.otc = 0;
            this.productFamilyTotal = 0;
            yearWrapperMap = new Map<Integer, yearWrapper>();
            monthTotalMap = new Map<String, Decimal>();
            yearLabelKeySet = new Set<String>();
            summaryMap = new Map<String,Map<String,monthWrapper>>();
            monthWrapperMap = new Map<String, monthWrapper>(); 
            
        }
    }


    public class yearWrapper {
        public Decimal year {get; set;}
        public Decimal amount {get; set;}
        public Decimal amountTotal{get; set;}
        public Decimal otc {get; set;}
        public Decimal recurring {get; set;}

        public yearWrapper(Decimal year) {
            this.amountTotal = 0;
            this.year = year;
            this.recurring = 0;
            this.otc = 0;
            this.amount = 0;
        }
    }
    
     public class monthWrapper {
        public Decimal month {get; set;}
        public Map<String,Decimal> amount {get; set;}
         
       
        public Decimal otc {get; set;}
        public Decimal total {get; set;}
        public Decimal recurring {get; set;}
        public String Family {get; set;}
        public String bundleName {get; set;}
        public String yearLabel {get; set;}

        public monthWrapper(Decimal month) {
            this.month = month;
            this.total = 0;
            this.otc = 0;
            amount = new Map<String,Decimal>();
           
        }
    }

    public class GroupYearWrapper {
        public Decimal year {get; set;}
        public String groupName {get; set;}
        public Decimal recurring {get; set;}
        public Decimal recurringTotal{get; set;}
        public Decimal Total {get; set;}
        public Decimal allGroupYearTotal {get; set;}

        public GroupYearWrapper(Decimal year) {
            this.year = year;
            this.recurringTotal = 0;
            this.recurring = 0;
            this.allGroupYearTotal = 0;
        }
    }

    public class allProducts {
        public String Family {get; set;}
        public String bundleName {get; set;}
        public String productDescription {get; set;}
        public Decimal qty {get; set;}
        public Decimal serialNumb {get; set;}
        public String uom {get; set;}
        public String delivery {get; set;}
        public List<allProducts> allProductWrapperList {get; set;}
        public SBQQ__QuoteLine__c quoteLine {get; set;}

        public allProducts() {
            this.productDescription = '';
            allProductWrapperList = new List<allProducts>(); 
        }
    }
    
    //optional service wrapper
    public class OptionalServiceGroupWrapper {
        public String grpName {get; set;}
        public String grpId {get; set;}
        public Map<String, ProposalWrapperClass.familyWrapper> optionalFamMap {get; set;}
        public Set<String> FamilyName { get; set; }
        public OptionalServiceGroupWrapper() {
            optionalFamMap = new Map<String, ProposalWrapperClass.familyWrapper>();
            FamilyName = new Set<String>();
        }
    }

    public class familyWrapper {
        public Map<String, ProposalWrapperClass.ProductOptionalWrapper> OptionalProductMap {get; set;}

        public familyWrapper(){
            this.OptionalProductMap = new Map<String,ProposalWrapperClass.ProductOptionalWrapper>();
        }

    }

    public class ProductOptionalWrapper {
        public String bundleName {get; set;}
        public String family {get; set;}
        public String description {get; set;}
        public Decimal qty {get; set;}
        public String uom {get; set;}
        public Decimal famWrapYearOtc {get; set;}
        public Decimal famWrapYearVRC {get; set;}
        public Set<String> ComponentName {get; set;}
        public Map<Integer, ProposalWrapperClass.ProdfamYearWrapper> famYearMap {get; set;}

        public ProductOptionalWrapper() {
            this.famWrapYearOtc = 0;
            this.famWrapYearVRC = 0;
            this.description = '';
            famYearMap = new Map<Integer, ProposalWrapperClass.ProdfamYearWrapper>();
            ComponentName = new Set<String>();
        }
    }

    public class ProdfamYearWrapper {
        public Decimal famWrapYearReccuring {get; set;}

        public ProdfamYearWrapper() {
            this.famWrapYearReccuring = 0;
        }
    }
}