public class SOFEmailComponentController {
    public SOFEmailComponentController() {

    }

    public Id recId {get; set;}
	public Contract contract {get{
			Contract contract = [SELECT Id, Owner.Name, Owner.Phone , Bill_To_Address__r.AddressLine1__c, Bill_To_Address__r.AddressLine2__c, Bill_To_Address__r.City__c, toLabel(Bill_To_Address__r.Country__c), Account.Name, Customer_Authorised_Signatory__r.Name, AccountId, SBQQ__Opportunity__r.Name, Support_To_Account__r.Name, Support_To_Account__r.Phone FROM Contract WHERE Id = : recId];
			return contract;
		}
		set;
	}
}