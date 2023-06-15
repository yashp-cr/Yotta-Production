//************************************************
//****** Test Class: LeadTriggerHandlerTest ******
//************************************************

public class LeadTriggerHandler extends TriggerHandler {
    
    
    
    
    public override void afterInsert() {
        updateLeadCreatorSharing ((List<Lead>)trigger.new, null);
        leadConversion((List<Lead>)trigger.new);
        updateLeadSharingOnPartnerAcc ((List<Lead>)trigger.new, null);
    }
    
    public override void afterUpdate() {
        updateLeadCreatorSharing( (List<Lead>)trigger.new, (Map<Id, Lead>)trigger.oldMap);  
        updatePartnerSourceonAccount((List<Lead>)trigger.new, (Map<Id, Lead>)trigger.oldMap);
        updateLeadSharingOnPartnerAcc( (List<Lead>)trigger.new, (Map<Id, Lead>)trigger.oldMap);
    }
    
    public override void beforeInsert() {
        beforeInsertLeadSharingOnPartnerAcc((List < Lead > ) trigger.new);
        //-------State Compute Begin----------
        List<Lead> leadsList = new List<Lead>();
        Set<String> stateKeys = new Set<String>();
        /*
Id RegularLeadRecordTypeId = [Select Id__c from ID__mdt where DeveloperName = 'Regular_Lead'].Id__c;
Id ISTeamId = [Select Id__c from ID__mdt where DeveloperName = 'Yotta_IS_Team'].Id__c;
//Id teamId = [select id from Group where DeveloperName = 'IS_Team'].id;
Id CharmiUserId = [Select Id__c from ID__mdt where DeveloperName = 'CharmiUserId'].Id__c;
*/
        
        for(Lead l : (List<Lead>)trigger.new){
            /*
if(l.RecordTypeId == RegularLeadRecordTypeId && l.Auto_Convert__c != 'Yes') {
if((l.PrimarySource__c!=null && (l.PrimarySource__c.contains( 'Partner') || l.PrimarySource__c.contains( 'Partne Site') )) || (l.SecondarySource__c!=null && l.SecondarySource__c.contains('Partner' )) || (l.TertiarySource__c!=null && l.TertiarySource__c.contains( 'Partner' ))) {                   
l.OwnerId = CharmiUserId;
} else
l.OwnerId = ISTeamId;
}
*/
            if((l.State_External_Key__c != '' || l.State_External_Key__c != null) && (l.State__c == null)){
                leadsList.add(l);
                stateKeys.add(l.State_External_Key__c);
            }
        }
        if(!leadsList.isEmpty())
            stateCompute(leadsList, stateKeys);
        //-------State Compute End----------
    }
    
    public override void beforeUpdate() {
        beforeInsertLeadSharingOnPartnerAcc((List < Lead > ) trigger.new);
        //-------State Update Begin----------
        List<Lead> leadsList = new List<Lead>();
        Set<String> stateKeys = new Set<String>();
        Map<Id, Lead> mapTriggerOld = (Map<Id, Lead>)trigger.oldMap;
        for(Lead l : (List<Lead>)trigger.new){
            if((l.State_External_Key__c != '' || l.State_External_Key__c != null) && l.State_External_Key__c != mapTriggerOld .get(l.id).State_External_Key__c && l.State__c == mapTriggerOld.get(l.id).State__c){
                leadsList.add(l);
                stateKeys.add(l.State_External_Key__c);
            }
        }
        if(!leadsList.isEmpty())
            stateCompute(leadsList, stateKeys);
        //-------State Update End----------
    }
    
    private void updateLeadCreatorSharing( List<Lead> lstTriggerNew, Map<Id, Lead> mapTriggerOld ) {
        List<LeadShare> lstLeadShareToInsert = new List<LeadShare>();
        List<LeadShare> lstLeadShareToDelete = new List<LeadShare>();
        
        if( mapTriggerOld == null ) {
            
            for( Lead objLead : lstTriggerNew ) {
                lstLeadShareToInsert.add( new LeadShare(LeadAccessLevel='Read', LeadId=objLead.Id, UserOrGroupId=UserInfo.getUserId()) );
            }
            createShareForCreator( JSON.serialize(lstLeadShareToInsert) );
        } else {
            Set<Id> setUserIds = new Set<Id>();
            List<Lead> lstLeadsToShare = new List<Lead>();
            for( Lead objLead : lstTriggerNew ) {
                if( objLead.Creator__c != null && (objLead.Creator__c != mapTriggerOld.get( objLead.Id ).Creator__c || objLead.OwnerId != mapTriggerOld.get(objLead.Id).OwnerId)) {
                    setUserIds.add( mapTriggerOld.get( objLead.Id ).Creator__c );
                    lstLeadsToShare.add( objLead );
                }
            }
            
            Map<Id, Map<Id, Id>> mapLeadToUsers = new Map<Id, Map<Id, Id>>();
            for( LeadShare objLeadShare : [Select UserOrGroupId, LeadId, Id from LeadShare where LeadId In:lstLeadsToShare And UserOrGroupId In:setUserIds And RowCause='Manual']) {
                if( !mapLeadToUsers.containsKey(objLeadShare.LeadId) ) {
                    mapLeadToUsers.put( objLeadShare.LeadId, new Map<Id, Id>{ objLeadShare.UserOrGroupId => objLeadShare.Id } );
                    continue;
                }
                mapLeadToUsers.get(objLeadShare.LeadId).put( objLeadShare.UserOrGroupId, objLeadShare.Id );
            }
            
            for( Lead objLead : lstLeadsToShare ) {
                if( mapLeadToUsers.containsKey( objLead.Id ) && 
                   mapLeadToUsers.get( objLead.Id ).containsKey( mapTriggerOld.get( objLead.Id ).Creator__c ) ) {
                       lstLeadShareToDelete.add( new LeadShare( Id=mapLeadToUsers.get( objLead.Id ).get( mapTriggerOld.get( objLead.Id ).Creator__c ) ) );
                   }
                lstLeadShareToInsert.add( new LeadShare(LeadAccessLevel='Read', LeadId=objLead.Id, UserOrGroupId=objLead.Creator__c) );
            }
            if( !lstLeadShareToInsert.isEmpty() )
                database.insert( lstLeadShareToInsert, false ) ;
            if( !lstLeadShareToDelete.isEmpty() ) 
                database.delete( lstLeadShareToDelete, false );
        }
    }
    
    private void beforeInsertLeadSharingOnPartnerAcc(List<Lead> lstTriggerNew){
        Id groupSecId;
        Id groupTerId;
        Set<Id> secPartner = new Set<Id>();
        Set<Id> terPartner = new Set<Id>();
        Map<Id,  Id> mapLeadToUsers = new Map<Id, Id>();
        Map<Id,  Id> mapSecToUsers = new Map<Id, Id>();
        Map<Id,  Id> mapLeadToUsers1 = new Map<Id, Id>();
        Map<Id,  Id> mapTerToUsers = new Map<Id, Id>();
        Id groupSecVal;
        Id groupTerVal;
        
        
        for(Lead leadObj: lstTriggerNew){
            secPartner.add(leadObj.Partner_Secondary__c);
            terPartner.add(leadObj.Partner_Tertiary__c);
        }    
        List<UserRole> userRoleList = [SELECT id,PortalAccountId FROM UserRole WHERE PortalAccountId = :secPartner ];
        List<Group> groupList = [SELECT Id,RelatedId FROM Group WHERE RelatedId in :userRoleList  and Type = 'RoleAndSubordinates' ] ;        
        List<UserRole> userRoleList1 = [SELECT id,PortalAccountId FROM UserRole WHERE PortalAccountId = :terPartner ];
        List<Group> groupList1 = [SELECT Id,RelatedId FROM Group WHERE RelatedId in :userRoleList1  and Type = 'RoleAndSubordinates' ] ; 
        
        for( UserRole userRole :userRoleList ){
            if( !mapLeadToUsers.containsKey(userRole.Id) ) {
                mapLeadToUsers.put( userRole.Id, userRole.PortalAccountId  );
            }
        }
        
        for(Group groupSec: groupList){
            if(mapLeadToUsers.containsKey(groupSec.RelatedId)){
                Id val = mapLeadToUsers.get(groupSec.RelatedId);
                if( !mapSecToUsers.containsKey(groupSec.Id) ) {
                    mapSecToUsers.put( val,groupSec.Id);
                }
                
                
            }
        }
        
        for( UserRole userRole :userRoleList1 ){
            if( !mapLeadToUsers1.containsKey(userRole.Id) ) {
                mapLeadToUsers1.put( userRole.Id, userRole.PortalAccountId  );
            }
        }
        
        for(Group groupTer: groupList1){
            if(mapLeadToUsers1.containsKey(groupTer.RelatedId)){
                Id val = mapLeadToUsers1.get(groupTer.RelatedId);
                if( !mapTerToUsers.containsKey(groupTer.Id) ) {
                    mapTerToUsers.put( val,groupTer.Id);
                }
                
                
            }
        }
        
        
        for(Lead leadObj: lstTriggerNew){
            if(leadObj.Partner_Secondary__c != null && mapSecToUsers.containsKey(leadObj.Partner_Secondary__c)){
                groupSecVal = mapSecToUsers.get(leadObj.Partner_Secondary__c);
                leadObj.SecondaryPartnerGroupId__c = groupSecVal;
            }
            else{
                leadObj.SecondaryPartnerGroupId__c = null;
            }
            
            if(leadObj.Partner_Tertiary__c != null && mapTerToUsers.containsKey(leadObj.Partner_Tertiary__c)){
                groupTerVal = mapTerToUsers.get(leadObj.Partner_Tertiary__c);
                leadObj.TertiaryPartnerGroupId__c = groupTerVal;   
            }
            else{
                leadObj.TertiaryPartnerGroupId__c = null;
            }
            
        }
    }
    
    private void updateLeadSharingOnPartnerAcc( List<Lead> lstTriggerNew, Map<Id, Lead> mapTriggerOld ) {
        
        List<LeadShare> lstLeadShareToInsert = new List<LeadShare>();
        List<LeadShare> lstLeadShareToDelete = new List<LeadShare>();       
        List<Lead> lstLeadsToShare = new List<Lead>();
        Set<Id> AccountIds = new set<Id>();  
        
        for( Lead objLead : lstTriggerNew ) {
            if( mapTriggerOld == null){
                if(objLead.Partner_Secondary__c != null){
                    lstLeadShareToInsert.add( new LeadShare(LeadAccessLevel='Read', LeadId=objLead.Id, UserOrGroupId=objLead.SecondaryPartnerGroupId__c) );
                }
                if(objLead.Partner_Tertiary__c != null){
                    lstLeadShareToInsert.add( new LeadShare(LeadAccessLevel='Read', LeadId=objLead.Id, UserOrGroupId=objLead.TertiaryPartnerGroupId__c) );
                }
                
                
            }
            
            else {
                Set<Id> UserIds = new Set<Id>();
                if(objLead.Partner_Secondary__c != mapTriggerOld.get( objLead.Id ).Partner_Secondary__c ){
                    //lstLeadShareToDelete = [Select id,UserOrGroupId from leadshare where leadid= :objLead.Id and UserOrGroupId =: mapTriggerOld.get( objLead.Id ).SecondaryPartnerGroupId__c];
                    lstLeadShareToInsert.add( new LeadShare(LeadAccessLevel='Read', LeadId=objLead.Id, UserOrGroupId=objLead.SecondaryPartnerGroupId__c) );
                    lstLeadsToShare.add( objLead );
                    AccountIds.add(mapTriggerOld.get( objLead.Id ).SecondaryPartnerGroupId__c);
                }   
                if(objLead.Partner_Tertiary__c != mapTriggerOld.get( objLead.Id ).Partner_Tertiary__c ) {
                    //lstLeadShareToDelete = [Select id from leadshare where leadid= :objLead.Id and UserOrGroupId =: mapTriggerOld.get( objLead.Id ).TertiaryPartnerGroupId__c];
                    
                    lstLeadShareToInsert.add( new LeadShare(LeadAccessLevel='Read', LeadId=objLead.Id, UserOrGroupId=objLead.TertiaryPartnerGroupId__c) );
                    lstLeadsToShare.add( objLead );
                    AccountIds.add(mapTriggerOld.get( objLead.Id ).TertiaryPartnerGroupId__c);
                }
            }
        }
        Map<Id, Map<Id, Id>> mapLeadToUsers = new Map<Id, Map<Id, Id>>();
        if( !lstLeadsToShare.isEmpty() ){
            for( LeadShare objLeadShare : [Select id,UserOrGroupId,LeadId from leadshare where leadid= :lstLeadsToShare and UserOrGroupId =:AccountIds and RowCause='Manual']) {
                if( !mapLeadToUsers.containsKey(objLeadShare.LeadId) ) {
                    mapLeadToUsers.put( objLeadShare.LeadId, new Map<Id, Id>{ objLeadShare.UserOrGroupId => objLeadShare.Id } );
                    continue;
                }
                mapLeadToUsers.get(objLeadShare.LeadId).put( objLeadShare.UserOrGroupId, objLeadShare.Id );
            }
            
            for( Lead objLead : lstLeadsToShare ) {
                if( mapLeadToUsers.containsKey( objLead.Id ) && 
                   mapLeadToUsers.get( objLead.Id ).containsKey(mapTriggerOld.get( objLead.Id ).SecondaryPartnerGroupId__c )) {
                       
                       lstLeadShareToDelete.add( new LeadShare( Id=mapLeadToUsers.get( objLead.Id ).get( mapTriggerOld.get(objLead.Id ).SecondaryPartnerGroupId__c ) ));
                   }
                if( mapLeadToUsers.containsKey( objLead.Id ) && 
                   mapLeadToUsers.get( objLead.Id ).containsKey(mapTriggerOld.get( objLead.Id ).TertiaryPartnerGroupId__c )) {
                       lstLeadShareToDelete.add( new LeadShare( Id=mapLeadToUsers.get( objLead.Id ).get( mapTriggerOld.get(objLead.Id ).TertiaryPartnerGroupId__c ) ));
                   }
            }
        }
        
        if( !lstLeadShareToInsert.isEmpty() )
            createShareForCreator( JSON.serialize(lstLeadShareToInsert));
        if( !lstLeadShareToDelete.isEmpty() ) 
            database.delete( lstLeadShareToDelete, false );
        
        
    }    
    
    
    private void updatePartnerSourceonAccount( List<Lead> lstTriggerNew, Map<Id, Lead> mapTriggerOld ) {
        
        List<Account> accsToUpdate = new List<Account>();
        Map<Id,Lead> leadIdMap = new Map<Id,Lead>();
        Map<Id,Account> partnerAccMap = new Map<Id,Account>(); 
        Map<Id,Campaign> campaignMap = new Map<Id,Campaign>(); 
        Map<Id,Account> convertedAccMap = new Map<Id,Account>(); 
        Set<Id> partnerAccountIds = new set<Id>(); 
        Set<Id> CampaignIds = new set<Id>(); 
        Set<Id> convertedAccIds = new Set<Id>();
        
        for( Lead objLead : lstTriggerNew ) {
            
            if(objLead.isConverted  != mapTriggerOld.get( objLead.Id).isConverted   && objLead.isConverted && !mapTriggerOld.get( objLead.Id).isConverted){
                System.debug('ConvertedAccountId ' + objLead.ConvertedAccountId );
                if(objLead.Primary_Campaign__c != null){
                    CampaignIds.add(objLead.Primary_Campaign__c);
                     if(!convertedAccMap.containsKey(objLead.ConvertedAccountId)){
                        convertedAccIds.add(objLead.ConvertedAccountId);
                    }
                    if(!leadIdMap.containsKey(objLead.ConvertedAccountId)){
                        leadIdMap.put(objLead.ConvertedAccountId,objLead); //lead id,obj
                    }
                }
                if(objLead.Secondary_Campaign__c != null){
                    CampaignIds.add(objLead.Secondary_Campaign__c);
                     if(!convertedAccMap.containsKey(objLead.ConvertedAccountId)){
                        convertedAccIds.add(objLead.ConvertedAccountId);
                    }
                    if(!leadIdMap.containsKey(objLead.ConvertedAccountId)){
                        leadIdMap.put(objLead.ConvertedAccountId,objLead); //lead id,obj
                    }
                }
                 if(objLead.Tertiary_Campaign__c != null){
                    CampaignIds.add(objLead.Tertiary_Campaign__c);
                      if(!convertedAccMap.containsKey(objLead.ConvertedAccountId)){
                        convertedAccIds.add(objLead.ConvertedAccountId);
                    }
                    if(!leadIdMap.containsKey(objLead.ConvertedAccountId)){
                        leadIdMap.put(objLead.ConvertedAccountId,objLead); //lead id,obj
                    }
                }
                if(objLead.Partner_Primary__c != null ){
                    partnerAccountIds.add(objLead.Partner_Primary__c);  //converted ac set
                    if(!convertedAccMap.containsKey(objLead.ConvertedAccountId)){
                        convertedAccIds.add(objLead.ConvertedAccountId);
                    }
                    if(!leadIdMap.containsKey(objLead.ConvertedAccountId)){
                        leadIdMap.put(objLead.ConvertedAccountId,objLead); //lead id,obj
                    }
                }
                if(objLead.Partner_Secondary__c != null){
                    partnerAccountIds.add(objLead.Partner_Secondary__c);  //converted ac set
                    if(!convertedAccMap.containsKey(objLead.ConvertedAccountId)){
                        convertedAccIds.add(objLead.ConvertedAccountId);
                    }
                    if(!leadIdMap.containsKey(objLead.ConvertedAccountId)){
                        leadIdMap.put(objLead.ConvertedAccountId,objLead); //lead id,obj
                    }
                    
                } 
                if(objLead.Partner_Tertiary__c != null){
                    partnerAccountIds.add(objLead.Partner_Tertiary__c);  //converted ac set
                    if(!leadIdMap.containsKey(objLead.ConvertedAccountId)){
                        leadIdMap.put(objLead.ConvertedAccountId,objLead); //lead id,obj
                    }
                    if(!leadIdMap.containsKey(objLead.ConvertedAccountId)){
                        leadIdMap.put(objLead.ConvertedAccountId,objLead); //lead id,obj
                    }
                }  
            }            
        }
        
        //if partner primary account exists
        if(partnerAccountIds != null){
            partnerAccMap = new Map<Id, Account>([Select Id,name,Account_Number__c  from Account where id in :partnerAccountIds]);//id,account              
        }
        if(CampaignIds != null){
            campaignMap = new Map<Id, Campaign>([Select Id,name from Campaign where id in :CampaignIds]);
        }
        
        //if converted account exists
        if(convertedAccIds != null){
            convertedAccMap = new Map<Id, Account>([Select Id,name,Primary_Campaign_Name__c,Converted_from_lead_Id__c,Secondary_Campaign_Name__c,Tertiary_Campaign_Name__c,Primary_Campaign_Id__c,Secondary_Campaign_Id__c,Tertiary_Campaign_Id__c,Partner_Primary_Id__c,Partner_Secondary_Id__c,Partner_Secondary_Source_Id__c,Partner_Tertiary_Id__c,Partner_Tertiary_Source_Id__c,Partner_Tertiary_Source_Name__c,	Partner_Primary_Source_Name__c,Partner_Primary_Source_Id__c,Account_Number__c  from Account where id in :convertedAccIds]);//id,account              
        }
        
        if(leadIdMap != null){            
            for(Lead leadVal: leadIdMap.values()){ 
                //traverse leadidmap converted id
                if(leadVal.Lead_Id__c == convertedAccMap.get(leadVal.ConvertedAccountId).Converted_from_lead_Id__c){
                if(leadVal.Partner_Primary__c != null){
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Primary_Id__c = leadVal.Partner_Primary__c;
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Primary_Source_Id__c = partnerAccMap.get(leadVal.Partner_Primary__c).Account_Number__c;
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Primary_Source_Name__c =  partnerAccMap.get(leadVal.Partner_Primary__c).Name;
                }
                if(leadVal.Partner_Secondary__c != null){
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Secondary_Id__c = leadVal.Partner_Secondary__c;
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Secondary_Source_Id__c = partnerAccMap.get(leadVal.Partner_Secondary__c).Account_Number__c;
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Secondary_Source_Name__c =  partnerAccMap.get(leadVal.Partner_Secondary__c).Name;
                }
                if(leadVal.Partner_Tertiary__c != null){
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Tertiary_Id__c = leadVal.Partner_Tertiary__c;
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Tertiary_Source_Id__c = partnerAccMap.get(leadVal.Partner_Tertiary__c).Account_Number__c;
                    convertedAccMap.get(leadVal.ConvertedAccountId).Partner_Tertiary_Source_Name__c =  partnerAccMap.get(leadVal.Partner_Tertiary__c).Name;
                }
                 if(leadVal.Primary_Campaign__c != null){
                     System.debug('leadVal.Primary_Campaign__c' + leadVal.Primary_Campaign__c);
                    convertedAccMap.get(leadVal.ConvertedAccountId).Primary_Campaign_Id__c = leadVal.Primary_Campaign__c;
                   convertedAccMap.get(leadVal.ConvertedAccountId).Primary_Campaign_Name__c =  campaignMap.get(leadVal.Primary_Campaign__c).Name;
                }
                if(leadVal.Secondary_Campaign__c != null){
                    convertedAccMap.get(leadVal.ConvertedAccountId).Secondary_Campaign_Id__c = leadVal.Secondary_Campaign__c;
                   convertedAccMap.get(leadVal.ConvertedAccountId).Secondary_Campaign_Name__c =  campaignMap.get(leadVal.Secondary_Campaign__c).Name;
                }
                 if(leadVal.Tertiary_Campaign__c != null){
                    convertedAccMap.get(leadVal.ConvertedAccountId).Tertiary_Campaign_Id__c = leadVal.Tertiary_Campaign__c;
                    convertedAccMap.get(leadVal.ConvertedAccountId).Tertiary_Campaign_Name__c =  campaignMap.get(leadVal.Tertiary_Campaign__c).Name;
                }
                }
                
            }
            
            
            
        }
        
        if (!convertedAccMap.isEmpty() && convertedAccMap != null) {
            update convertedAccMap.values();
        }
        
        
        
        
        
    } 
    
    
    
    
    @future
    public static void createShareForCreator( String strShareRecords ) {
        List<LeadShare> lstLeadShareToInsert = (List<LeadShare>)JSON.deserialize(strShareRecords, List<LeadShare>.class);
        Database.insert( lstLeadShareToInsert, false );
    }
    
    /*public static void leadConversion(List<Lead> newLeads)
{
Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Regular Lead').getRecordTypeId();
Set<String> leadCompanies = new Set<String>();
Set<String> leadEmails = new Set<String>();
List<Lead> targetLeads = new List<Lead>();
for(Lead l: newLeads){
if(!l.isConverted && l.Auto_Convert__c && l.RecordTypeId==recordTypeId){
leadCompanies.add(l.Company);
leadEmails.add(l.Email);
targetLeads.add(l);
}
}

if(!targetLeads.isEmpty()){
List<Account> accountList = [Select id, name from Account where name =: leadCompanies];
Map<String, Id> accountNameIdMap = new Map<String, Id>();
for(Account a:accountList)
accountNameIdMap.put(a.name, a.id);

List<Contact> contactList = [Select id, AccountId, Email from Contact where email =: leadEmails];
Map<String, Contact> contactEmailMap = new Map<String, Contact>();
for(Contact c:contactList)
contactEmailMap.put(c.Email, c);

List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
for(Lead currentlead: targetLeads){
//if(!currentlead.isConverted && currentlead.Auto_Convert__c && currentlead.RecordTypeId==recordTypeId) {
//if(accountNameIdMap.containsKey(currentlead.Company) && contactEmailIdMap.containsKey(currentlead.Email)){
if(!contactEmailMap.containsKey(currentlead.Email) || (contactEmailMap.containsKey(currentlead.Email) && accountNameIdMap.containsKey(currentlead.Company) && contactEmailMap.get(currentlead.Email).AccountId == accountNameIdMap.get(currentlead.Company))){
Database.LeadConvert Leadconvert = new Database.LeadConvert();
Leadconvert.setLeadId(currentlead.id);                
Leadconvert.setConvertedStatus('Assigned to Sales');
if(accountNameIdMap.containsKey(currentlead.Company))
Leadconvert.setAccountId(accountNameIdMap.get(currentlead.Company)); 
if(contactEmailMap.containsKey(currentlead.Email))
Leadconvert.setContactId(contactEmailMap.get(currentlead.Email).id); 
Leadconvert.setDoNotCreateOpportunity(TRUE);

MassLeadconvert.add(Leadconvert);
}
//}
}

if (!MassLeadconvert.isEmpty()) {
List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
//Database.executeBatch(new AutoLeadConvertBatch(MassLeadconvert), 20);
}
}
}*/
    
    public static void leadConversion(List<Lead> newLeads)
    {
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Regular Lead').getRecordTypeId();
        List<Lead> convertLeads = new List<Lead>();
        for(Lead l: newLeads){
            if(!l.isConverted && l.Auto_Convert__c=='Yes' && l.RecordTypeId==recordTypeId){
                convertLeads.add(l);
            }
        }
        
        if(!convertLeads.isEmpty()){
            //Database.executeBatch(new AutoLeadConvertBatch(convertLeads), 200);
            //Executing a batch after 5 minutes because lead conversion makes lead read only and updates from campaign member process were failing
            AutoLeadConvertBatch batchable = new AutoLeadConvertBatch(convertLeads);
            String jobName = 'Lead Auto Convert Job' + Datetime.now().getTime();
            String cronId = System.scheduleBatch(batchable, jobName, 5, 200);
        }
    }
    
    public static void stateCompute(List<Lead> newLeads, Set<String> stateKeys) {
        Map<String, State__c> StateKeyMap = new Map<String, State__c>();
        for(State__c st : [Select id, External_Key__c from State__c where External_Key__c IN : stateKeys])
            StateKeyMap.put(st.External_Key__c, st);
        for(Lead l : newLeads){
            if(StateKeyMap.keySet().contains(l.State_External_Key__c))
                l.State__c = StateKeyMap.get(l.State_External_Key__c).id;
            else
                l.state__c = NULL;
        }
    }
}