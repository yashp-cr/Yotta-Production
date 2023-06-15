public class ContractLineWrapper {
 public class ParentWrapper {
        public ParentWrapper(){
            
            this.qty = 0;
            this.deliveryLocation = '';
            this.productDescription='';
            this.BillStartDate='';
            this.productName='';
            this.id='';
        }
        
        
     public String Id{get;set;}
        public String deliveryLocation {get;set;}
        public String ContractNumber{get;set;}
        public Decimal qty {get;set;}     
        public String productDescription {get;set;}
        public String BillStartDate {get;set;}//
        public String productName{get;set;}
        
    }

}