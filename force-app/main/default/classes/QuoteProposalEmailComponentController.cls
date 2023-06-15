public class QuoteProposalEmailComponentController {
	public QuoteProposalEmailComponentController() {
		System.debug(recId);
	}

	public Id recId {get; set;}
	public SBQQ__Quote__c quote {get{
			SBQQ__Quote__c quote = recId != null ? [SELECT Id, Owner.Name, Owner.Phone , Bill_To_Address__r.AddressLine1__c, Bill_To_Address__r.AddressLine2__c, Bill_To_Address__r.City__c, toLabel(Bill_To_Address__r.Country__c), SBQQ__Account__r.Name, Customer_Contact__r.Name, SBQQ__Account__c, SBQQ__Opportunity2__r.Name, Support_To_Customer__r.Name, Support_To_Customer__r.Phone FROM SBQQ__Quote__c WHERE Id = : recId]: new Sbqq__Quote__c();
			return quote;
		}
		set;
	}
}