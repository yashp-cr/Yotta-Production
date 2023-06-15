public class TariffCardWrapper {
    
    public class ProductWrapper {
        public ProductWrapper() {
            this.Name = '';
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
            this.UPrice = new UnitPrice();
            this.SPrice = new SalesPrice();
            this.PPrice = new PartnerPrice();
            this.DPrice = new DistributorPrice();
        }

        public String Name {get; set;}   
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
        public SalesPrice SPrice {get; set;}
        public UnitPrice UPrice {get; set;}
        public PartnerPrice PPrice {get; set;}
        public DistributorPrice DPrice {get; set;}

    }
    public class SalesPrice{
        public Decimal OTC {get; set;}
        public Decimal MRC {get; set;}
        public Decimal VRC {get; set;}
        
        public SalesPrice(){
            this.OTC = 0;
            this.MRC = 0;
            this.VRC = 0;     
        }
    }
    public class UnitPrice{
        public Decimal OTC {get; set;}
        public Decimal MRC {get; set;}
        public Decimal VRC {get; set;}
        
        public UnitPrice(){
            this.OTC = 0;
            this.MRC = 0;
            this.VRC = 0;     
        }
    }
    public class PartnerPrice{
        public Decimal OTC {get; set;}
        public Decimal MRC {get; set;}
        public Decimal VRC {get; set;}
        
        public PartnerPrice(){
            this.OTC = 0;
            this.MRC = 0;
            this.VRC = 0;     
        }
    }
    public class DistributorPrice{
        public Decimal OTC {get; set;}
        public Decimal MRC {get; set;}
        public Decimal VRC {get; set;}
        
        public DistributorPrice(){	
            this.OTC = 0;
            this.MRC = 0;
            this.VRC = 0;     
        }
    }
}