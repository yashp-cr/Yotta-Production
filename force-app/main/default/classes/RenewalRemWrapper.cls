public class RenewalRemWrapper {
    public class ParentWrapper {
        public ParentWrapper(){
            
            this.qty = 0;
            this.deliveryLocation = '';
            this.deliveryLocationRev = '';
            this.productFamily='';
            
            this.productDescription='';
            bundleProductWrapperMap = new Map<Id, ProductWrapper>();
        }
        
        
     
        public String deliveryLocation {get;set;}
        public String deliveryLocationRev{get;set;}
        public String SCFType{get;set;}
        public Map<String,String> LocationDeliveryAddressMap {get;set;}
        public Decimal qty {get;set;}         
        public Map<Id, ProductWrapper> bundleProductWrapperMap {get;set;}
        public String productName{get;set;}
        public Integer refNo {get; set;}//
        public String productFamily {get;set;}
        public Decimal mrcTotal {get;set;}//
         public String UOM {get;set;}//
        
        public String productDescription {get;set;}//
        
    }
    
    
    public class ProductWrapper {
        
        public ProductWrapper(){
            
            
            this.mrcUnit=0;
            this.mrcTotal=0;
            this.mrcRevTotal=0;
            this.productDescription = '';
            this.vrcCharge=0;
            this.type ='';
            this.productModel='';
            this.otcTotal=0;
            this.otcRevTotal=0;
            this.vrcRevCharge=0;
            //componentProdList = new List<ProductWrapper>();
            
        }
        
        public Decimal refNo  {get;set;}
        public Decimal mrcUnit {get;set;}//
        public Decimal mrcTotal {get;set;}//
        public Decimal mrcRevTotal{get;set;}
        public Decimal otcRevTotal{get;set;}
        public Decimal otcTotal {get;set;}
        public Decimal vrcCharge {get;set;}//
        public Decimal vrcRevCharge{get;set;}
        public String UOM {get;set;}//
        public String productDescription {get;set;}
        //second table 
        public String productName {get;set;}
        public String SCFType {get;set;}
        public String productModel {get;set;}
        public String sacCode {get;set;}
        public String deliveryLocation {get;set;} 
        public Decimal qty {get;set;} 
        public String type {get;set;}
        public SBqq__QuoteLine__c quoteLine {get; set;}
        //public List<ProductWrapper> componentProdList {get; set;}
    }
}