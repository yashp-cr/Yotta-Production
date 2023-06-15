public class OpportunityTriggerHandler extends TriggerHandler {

    private Boolean isScheduled = false;

    public override void afterInsert() {
        updateOppSharingOnPartnerAcc ((List<Opportunity>)trigger.new, null);
    }

    public override void afterUpdate() {
        updateOppSharingOnPartnerAcc( (List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);        
        sendPendingApprovalProcessQuote( (List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
        if( !isScheduled ) { 
            integrateSCFContracts( (Map<Id, Opportunity>)trigger.newMap, (Map<Id, Opportunity>)trigger.oldMap );
        }
        isScheduled = true;
    }

    public override void beforeInsert() {
        beforeInsertOpp((List <Opportunity>) trigger.new);
        InsertPartnerCommission((List <Opportunity>) trigger.new);
    }

    public override void beforeUpdate() {
        beforeInsertOpp((List <Opportunity>) trigger.new);
    }

    private void beforeInsertOpp(List<Opportunity> lstTriggerNew) {
        Id groupSecId;
        Id groupTerId;
        Set<Id> secPartner = new Set<Id>();
        Set<Id> terPartner = new Set<Id>();
        Map<Id, Id> mapOppToUsers = new Map<Id, Id>();
        Map<Id, Id> mapSecToUsers = new Map<Id, Id>();
        Map<Id, Id> mapOppToUsers1 = new Map<Id, Id>();
        Map<Id, Id> mapTerToUsers = new Map<Id, Id>();
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>)trigger.oldMap;

        for (Opportunity oppObj : lstTriggerNew) {
            if(trigger.isInsert){
                if(oppObj.PartnerSecondary__c != NULL){
                    secPartner.add(oppObj.PartnerSecondary__c);
                }
                if(oppObj.PartnerTertiary__c != NULL){
                    terPartner.add(oppObj.PartnerTertiary__c);
                }
            }else{
                if(oppObj.PartnerSecondary__c != oldMap.get(oppObj.Id).PartnerSecondary__c){
                    secPartner.add(oppObj.PartnerSecondary__c);
                }

                if(oppObj.PartnerTertiary__c != oldMap.get(oppObj.Id).PartnerTertiary__c){
                    terPartner.add(oppObj.PartnerTertiary__c);
                }
            }
        }

        if(terPartner.size() > 0 || secPartner.size() > 0){
            List<UserRole> userRoleList = [SELECT id, PortalAccountId FROM UserRole WHERE PortalAccountId = :secPartner ];
            List<Group> groupList = [SELECT Id, RelatedId FROM Group WHERE RelatedId in :userRoleList  and Type = 'RoleAndSubordinates' ] ;
            List<UserRole> userRoleList1 = [SELECT id, PortalAccountId FROM UserRole WHERE PortalAccountId = :terPartner ];
            List<Group> groupList1 = [SELECT Id, RelatedId FROM Group WHERE RelatedId in :userRoleList1  and Type = 'RoleAndSubordinates' ] ;
        
            for ( UserRole userRole : userRoleList ) {
                if ( !mapOppToUsers.containsKey(userRole.Id) ) {
                    mapOppToUsers.put( userRole.Id, userRole.PortalAccountId  );
                }
            }

            for (Group groupSec : groupList) {
                if (mapOppToUsers.containsKey(groupSec.RelatedId)) {
                    Id val = mapOppToUsers.get(groupSec.RelatedId);
                    if ( !mapSecToUsers.containsKey(groupSec.Id) ) {
                        mapSecToUsers.put( val, groupSec.Id);
                    }
                }
            }

            for ( UserRole userRole : userRoleList1 ) {
                if ( !mapOppToUsers1.containsKey(userRole.Id) ) {
                    mapOppToUsers1.put( userRole.Id, userRole.PortalAccountId  );
                }
            }

            for (Group groupTer : groupList1) {
                if (mapOppToUsers1.containsKey(groupTer.RelatedId)) {
                    Id val = mapOppToUsers1.get(groupTer.RelatedId);
                    if ( !mapTerToUsers.containsKey(groupTer.Id) ) {
                        mapTerToUsers.put( val, groupTer.Id);
                    }
                }
            }

            for (Opportunity oppObj : lstTriggerNew) {
                if (oppObj.PartnerSecondary__c != null && mapSecToUsers.containsKey(oppObj.PartnerSecondary__c)) {
                    groupSecId = mapSecToUsers.get(oppObj.PartnerSecondary__c);
                    oppObj.SecondaryPartnerGroupId__c = groupSecId;
                }
                if (oppObj.PartnerTertiary__c != null && mapTerToUsers.containsKey(oppObj.PartnerTertiary__c)) {
                    groupTerId = mapTerToUsers.get(oppObj.PartnerTertiary__c);
                    oppObj.TertiaryPartnerGroupId__c = groupTerId;
                }
            }
        }
    }
    
    private void sendPendingApprovalProcessQuote( List<Opportunity> lstTriggerNew, Map<Id, Opportunity> oldMap ) {
        Set<Id> oppID = new Set<Id>();
        Set<Id> quoteID = new Set<Id>();
        List<sbqq__quote__c> quoteList = new List<sbqq__quote__c>();
        for(Opportunity opp : (List<Opportunity>)Trigger.new){
            if(opp.isClosed && opp.isClosed != oldMap.get(opp.Id).isClosed){
                oppId.add(opp.Id);
            }
        }
        if(!oppId.isEmpty()){
            for(sbqq__quote__c quote: [Select Id from sbqq__quote__c where  SBQQ__Opportunity2__c in: oppID]){
                quoteID.add(quote.Id);
            }
            if(!quoteID.isEmpty()){
                ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId in : quoteId AND ProcessInstance.Status = 'Pending']; 
                if(piWorkItems.size() > 0){
                    //Create Process Work Item Request
                    Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                    pwiRequest.setAction('Removed');
                    pwiRequest.setWorkItemId(piWorkItems[0].Id);
                    Approval.ProcessResult result = Approval.process(pwiRequest);
                }
            }
        }
    }


    private void updateOppSharingOnPartnerAcc( List<Opportunity> lstTriggerNew, Map<Id, Opportunity> mapTriggerOld ) {

        List<OpportunityShare> lstOppShareToInsert = new List<OpportunityShare>();
        List<OpportunityShare> lstOppShareToDelete = new List<OpportunityShare>();
        Set<Id> AccountIds = new set<Id>();
        List<Opportunity> lstOpportunityToShare = new List<Opportunity>();

        for ( Opportunity objOpp : lstTriggerNew ) {
            if ( mapTriggerOld == null) {
                //System.debug('objOpp.Partner_Secondary__c' + objOpp.PartnerSecondary__c);
                if (objOpp.PartnerSecondary__c != null) {
                    //System.debug('objOpp.SecondaryPartnerGroupId__c' + objOpp.SecondaryPartnerGroupId__c);
                    lstOppShareToInsert.add( new OpportunityShare(OpportunityAccessLevel = 'Read', OpportunityId = objOpp.Id, UserOrGroupId = objOpp.SecondaryPartnerGroupId__c) );
                    //System.debug(lstOppShareToInsert + 'lstOppShareToInsert');
                }
                if (objOpp.PartnerTertiary__c != null) {
                    lstOppShareToInsert.add( new OpportunityShare(OpportunityAccessLevel = 'Read', OpportunityId = objOpp.Id, UserOrGroupId = objOpp.TertiaryPartnerGroupId__c) );
                }
            }

            else {
                Set<Id> UserIds = new Set<Id>();
                if ( objOpp.PartnerSecondary__c != mapTriggerOld.get( objOpp.Id ).PartnerSecondary__c ) {
                    //lstLeadShareToDelete = [Select id,UserOrGroupId from leadshare where leadid= :objLead.Id and UserOrGroupId =: mapTriggerOld.get( objLead.Id ).SecondaryPartnerGroupId__c];

                    lstOppShareToInsert.add( new OpportunityShare(OpportunityAccessLevel = 'Read', OpportunityId = objOpp.Id, UserOrGroupId = objOpp.SecondaryPartnerGroupId__c) );
                    lstOpportunityToShare.add( objOpp );
                    AccountIds.add(mapTriggerOld.get( objOpp.Id ).SecondaryPartnerGroupId__c);
                }
                if ( objOpp.PartnerTertiary__c != mapTriggerOld.get( objOpp.Id ).PartnerTertiary__c ) {
                    //lstLeadShareToDelete = [Select id from leadshare where leadid= :objLead.Id and UserOrGroupId =: mapTriggerOld.get( objLead.Id ).TertiaryPartnerGroupId__c];

                    lstOppShareToInsert.add( new OpportunityShare(OpportunityAccessLevel = 'Read', OpportunityId = objOpp.Id, UserOrGroupId = objOpp.TertiaryPartnerGroupId__c) );
                    lstOpportunityToShare.add( objOpp );
                    AccountIds.add(mapTriggerOld.get( objOpp.Id ).TertiaryPartnerGroupId__c);
                    //System.debug(lstOpportunityToShare);
                    //System.debug(AccountIds);
                }
            }
        }
        Map<Id, Map<Id, Id>> mapOppToUsers = new Map<Id, Map<Id, Id>>();
        if ( !lstOpportunityToShare.isEmpty() ) {
            for ( OpportunityShare objOppShare : [Select id, UserOrGroupId, OpportunityId from OpportunityShare where OpportunityId = :lstOpportunityToShare and UserOrGroupId = :AccountIds and RowCause = 'Manual']) {
                if ( !mapOppToUsers.containsKey(objOppShare.OpportunityId) ) {
                    mapOppToUsers.put( objOppShare.OpportunityId, new Map<Id, Id> { objOppShare.UserOrGroupId => objOppShare.Id } );
                    continue;
                }
                //System.debug(mapOppToUsers);
                mapOppToUsers.get(objOppShare.OpportunityId).put( objOppShare.UserOrGroupId, objOppShare.Id );
            }

            for ( Opportunity objOpp : lstOpportunityToShare ) {
                if ( mapOppToUsers.containsKey( objOpp.Id ) &&
                        mapOppToUsers.get( objOpp.Id ).containsKey(mapTriggerOld.get( objOpp.Id ).SecondaryPartnerGroupId__c )) {
                    //System.debug(mapOppToUsers);
                    lstOppShareToDelete.add( new OpportunityShare( Id = mapOppToUsers.get( objOpp.Id ).get( mapTriggerOld.get(objOpp.Id ).SecondaryPartnerGroupId__c ) ));
                }
                if ( mapOppToUsers.containsKey( objOpp.Id ) &&
                        mapOppToUsers.get( objOpp.Id ).containsKey(mapTriggerOld.get( objOpp.Id ).TertiaryPartnerGroupId__c )) {
                    lstOppShareToDelete.add( new OpportunityShare( Id = mapOppToUsers.get( objOpp.Id ).get( mapTriggerOld.get(objOpp.Id ).TertiaryPartnerGroupId__c ) ));
                }
            }

        }
        
        if ( !lstOppShareToInsert.isEmpty() )
            database.insert( lstOppShareToInsert, false ) ;
        if ( !lstOppShareToDelete.isEmpty() )
            database.delete( lstOppShareToDelete, false );


    }

    private void integrateSCFContracts( Map<Id, Opportunity> mapTriggerNew, Map<Id, Opportunity> mapTriggerOld ) {
        Set<Id> setContractedOpportunity = new Set<Id>();
        for ( Opportunity objOpp : mapTriggerNew.values()) {
            if ( objOpp.SBQQ__Contracted__c && mapTriggerOld.get( objOpp.Id ).SBQQ__Contracted__c != objOpp.SBQQ__Contracted__c ) {
                setContractedOpportunity.add( objOpp.Id );
            }
        }

        if ( !setContractedOpportunity.isEmpty() ) {
            Set<Id> setIntegratedOpps = new Set<Id>();
            //for (Opportunity objOpp : [Select Id From Opportunity Where SBQQ__PrimaryQuote__r.Amendment_Contract_Creation__c = TRUE And Id In:setContractedOpportunity ]) {
            //    setIntegratedOpps.add( objOpp.Id );
            //}
        
            for (Opportunity objOpp : [Select Id From Opportunity Where SBQQ__PrimaryQuote__r.SBQQ__Type__c IN ('Amendment', 'Renewal') And Id In:setContractedOpportunity ]) {
                setIntegratedOpps.add( objOpp.Id );
            }
            if ( !setIntegratedOpps.isEmpty() ) {
                Datetime nowPlusTen = Datetime.now().addMinutes(3);
                String hour = String.valueOf(nowPlusTen.hour());
                String min = String.valueOf(nowPlusTen.minute());
                String ss = String.valueOf(nowPlusTen.second());

                //parse to cron expression
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                List<Id> listOpp = new List<Id>(setIntegratedOpps);
                String q = '%' + listOpp[0];
                if( [SELECT count() FROM CronTrigger Where CronJobDetail.Name Like :q ] <= 0 )
                    System.schedule('Integration Job For SCF Contracts -' + listOpp[0], nextFireTime, new Sch_SCFContractsIntegration(setIntegratedOpps));
            }
        }
    }
    private void InsertPartnerCommission(List<Opportunity> lstTriggerNew){
        for(Opportunity oppObj: lstTriggerNew){
            // Select the Commission Model of the Partner
            if(((oppObj.PrimarySource__c == 'YIC Partner' && oppObj.PartnerPrimary__c == oppObj.AccountId) ||
                    (oppObj.SecondarySource__c == 'YIC Partner' && oppObj.PartnerSecondary__c == oppObj.AccountId) ||
                    (oppObj.TertiarySource__c == 'YIC Partner' && oppObj.PartnerTertiary__c == oppObj.AccountId)) && oppObj.POC__c == 'No' && (oppObj.SBQQ__AmendedContract__c ==  null || oppObj.SBQQ__AmendedContract__r.SBQQ__Opportunity__r.Partner_Commision_Model__c != null)){
                oppObj.Partner_Commision_Model__c = 'TP';
                break;
            } else if(((oppObj.PrimarySource__c == 'YIC Partner' && oppObj.PartnerPrimary__c != oppObj.AccountId) ||
                    (oppObj.SecondarySource__c == 'YIC Partner' && oppObj.PartnerSecondary__c != oppObj.AccountId) ||
                    (oppObj.TertiarySource__c == 'YIC Partner' && oppObj.PartnerTertiary__c != oppObj.AccountId))  && oppObj.POC__c == 'No' && (oppObj.SBQQ__AmendedContract__c ==  null || oppObj.SBQQ__AmendedContract__r.SBQQ__Opportunity__r.Partner_Commision_Model__c != null)){
                oppObj.Partner_Commision_Model__c = 'Model A';
            }else if(((oppObj.PrimarySource__c == 'Distributor Partner-TP' || oppObj.PrimarySource__c == 'Alliance Partner') ||
                    (oppObj.SecondarySource__c == 'Distributor Partner-TP' || oppObj.SecondarySource__c == 'Alliance Partner') ||
                    (oppObj.TertiarySource__c == 'Distributor Partner-TP' || oppObj.TertiarySource__c == 'Alliance Partner')) && oppObj.POC__c == 'No' && oppObj.Partner_Commision_Model__c == null && (oppObj.SBQQ__AmendedContract__c ==  null || oppObj.SBQQ__AmendedContract__r.SBQQ__Opportunity__r.Partner_Commision_Model__c != null)){
                oppObj.Partner_Commision_Model__c = 'TP';
            }else if (((oppObj.PrimarySource__c == 'Reseller Partner' || oppObj.PrimarySource__c == 'Distributor Partner-Commission' || oppObj.PrimarySource__c == 'IPC Partner') ||
                    (oppObj.SecondarySource__c == 'Reseller Partner' || oppObj.SecondarySource__c == 'Distributor Partner-Commission'|| oppObj.SecondarySource__c == 'IPC Partner') ||
                    (oppObj.TertiarySource__c == 'Reseller Partner' || oppObj.TertiarySource__c == 'Distributor Partner-Commission'|| oppObj.TertiarySource__c == 'IPC Partner')) && oppObj.POC__c == 'No' && oppObj.Partner_Commision_Model__c == null && (oppObj.SBQQ__AmendedContract__c ==  null || oppObj.SBQQ__AmendedContract__r.SBQQ__Opportunity__r.Partner_Commision_Model__c != null) ){
                oppObj.Partner_Commision_Model__c = 'Model A';

            }else if (((oppObj.PrimarySource__c == 'Consultant Partner' || oppObj.PrimarySource__c == 'Alliance Partner - Commission') ||
                    (oppObj.SecondarySource__c == 'Consultant Partner' || oppObj.SecondarySource__c == 'Alliance Partner - Commission') ||
                    (oppObj.TertiarySource__c == 'Consultant Partner' || oppObj.TertiarySource__c == 'Alliance Partner - Commission')) && oppObj.POC__c == 'No' && oppObj.Partner_Commision_Model__c == null && (oppObj.SBQQ__AmendedContract__c ==  null || oppObj.SBQQ__AmendedContract__r.SBQQ__Opportunity__r.Partner_Commision_Model__c != null) ){
                oppObj.Partner_Commision_Model__c = 'Model B';
            }
        }
    }

}