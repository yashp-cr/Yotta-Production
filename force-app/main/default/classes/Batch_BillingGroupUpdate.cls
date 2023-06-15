public class Batch_BillingGroupUpdate implements Database.Batchable < SObject > , Database.Stateful {
	//public List < Billing_Group__c > billGroupList {get;set;}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator('SELECT Id,Bandwidth_Type__c,Total_Contracted_Value__c,Total_Burstable_Up_To__c,Status__c,reset__c FROM Billing_Group__c WHERE reset__c = true');
	}

	public void execute(Database.BatchableContext bc, List < Billing_Group__c > scope) {
		Map < Id, List < SBQQ__Subscription__c > > billingGroupSubMap = new Map < Id, List < SBQQ__Subscription__c >> ();
		//billGroupList = new List < Billing_Group__c > ();

		List < SBQQ__Subscription__c > subList = [SELECT Id, SCF_Type__c, S_No__c, SBQQ__RequiredById__c, Base_Value__c, SBQQ__Bundle__c, Variable_Product__c, SBQQ__ProductOption__c, SBQQ__Contract__c,
                            Technical_Start_Date__c, Technical_End_Date__c, Bill_Start_Date__c,SBQQ__Contract__r.AccountId, SBQQ__Contract__r.Support_To_Account__c, Location__c, Billing_Group__c,
                            SBQQ__Quantity__c, SBQQ__SegmentIndex__c, Component_Quantity__c, Burstable_Upto__c, Burstable_upto_bundle__c, SBQQ__Product__c, SBQQ__Product__r.Model_Name__c,
                            Product_Family__c, Product_Line__c, SBQQ__ProductName__c, Bandwidth_Type__c, SBQQ__TerminatedDate__c, Status__c FROM SBQQ__Subscription__c
                            WHERE Billing_Group__c IN: scope AND Variable_Product__c = False AND SBQQ__Quantity__c >= 0 AND Technical_Start_Date__c != null AND Technical_End_Date__c = null];
        
		if (!subList.isEmpty() && subList.size() > 0) {
			for (SBQQ__Subscription__c sub: subList) {
				List < SBQQ__Subscription__c > subList1;
				if (billingGroupSubMap.containsKey(sub.Billing_Group__c))
					subList1 = billingGroupSubMap.get(sub.Billing_Group__c);
				else
					subList1 = new List < SBQQ__Subscription__c > ();
				subList1.add(sub);
				billingGroupSubMap.put(sub.Billing_Group__c, subList1);
			}
		}
		for (Billing_Group__c bg: scope) {
			bg.Total_Contracted_Value__c = 0;
			bg.Total_Burstable_Up_To__c = 0;
            Decimal compQ = 0;
			//bg.Status__c = 'Inactive';
			
            if (billingGroupSubMap.containsKey(bg.Id)) {
				for (SBQQ__Subscription__c sub: billingGroupSubMap.get(bg.Id)) {
					//if (!sub.Variable_Product__c) {
						if (bg.Bandwidth_Type__c == 'Burstable') {
							if(sub.Technical_End_Date__c != NULL || ((sub.Status__c == 'Renewed' || sub.Status__c=='Decommissioned') && sub.Bill_Start_Date__c != null )) {
								//billingGrp.reset__c = true;
								// if (sub.Technical_End_Date__c != NULL || (sub.Status__c == 'Renewed' && sub.Bill_Start_Date__c != null )) {

								//bg.Total_Contracted_Value__c = sub.Base_Value__c;
							}else {
								bg.Total_Contracted_Value__c += sub.Base_Value__c;
							}
							if (compQ < sub.Base_Value__c) {
								compQ = sub.Base_Value__c;
								bg.Total_Burstable_Up_To__c = sub.Burstable_upto_bundle__c;
							}

							} else if (bg.Bandwidth_Type__c == 'Data Transfer') {
								if(sub.Technical_End_Date__c != NULL || ((sub.Status__c == 'Renewed' || sub.Status__c=='Decommissioned') && sub.Bill_Start_Date__c != null )) {
								//billingGrp.reset__c = true;
								// if (sub.Technical_End_Date__c != NULL || (sub.Status__c == 'Renewed' && sub.Bill_Start_Date__c != null )) {

									//bg.Total_Contracted_Value__c -= sub.Base_Value__c;
								}else {
								bg.Total_Contracted_Value__c += sub.Base_Value__c;
								}
						/*if (bg.Bandwidth_Type__c == 'Burstable') {
							//if (!sub.Variable_Product__c && sub.Technical_Start_Date__c != null && sub.Technical_End_Date__c == null) {
								if (compQ < sub.Base_Value__c) {
									compQ = sub.Base_Value__c;
									bg.Total_Burstable_Up_To__c = sub.Burstable_upto_bundle__c;
								}
							//}
						}*/
					//}
				}
					if(sub.Status__c=='Active'){
						bg.status__c='Active';
					}
				}

				//bg.Status__c = 'Active';
			}
			bg.reset__c = false;
			//billGroupList.add(bg);
		}
		if (scope != null && scope.size() > 0)
			update scope;
	}

	public void finish(Database.BatchableContext bc) {}
}