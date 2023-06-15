public class AutoLeadConvertBatch implements Database.Batchable<Lead>{
    List<Lead> leads = new List<Lead>();
    public AutoLeadConvertBatch(List<Lead> convertLeads) {
        leads.addAll(convertLeads);
    }
    public List<Lead> start(Database.BatchableContext context)
	{
    	return leads;
	}
    public void execute(Database.BatchableContext BC, List<Lead> convertLeads) {
        Set<String> leadCompanies = new Set<String>();
        Set<String> leadEmails = new Set<String>();
        for(Lead l: convertLeads){
            leadCompanies.add(l.Company);
            leadEmails.add(l.Email);
        }
        
        List<Account> accountList = [Select id, name from Account where name =: leadCompanies];
        system.debug('accountList' + accountList);
        Map<String, Id> accountNameIdMap = new Map<String, Id>();
        for(Account a:accountList)
        	accountNameIdMap.put(a.name.toLowercase(), a.id);
            
        List<Contact> contactList = [Select id, AccountId, Email from Contact where email =: leadEmails];
        Map<String, Contact> contactEmailMap = new Map<String, Contact>();
        for(Contact c:contactList)
        	contactEmailMap.put(c.Email.toLowercase(), c);
            
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(Lead currentlead : convertLeads){
        	//if(!(accountNameIdMap.containsKey(currentlead.Company) && contactEmailMap.containsKey(currentlead.Email))){
        	if(!contactEmailMap.containsKey(currentlead.Email.toLowercase()) || (contactEmailMap.containsKey(currentlead.Email.toLowercase()) && accountNameIdMap.containsKey(currentlead.Company.toLowercase()) && contactEmailMap.get(currentlead.Email.toLowercase()).AccountId == accountNameIdMap.get(currentlead.Company.toLowercase()))){
                Database.LeadConvert Leadconvert = new Database.LeadConvert();
                Leadconvert.setLeadId(currentlead.id);                
                Leadconvert.setConvertedStatus('Assigned to Sales');
                if(accountNameIdMap.containsKey(currentlead.Company.toLowercase()))
                	Leadconvert.setAccountId(accountNameIdMap.get(currentlead.Company.toLowercase())); 
                if(contactEmailMap.containsKey(currentlead.Email.toLowercase()))
                	Leadconvert.setContactId(contactEmailMap.get(currentlead.Email.toLowercase()).id); 
                Leadconvert.setDoNotCreateOpportunity(TRUE);
                
                MassLeadconvert.add(Leadconvert);
            }
        }
            
        if (!MassLeadconvert.isEmpty()) {
        	List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
        }
    }
    public void finish(Database.BatchableContext BC) {}
}


/*public class AutoLeadConvertBatch implements Database.Batchable<Database.LeadConvert>{
    List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
    public AutoLeadConvertBatch(List<Database.LeadConvert> leadconverts) {
        MassLeadconvert.addAll(leadconverts);
    }
    public List<Database.LeadConvert> start(Database.BatchableContext context)
	{
    	return MassLeadconvert;
	}
    public void execute(Database.BatchableContext BC, List<Database.LeadConvert> MassLeadconvert) {
        List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
    }
    public void finish(Database.BatchableContext BC) {}
}*/