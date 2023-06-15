/**
 * Created by CloudRoute on 22-03-2022.
 */

public with sharing class RedAlertNotification {

    @InvocableMethod(label = 'Send Red Alert' description = 'Send Red Alert')
    public static void sendNotificationEmail(List<String> params) {

        Map<String, String> inputString = (Map<String, String>)JSON.deserialize(params[0], Map<String, String>.class);
        Id recordId=(Id)inputString.get('recordId');
        String emailBody=(String)inputString.get('emailBody');

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Set<String> SenderAddress = new Set<String>();
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        Opportunity objMsg = [SELECT Id,Name,Account.Name,Owner.Name,StageName,CloseDate,Infrastructure_Details__c,OpportunityId__c,Region__c,Vertical__c,PrimarySource__c,SecondarySource__c,TertiarySource__c,Account.Owner.Email FROM Opportunity Where Id = :recordId];
        System.debug('Opportunity Record '+objMsg);
        List<User> UserDetail = [SELECT Id,Name,Email,UserRole.Name FROM User WHERE UserRole.Name <> null];
        for (User Us: UserDetail){
            if(Us.UserRole.Name.contains('Sales Head')){
                SenderAddress.add(Us.Email);
            }
            if(objMsg.Region__c != null && Us.UserRole.Name.Contains('Regional Head - '+objMsg.Region__c)){
                SenderAddress.add(Us.Email);
            }
            if (objMsg.Vertical__c != null && Us.UserRole.Name.contains('Vertical Head - '+objMsg.Vertical__c)) {
                SenderAddress.add(Us.Email);
            }
            if(((objMsg.SecondarySource__c != null && objMsg.PrimarySource__c.contains('Marketing')) || (objMsg.SecondarySource__c != null && objMsg.SecondarySource__c.contains('Marketing')) || (objMsg.SecondarySource__c != null && objMsg.TertiarySource__c.contains('Marketing'))) && Us.UserRole.Name.contains('IS Head')){
                SenderAddress.add(Us.Email);
            }
            if((objMsg.SecondarySource__c != null && objMsg.PrimarySource__c.contains('Partner')) || (objMsg.SecondarySource__c != null && objMsg.SecondarySource__c.contains('Partner')) || (objMsg.SecondarySource__c != null && objMsg.TertiarySource__c.contains('Partner'))){
                SenderAddress.add(Us.Email);
                if((objMsg.SecondarySource__c != null && objMsg.PrimarySource__c.contains('Distributor')) || (objMsg.SecondarySource__c != null && objMsg.SecondarySource__c.contains('Distributor')) || (objMsg.SecondarySource__c != null && objMsg.TertiarySource__c.contains('Distributor'))){
                    SenderAddress.add('nmasand@yotta.com');
                    SenderAddress.add(objMsg.Account.Owner.Email);
                }
            }
        }
        Set<String> BUHead = new Set<String>{'njadhav@yotta.com','rsheth@yotta.com','speerzade@yotta.com','rgarg@yotta.com','spanda@yotta.com'};
        SenderAddress.addAll(BUHead);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if( org.IsSandbox ) {
            message.setToAddresses( new List<String>{'yash.p@cloudroute.in','yashparsiya098@gmail.com','jahuja@yotta.com','smadav@yotta.com','samhatre@yotta.com'});
        } else {
            message.setToAddresses(new List<String>(SenderAddress));
            //message.setCcAddresses( new List<String>{'automation@yotta.com'});// CC Email Address
        }
        String finalBody = 'Opportunity Id: '+objMsg.OpportunityId__c+',<br/> ' +
                ' Account Name : '+objMsg.Account.Name+
                '<br/> Opportunity Name :'+ objMsg.Name+
                '<br/> Opportunity Owner : '+objMsg.Owner.Name+
                '<br/> Stage : '+objMsg.StageName+
                '<br/> Expected Closure Date : '+objMsg.CloseDate.format()+
                '<br/> Infrastructure Details :  '+objMsg.Infrastructure_Details__c+
                '<br/><br/>     Required Following help : <br/><br>'+emailBody;
        message.setHtmlBody( finalBody );
        message.setSenderDisplayName(objMsg.Owner.Name);
        message.setSubject( 'Red Alert For ' + objMsg.OpportunityId__c );
        messages.add(message);
        System.debug('List SenderEmailAddress:  '+SenderAddress);
        System.debug('Email Body :  '+finalBody);
        if( !messages.isEmpty() ){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            System.debug('Results: '+results);
        }

    }

}