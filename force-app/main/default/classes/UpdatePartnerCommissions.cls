/* ****************************************************************************************************************
Name          : updatePartnerCommissions
Description   : It is used for fetching desired field for partner comission screen A and B on quote
on Quote
Author        : Riya Sharma(Compro Technologies)
**************************************************************************************************************** */
public without sharing class UpdatePartnerCommissions{

    @AuraEnabled
    public static String profileName(){
        String profileName = [Select Id,Name from Profile where Id =: userinfo.getProfileId()].Name;
        //if(profileName != 'Yotta Partner Manager Profile'){
        //  System.debug('profileName' + profileName);
        //   }

        return profileName;
    }

    @AuraEnabled
    public static Boolean contractApprovedfun(String recordId){
        //List<Contract> ContractList = [SELECT Id,Status,StatusCode FROM Contract WHERE SBQQ__Opportunity__c = :recordId AND StatusCode != 'Draft'];
        List<Opportunity> ContractList = [SELECT Id,SBQQ__Contracted__c FROM Opportunity WHERE Id = :recordId AND SBQQ__Contracted__c = true];
        if (ContractList.size() > 0) {
            return true;
        }
        System.debug('ContractList'+ContractList);
        return false;
    }

    @AuraEnabled
    public static boolean checkSalesRepModelB(String recordId){
        System.debug('Record Id'+recordId);
        Boolean CheckSalesRep = false;
        List<Sbqq__Quote__c> quoteList = [SELECT SBQQ__Opportunity2__r.Partner_Sales_Rep__c,
                Partner_Commission__c,Partner_Commision_Model__c, Sales_Rep_Commission__c,
                SBQQ__Opportunity2__r.Partner_Commision_Model__c
        FROM Sbqq__Quote__c WHERE SBQQ__Opportunity2__c =: recordId
        and SBQQ__Primary__c = true];
        System.debug('QuoteList '+quoteList);
        for(SBQQ__Quote__c quote : quoteList){
            if(quote.SBQQ__Opportunity2__r.Partner_Sales_Rep__c == null){
                CheckSalesRep = true;
                return CheckSalesRep;
            }
        }
        return CheckSalesRep;
    }

    @AuraEnabled
    public static List<Opportunity> getQuoteStatus(Id recordId){

        List<Opportunity> quoteList = [Select SBQQ__Contracted__c,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.SBQQ__Status__c,SBQQ__PrimaryQuote__r.Contracted__c, Partner_Commision_Model__c,
                PrimarySource__c,SecondarySource__c,TertiarySource__c from
                Opportunity where id = :recordId];


        for(Opportunity opp : quoteList){
            if(opp.PrimarySource__c == null){
                opp.PrimarySource__c = 'null';
            }
            if(opp.SecondarySource__c == null){
                opp.SecondarySource__c = 'null';
            }
            if(opp.TertiarySource__c == null){
                opp.TertiarySource__c = 'null';
            }
        }

        return quoteList;

    }

    //This function gets the model type for further actions accordingly on bais of A or B type
    @AuraEnabled
    public static void getModelType(Id recordId,String modelType){


        Opportunity getModel = [Select Id, Partner_Commision_Model__c,SBQQ__Contracted__c from Opportunity where
                Id = :recordId];
        System.debug('getModel' + getModel);

        getModel.Partner_Commision_Model__c = modelType;
        update getModel;
    }


    //This function gets the start date and end date from quote and on basis of that it divided the years into first year
    //second year and so on. It then calculates the MRC value from quoteLine product depending in which year it falls in
    //and then lastly one time org and one time sales ic calculated using TCV value which is derived based on the formula
    @AuraEnabled
    public static List<Sbqq__Quote__c>  updatePartnerB(Id recordId){
        //Gets the percentage values from metadata required in the formula
        List<Partner_Commission_B__mdt> commissionModelList = [Select Year_1__c,Year_2__c,Year_3__c,Year_4__c,Year_5__c,
                Year_6_and_above__c,One_Time_Commission__c,One_Time_Sales__c
        FROM Partner_Commission_B__mdt
        WHERE MasterLabel = 'PartnerCommissionModelB'];

        List<Sbqq__Quote__c> quoteList = [SELECT TCV_Formula_for_Year_1__c,TCV_Formula_for_Year_2__c,TCV_Formula_for_Year_3__c,Contracted__c, SBQQ__Opportunity2__r.Partner_Sales_Rep__c,
                TCV_Formula_for_Year_4__c,TCV_Formula_for_Year_5__c,Partner_Commission__c,Partner_Commision_Model__c, Sales_Rep_Commission__c,
                SBQQ__Opportunity2__r.Partner_Commision_Model__c
        FROM Sbqq__quote__c WHERE SBQQ__Opportunity2__c =: recordId
        and SBQQ__Primary__c = true];

        System.debug('quoteList' + quoteList);
        Map<String,Partner_Commission_B__mdt> commissionMap = new Map<String, Partner_Commission_B__mdt>();
        for  ( Partner_Commission_B__mdt commission: commissionModelList) {
            commissionMap.put('commissionItems', commission);
        }
        System.debug('commissionMap' + commissionMap);
        Opportunity Oppor = [SELECT Id, Partner_Commision_Model__c,Partner_Sales_Rep__c FROM Opportunity WHERE Id = :recordId];
        Oppor.Partner_Commision_Model__c = 'Model B';
        for(Sbqq__Quote__c quote: quoteList){
            if(commissionMap.containsKey('commissionItems')){
                System.debug('hey');
                Partner_Commission_B__mdt value = commissionMap.get('commissionItems');
                System.debug('hii');
                if(quote.TCV_Formula_for_Year_1__c == null){
                    System.debug(value.Year_1__c + 'year1');
                    quote.TCV_Formula_for_Year_1__c = value.Year_1__c ;
                }
                if(quote.TCV_Formula_for_Year_2__c == null){
                    quote.TCV_Formula_for_Year_2__c = value.Year_2__c ;
                }
                if(quote.TCV_Formula_for_Year_3__c == null){
                    quote.TCV_Formula_for_Year_3__c = value.Year_3__c;
                }
                if(quote.TCV_Formula_for_Year_4__c == null){
                    quote.TCV_Formula_for_Year_4__c = value.Year_4__c ;
                }
                if(quote.TCV_Formula_for_Year_5__c == null){
                    quote.TCV_Formula_for_Year_5__c = value.Year_5__c ;
                }
                if(quote.Partner_Commission__c == null){
                    quote.Partner_Commission__c = value.One_Time_Commission__c ;
                }
                if(quote.Sales_Rep_Commission__c == null){
                    quote.Sales_Rep_Commission__c = value.One_Time_Sales__c ;
                }

                quote.Partner_Commision_Model__c = 'Model B';
                quote.Validate_Commission_Model__c = true;


            }

        }
        update Oppor;

        System.debug(quoteList);
        return quoteList;

    }

    //This method gets the list of categories from metadata and stamps them on partner Commission and partner Commission
    //Line. In case user makes any change in a certain value it marks the field on Partner Commission 'Approval required'
    //as Yes
    @AuraEnabled
    public static void updatePartnerCommissionModelB(List<Sbqq__Quote__c> editedList, Id recordId){
        //Update Partner_Commission object
        System.debug('bbbb');


        List<Partner_Commission_B__mdt> Commission_Model = [Select Year_1__c,Year_2__c,Year_3__c,Year_4__c,Year_5__c,
                Year_6_and_above__c,One_Time_Commission__c,One_Time_Sales__c
        FROM Partner_Commission_B__mdt
        WHERE MasterLabel = 'PartnerCommissionModelB'];

        List<Contract> contractList = [Select TCV_Formula_for_Year_1__c,TCV_Formula_for_Year_2__c,TCV_Formula_for_Year_3__c,TCV_Formula_for_Year_4__c,
                Partner_Commision_Model__c,
                TCV_Formula_for_Year_5__c,Partner_Commission__c,Sales_Rep_Commission__c from Contract where Sbqq__quote__r.SBQQ__Opportunity2__c
                = :recordId];

        //MAP metadata object fields to compare the data entries and see if there is any change
        Map<String,Partner_Commission_B__mdt> commissionModelMap = new Map<String, Partner_Commission_B__mdt>();
        System.debug('editedList' + editedList);
        Boolean Contracted = False;
        Decimal TCV1,TCV2,TCV3,TCV4,TCV5,partnerComm,SalesRep;
        Opportunity Oppor = [SELECT Id, Partner_Commision_Model__c FROM Opportunity WHERE Id = :recordId];
        Oppor.Partner_Commision_Model__c = 'Model B';

        for  ( Partner_Commission_B__mdt partner: Commission_Model) {
            commissionModelMap.put('Years', partner);
        }
        for (Sbqq__Quote__c partner :editedList) {
            if(partner.Contracted__c){
                Contracted = partner.Contracted__c;
                TCV1 = partner.TCV_Formula_for_Year_1__c;
                TCV2 = partner.TCV_Formula_for_Year_2__c;
                TCV3 = partner.TCV_Formula_for_Year_3__c;
                TCV4 = partner.TCV_Formula_for_Year_4__c;
                TCV5 = partner.TCV_Formula_for_Year_5__c;
                partnerComm = partner.Partner_Commission__c;
                SalesRep = partner.Sales_Rep_Commission__c;
                partner.Validate_Commission_Model__c = true;
            }

            /*
if(commissionModelMap.containsKey('Years')){
System.debug('bbbb');
Partner_Commission_B__mdt value = commissionModelMap.get(('Years'));
if((value.Year_1__c != partner.TCV_Formula_for_Year_1__c) || (value.Year_2__c != partner.TCV_Formula_for_Year_2__c) ||
(value.Year_3__c != partner.TCV_Formula_for_Year_3__c) || (value.Year_4__c != partner.TCV_Formula_for_Year_4__c) ||
(value.Year_5__c != partner.TCV_Formula_for_Year_5__c) || (value.One_Time_Commission__c != partner.Partner_Commission__c) ||
(value.One_Time_Sales__c != partner.Sales_Rep_Commission__c)){
system.debug('UNEQUAL');
}

}
*/
        }
        if(Contracted){
            for(Contract cont: contractList){

                cont.TCV_Formula_for_Year_1__c = TCV1;
                cont.TCV_Formula_for_Year_2__c = TCV2;
                cont.TCV_Formula_for_Year_3__c = TCV3;
                cont.TCV_Formula_for_Year_4__c = TCV4;
                cont.TCV_Formula_for_Year_5__c = TCV5;
                cont.Partner_Commission__c = partnerComm;
                cont.Sales_Rep_Commission__c = SalesRep;
            }
        }
        if(!(editedList.isEmpty()) && editedList != null){
            System.debug('eddd' + editedList);
            upsert editedList ;
        }
        if(!(contractList.isEmpty()) && contractList != null){
            System.debug('contractList' + contractList);
            upsert contractList ;
        }
    }

    //This function gets the category type and values from metadata and helps lightning view it on the screen.

    @AuraEnabled
    public static List<Sbqq__QuoteLine__c>  getPartnerLineList(Id recordId){
        List<Partner_Commission_A__mdt> commissionModelList = [SELECT Category_Type__c,  One_Time_Commission_on_Annual_Contract__c,
                Recurring_Commission_on_Actual_Billed__c FROM Partner_Commission_A__mdt
        WHERE Model_Type__c = 'Model A'];

        List<Sbqq__QuoteLine__c> quoteLineList = [Select Product_Line__c,SBQQ__Quantity__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Partner_Sales_Rep__c,Distributor_Partner_Commission__c,
                SBQQ__Quote__r.SBQQ__Opportunity2__r.PrimarySource__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.SecondarySource__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.TertiarySource__c,
                SBQQ__Product__r.Partner_Commission_Percent__c , SBQQ__Product__r.Distributor_Partner_Commission_Percent__c,SBQQ__Product__r.IPC_Partner_Commission_Percent__c, SBQQ__Product__r.Sales_Rep_Commission_Percent__c,
                Partner_Commission__c,Sales_Rep_Commission__c
        from sbqq__quoteLine__c where  SBQQ__Quote__r.SBQQ__Opportunity2__c =:RecordId
        and sbqq__requiredBy__c=null and SBQQ__Quote__r.SBQQ__Primary__c = true];

        List<Sbqq__Quote__c> quoteList = [Select Partner_Commision_Model__c,Contracted__c from Sbqq__Quote__c where SBQQ__Opportunity2__c = :recordId];
        Opportunity Oppor = [SELECT Id, Partner_Commision_Model__c FROM Opportunity WHERE Id = :recordId];
        Oppor.Partner_Commision_Model__c = 'Model A';
        System.debug('quoteLineList'+quoteLineList);
        List<Sbqq__QuoteLine__c> quoteLineNewList = new List<Sbqq__QuoteLine__c>();
        Set<String> productSet = new Set<String>();
        //Map the metadata with the custom object to update values.

        for(Sbqq__Quote__c quote: quoteList){
            quote.Partner_Commision_Model__c = 'Model A';
            quote.Partner_Commission__c = null;
            quote.TCV_Formula_for_Year_1__c =null;
            quote.TCV_Formula_for_Year_2__c =null;
            quote.TCV_Formula_for_Year_3__c =null;
            quote.TCV_Formula_for_Year_4__c =null;
            quote.TCV_Formula_for_Year_5__c =null;
            quote.Sales_Rep_Commission__c = null;
        }
        for(Sbqq__QuoteLine__c quoteLine: quoteLineList){
            //if(!productSet.contains(quoteLine.SBQQ__ProductFamily__c+ '_'+quoteLine.SBQQ__ProductName__c+'_'+quoteLine.Product_Line__c)){
                System.debug('productSet'+productSet);
                quoteLineNewList.add(quoteLine);
                if(quoteLine.Sales_Rep_Commission__c == null){
                    quoteLine.Sales_Rep_Commission__c = quoteLine.SBQQ__Product__r.Sales_Rep_Commission_Percent__c;
                }
                System.debug('Before Quoteline Partner Com'+quoteLine.Partner_Commission__c);

                if(quoteLine.Partner_Commission__c == null){

                    if((quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.PrimarySource__c != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.PrimarySource__c.contains('Distributor')) ||
                            (quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SecondarySource__c != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SecondarySource__c.contains('Distributor')) ||
                            (quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.TertiarySource__c !=null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.TertiarySource__c.contains('Distributor'))){
                        quoteLine.Distributor_Partner_Commission__c = quoteLine.SBQQ__Product__r.Distributor_Partner_Commission_Percent__c;
                        quoteLine.Partner_Commission__c = quoteLine.SBQQ__Product__r.Partner_Commission_Percent__c;
                        System.debug('Product Distributor Commission'+quoteLine.SBQQ__Product__r.Distributor_Partner_Commission_Percent__c);
                    }else if((quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.PrimarySource__c != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.PrimarySource__c.contains('IPC')) ||
                            (quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SecondarySource__c != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SecondarySource__c.contains('IPC')) ||
                            (quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.TertiarySource__c !=null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.TertiarySource__c.contains('IPC'))){
                        quoteLine.Partner_Commission__c = null;
                        quoteLine.Distributor_Partner_Commission__c = null;
                        quoteLine.Sales_Rep_Commission__c = quoteLine.SBQQ__Product__r.IPC_Partner_Commission_Percent__c;
                        System.debug('Product Distributor Commission'+quoteLine.SBQQ__Product__r.IPC_Partner_Commission_Percent__c);
                    }else{
                        quoteLine.Partner_Commission__c = quoteLine.SBQQ__Product__r.Partner_Commission_Percent__c;
                        quoteLine.Distributor_Partner_Commission__c = null;
                        System.debug('Product Partner Commission'+quoteLine.SBQQ__Product__r.Partner_Commission_Percent__c);
                    }
                    System.debug('Quoteline Partner Com'+quoteLine.Partner_Commission__c);
                }
                productSet.add(quoteLine.SBQQ__ProductFamily__c+ '_'+quoteLine.SBQQ__ProductName__c+'_'+quoteLine.Product_Line__c);
                System.debug('productSet'+productSet);
                System.debug('QuoteLine'+quoteLine);
            //}
        }
        System.debug(quoteLineList);
        try{
            update Oppor;
            update quoteList;
        }catch (Exception e){
            String message;
            if(e.getMessage().contains('Only Model B Can be Selected for the given Source')){
                message = 'Only Model B Can be Selected for the given Source';
            } else if(e.getMessage().contains('Only Model A or Model B Can be Selected for the given Source')){
                message = 'Only Model A or Model B Can be Selected for the given Source';
            } else if (e.getMessage().contains('Only TP Commission Model can be Selected for the given Source')){
                message = 'Only TP Commission Model can be Selected for the given Source';
            }else{
                message = 'Exception Occured'+e.getMessage();
                }
            if(message != null){
                throw new AuraHandledException( message);

            }
        }

        return quoteLineList;
    }

    //This method gets the list of categories from metadata and stamps them on partner Commission and partner Commission 
    //Line. In case user makes any change in a certain value it marks the field on Partner Commission 'Approval required'
    //as Yes 
    @AuraEnabled
    public static void updatePartnerCommission(List<Sbqq__QuoteLine__c> editedList, Id recordId){
        string errorMessage  = 'SUCCESS';
        Boolean Contracted = False;
        Decimal SalesRep,partnerComm;
        //Update Partner_Commission object


        List<Sbqq__QuoteLine__c> quoteLineList = [Select Product_Line__c,SBQQ__Quantity__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,Distributor_Partner_Commission__c,
                Partner_Commission__c,Sales_Rep_Commission__c,SBQQ__Quote__r.Contracted__c, SBQQ__Product__r.IPC_Partner_Commission_Percent__c,
                SBQQ__Product__r.Partner_Commission_Percent__c,SBQQ__Product__r.Sales_Rep_Commission_Percent__c
        from sbqq__quoteLine__c where  SBQQ__Quote__r.SBQQ__Opportunity2__c =:RecordId
        and sbqq__requiredBy__c=null and SBQQ__Quote__r.SBQQ__Primary__c = true];

        List<SBQQ__Subscription__c> subsList = [Select Product_Line__c,Product_Family__c,SBQQ__ProductName__c,SBQQ__Contract__c,Distributor_Partner_Commission__c,
                Partner_Commission__c,Sales_Rep_Commission__c,SBQQ__QuoteLine__c,SBQQ__Product__r.IPC_Partner_Commission_Percent__c,
                SBQQ__Product__r.Partner_Commission_Percent__c,SBQQ__Product__r.Sales_Rep_Commission_Percent__c from SBQQ__Subscription__c

        where SBQQ__Contract__r.SBQQ__Quote__r.SBQQ__Opportunity2__c =:RecordId and SBQQ__RequiredById__c=null ];
        Id contractId;
        if(!subsList.isEmpty()){
            contractId = subsList[0].SBQQ__Contract__c;
        }
        List<Contract> contList = [Select Partner_Commision_Model__c from Contract where Id=:contractId];

        SBQQ__Quote__c quote = [SELECT Id,Validate_Commission_Model__c FROM SBQQ__Quote__c WHERE SBQQ__Primary__c= true AND SBQQ__Opportunity2__c = :recordId] ;
        quote.Validate_Commission_Model__c = true;
        System.debug('quoteLineList' + quoteLineList);
        System.debug('editedList' + editedList);
        //MAP metadata object fields to compare the data entries and see if there is any change
        Map<String,Sbqq__QuoteLine__c> commissionModelMap = new Map<String, Sbqq__QuoteLine__c>();
        Map<Id,Sbqq__QuoteLine__c> quoteLineMap = new Map<Id, Sbqq__QuoteLine__c>();

        Set<Id> quoteLineId = new  Set<Id>();

        for  ( Sbqq__QuoteLine__c partner: editedList) {
            commissionModelMap.put(partner.SBQQ__ProductFamily__c+ '_'+partner.SBQQ__ProductName__c+'_'+partner.Product_Line__c, partner);
        }

        for (Sbqq__QuoteLine__c partnerLine :quoteLineList) {
            Contracted = partnerLine.SBQQ__Quote__r.Contracted__c;
            if(commissionModelMap.containsKey(partnerLine.SBQQ__ProductFamily__c+ '_'+partnerLine.SBQQ__ProductName__c+'_'+partnerLine.Product_Line__c)){
                quoteLineId.add(partnerLine.Id);
                system.debug(' products' +  partnerLine.Sales_Rep_Commission__c);
                Sbqq__QuoteLine__c value = commissionModelMap.get(partnerLine.SBQQ__ProductFamily__c+ '_'+partnerLine.SBQQ__ProductName__c+'_'+partnerLine.Product_Line__c);
                if((value.Sales_Rep_Commission__c != partnerLine.Sales_Rep_Commission__c)
                        || (value.Partner_Commission__c != partnerLine.Partner_Commission__c)){
                    system.debug('UNEQUAL');
                    system.debug(' partnerLine.Sales_Rep_Commission__c' +  partnerLine.Sales_Rep_Commission__c);
                    partnerLine.Sales_Rep_Commission__c = value.Sales_Rep_Commission__c;
                    partnerLine.Partner_Commission__c = value.Partner_Commission__c ;
                    partnerLine.Distributor_Partner_Commission__c = value.Distributor_Partner_Commission__c;
                    System.debug('value.Sales_Rep_Commission__c'+ value.Sales_Rep_Commission__c);
                }
            }
            quoteLineMap.put(partnerLine.Id,partnerLine);
        }

        if(Contracted){
            for(SBQQ__Subscription__c sub: subsList){

                if( quoteLineMap.containsKey(sub.SBQQ__QuoteLine__c)){
                    Sbqq__QuoteLine__c value = quoteLineMap.get(sub.SBQQ__QuoteLine__c);
                    sub.Sales_Rep_Commission__c = value.Sales_Rep_Commission__c;
                    sub.Partner_Commission__c = value.Partner_Commission__c;
                    sub.Distributor_Partner_Commission__c = value.Distributor_Partner_Commission__c;

                }

            }
            for(Contract con : contList){
                con.Partner_Commision_Model__c = 'Model A';
            }
        }

        if (quote != null) {
            update quote;
        }
        if(!(quoteLineList.isEmpty()) && quoteLineList != null){
            System.debug('update');
            upsert quoteLineList ;
        }
        if(!(subsList.isEmpty()) && subsList != null){
            System.debug('update');
            upsert subsList ;
        }
        if(!(contList.isEmpty()) && contList != null){
            System.debug('update');
            upsert contList ;
        }
    }

}