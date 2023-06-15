public without sharing class partnerOpptyEmailController {
    public String quoteId{get;set;}
    
    public Sbqq__Quote__c getPartnerEmailInf{
        get{
         getPartnerEmailInf = quoteId != null ? [Select SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__c,SBQQ__Account__r.Name,Quote__c from SBQQ__Quote__c where
                                            id= : quoteId] : new Sbqq__Quote__c(); 
         return getPartnerEmailInf; 
       //  return quoteId != null ? [Select SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__c,SBQQ__Account__r.Name,Quote__c from SBQQ__Quote__c where
         //                                   id= : quoteId];
        } set; 
    }
}