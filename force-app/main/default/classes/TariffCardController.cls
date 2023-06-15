public class TariffCardController {
    public string recordId{get;set;}
    public List<Product2> listOfProduct{get;set;}
    public List<SBQQ__Dimension__c> listOfProductDimensions{get;set;}
    public TariffCardWrapper.ProductWrapper productWrap{get;set;}
    public List<TariffCardWrapper.ProductWrapper> listOfProductWrap{get;set;}
    public String profileName { get; set;}
    public Boolean SalesProfile { get; set; }
    public Boolean PartnerProfile { get; set; }
    public Boolean DistributorPartnerProfile { get; set; }
    public String CurrentDatetime {get; Set;}
    public Boolean PartnerDisclamer {get; set;}
    public Boolean SalesDisclamer {get; set;}

    
    public Map<String,List<TariffCardWrapper.ProductWrapper>> mapOfProductWrap {get; set;}
    public Map<String,Set<String>> mapOfProductFamily {get; set;}
    
    public TariffCardController(){
 
        //recordId  = ApexPages.CurrentPage().getparameters().get('id');

         CurrentDatetime = DateTime.NOW().format('dd/MM/yyyy HH:mm:ss', UserInfo.getTimeZone().toString());

        PartnerDisclamer = false;
        SalesDisclamer = false;
        SalesProfile = false ;
        PartnerProfile = false;
        DistributorPartnerProfile = false;
        system.debug('recordId='+ recordId);
        mapOfProductWrap = new Map<String,List<TariffCardWrapper.ProductWrapper>>();
        mapOfProductFamily = new Map<String,Set<String>>();
        listOfProductWrap = new List<TariffCardWrapper.ProductWrapper>();
        listOfProduct = [SELECT Id, Name, Family,Product_Family_Text__c,Product_Line_Text__c,Product_Description__c,Description,Variable_UOM__c,Model_Name__c,Unit_of_Measurement__c,(SELECT Id,Dimension_Type__c,Name,SBQQ__Type__c,Distributor_Price__c,Internal_Cost_Price__c,Partner_Price__c,Product_Head_Price__c,Sales_Head_Price__c,
                                 Sales_Price__c,SBQQ__UnitPrice__c,SBQQ__Product__c FROM SBQQ__Dimensions__r) From Product2 WHERE SBQQ__Component__c = true AND IsActive = true and Product_Family_Text__c <> null];
        listOfProductDimensions = [SELECT Id,Dimension_Type__c,Name,SBQQ__Type__c,Distributor_Price__c,Internal_Cost_Price__c,Partner_Price__c,Product_Head_Price__c,Sales_Head_Price__c,
                                 Sales_Price__c,SBQQ__UnitPrice__c,SBQQ__Product__c From SBQQ__Dimension__c WHERE SBQQ__Product__c IN :listOfProduct ];
        for(Product2 prod:listOfProduct){
            productWrap = new TariffCardWrapper.ProductWrapper();
            productWrap.Name = prod.Name;
            productWrap.productFamily = prod.Product_Family_Text__c;
            productWrap.productDescription = prod.Description;
            productWrap.productLine = prod.Product_Line_Text__c;
            productWrap.UOM = prod.Unit_of_Measurement__c;
            productWrap.productBundleName=prod.Model_Name__c;
			
          for(SBQQ__Dimension__c Dim: prod.SBQQ__Dimensions__r){
                if(Dim.Dimension_Type__c == 'OTC'){
                    productWrap.SPrice.OTC = Dim.Sales_Price__c;
                    productWrap.DPrice.OTC = Dim.Distributor_Price__c;
					productWrap.PPrice.OTC = Dim.Partner_Price__c;
                    productWrap.UPrice.OTC = Dim.SBQQ__UnitPrice__c;
                }
              if(Dim.Dimension_Type__c == 'MRC'){
                    productWrap.SPrice.MRC = Dim.Sales_Price__c;
                    productWrap.DPrice.MRC = Dim.Distributor_Price__c;
					productWrap.PPrice.MRC = Dim.Partner_Price__c;
                    productWrap.UPrice.MRC = Dim.SBQQ__UnitPrice__c;
                }
              if(Dim.Dimension_Type__c == 'VRC'){
                    productWrap.SPrice.VRC = Dim.Sales_Price__c;
                    productWrap.DPrice.VRC = Dim.Distributor_Price__c;
					productWrap.PPrice.VRC = Dim.Partner_Price__c;
                    productWrap.UPrice.VRC = Dim.SBQQ__UnitPrice__c;
                }
            }
            listOfProductWrap.add(productWrap);
            
        }
        
        for (TariffCardWrapper.ProductWrapper P : listOfProductWrap) {
            if (mapOfProductWrap.containsKey(P.productBundleName)) {
                List<TariffCardWrapper.ProductWrapper> listOfProductWrapCopy = mapOfProductWrap.get(P.productBundleName);
                listOfProductWrapCopy.add(P);
                mapOfProductWrap.put(P.productBundleName, listOfProductWrapCopy);
            } else {
                mapOfProductWrap.put(P.productBundleName, new List<TariffCardWrapper.ProductWrapper> {P});
            }
        }
        
        for(TariffCardWrapper.ProductWrapper Product : listOfProductWrap){
            if(mapOfProductFamily.containsKey(Product.productFamily)){
                Set<String> listofProductBundlename = mapOfProductFamily.get(Product.productFamily);
                if (!listofProductBundlename.contains(Product.productBundleName)){
                    listofProductBundlename.add(Product.productBundleName);
                }
                mapOfProductFamily.put(Product.productFamily, listofProductBundlename);
            }else{
                mapOfProductFamily.put(Product.productFamily, new Set<String>{ Product.productBundleName });
            }
        }
        
        System.debug('inside controller');
        Id profileId = UserInfo.getProfileId();
        User currentUser = [SELECT Id, Account_Type__c FROM User WHERE Id = :UserInfo.getUserId()];
		String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
         if (profileName  == 'Yotta Partner Profile' && !currentUser.Account_Type__c.Contains('Distributor') || currentUser.Account_Type__c.Contains('Partner')) {
            System.debug('Partner');
            PartnerProfile = true;
            PartnerDisclamer = true;
        }else if ((profileName  == 'Yotta Partner Profile' && currentUser.Account_Type__c.Contains('Distributor')) || profileName == 'Yotta Partner Manager Profile') {
            System.debug('Distributor');
            DistributorPartnerProfile = true;
            PartnerDisclamer = true;
        }else {
            System.debug('Sales');
            SalesProfile = true;
            SalesDisclamer = true;
        }
		system.debug('Profile Name'+profileName);
		system.debug('Sales Profile Name'+SalesProfile);
        system.debug('Parnter Profile Name'+PartnerProfile);
        system.debug('listOfProduct11' +listOfProduct);
        system.debug('listOfProductDimensions' +listOfProductDimensions);
        
    }
	
    public List<SBQQ__Dimension__c> GetDimension(Id ProductId){
        List<SBQQ__Dimension__c> dimen = [SELECT Id,Dimension_Type__c,Name,SBQQ__Type__c,Distributor_Price__c,Internal_Cost_Price__c,Partner_Price__c,Product_Head_Price__c,Sales_Head_Price__c,
                                  Sales_Price__c,SBQQ__UnitPrice__c,SBQQ__Product__c From SBQQ__Dimension__c WHERE SBQQ__Product__c = :ProductId ];
        return dimen;
    }    
    
    public class ProductDimensionWrapper{
        public string Name{get;set;}
        public string Family{get;set;}
        public string ProductLine{get;set;}
        public ProductDimensionWrapper(String Name,String Family,String ProductLine){
            this.Name = Name;
            this.Family = Family;
            this.ProductLine = ProductLine;
            
        }
        
    }
    
    
}