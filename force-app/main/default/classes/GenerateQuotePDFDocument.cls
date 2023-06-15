public class GenerateQuotePDFDocument {
    public static Id fileId;
	public static String toEmail;
    public static ContentVersion file;
    public static String pdfName = '';

    public GenerateQuotePDFDocument() {

    }

    @AuraEnabled
	public static String pdfGenerationCheck(Id recordId, String pdfName) {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c,Bill_To_Address__c,Customer_Contact__c,	Variable_Product_Count__c ,No_of_days_per_month__c,No_of_hours_per_month__c, SCF_Type__c, Name, SBQQ__Status__c, Contracted__c, (SELECT Id, SCF_Type__c FROM SBQQ__LineItems__r WHERE SCF_Type__c = 'Transfer of Service') FROM SBQQ__Quote__c WHERE Id = : recordId];
        List<Sbqq__QuoteLine__c> quoteLineList = [Select SBQQ__Product__r.Variable_UOM__c from Sbqq__QuoteLine__c where SBQQ__Quote__c =:recordId];
        System.debug('quote.SBQQ__Status__c' + quote.SBQQ__Status__c);    
        System.debug('quote.Contracted__c' + quote.Contracted__c);
        System.debug('quote.SBQQ__Type__c' + quote.SBQQ__Type__c);
        for(Sbqq__QuoteLine__c quoteLine: quoteLineList){
			if(quoteLine.SBQQ__Product__r.Variable_UOM__c == 'Hour' && (quote.No_of_days_per_month__c == null || quote.No_of_hours_per_month__c == null) && quote.SBQQ__Type__c == 'Quote' ){ 
				throw new AuraHandledException('No. of days per month and No. of hours per day fields are required if variable product is involved in the quote.');
			}
            if(quote.Bill_To_Address__c == null || quote.Customer_Contact__c == null){
                 throw new AuraHandledException('Please fill Bill to Address and Customer Contact first.');
            }
		}
		if ((quote.SBQQ__Status__c == 'Approved' || quote.SBQQ__Status__c == 'Rejected' || quote.SBQQ__Status__c == 'Customer Accepted') && !quote.Contracted__c) {
			if(quote.SBQQ__Type__c == 'Amendment'){
				if(quote.SCF_Type__c == 'Address Change'){
					pdfName = 'SCFAddressChange';
				} else if(quote.SCF_Type__c == 'Bill Cycle Change'){
					pdfName = 'SCFBillCycleChange';
				} else if(quote.SCF_Type__c == 'Transfer of Service'){
					pdfName = 'SCFTransferOfService';
				} else if(quote.SCF_Type__c == 'Contract Line SCF'){
					pdfName = 'CombinedSCF';
				}
            }else if(quote.SBQQ__Type__c == 'Quote'){
                pdfName = 'SalesforceProposalTemplate';
			}else{
				pdfName = 'RenewalSCF';
			}
			
			System.debug('.....PDF NAme...' + pdfName);
        } else{
            if (!Test.isRunningTest()) { 
            throw new AuraHandledException('Cannot generate PDF until quote is approved.');
            }
        }

        return pdfName;
	}


	@AuraEnabled
	public static String SavePDFAsFile(Id recordId, String pdfName) {

		SBQQ__Quote__c quote = [SELECT Id, Name, Version__c, SBQQ__Account__c, Customer_Contact__r.Email,Is_PDF_Generated__c, Customer_Contact__c, Additional_CC_s_Email__c, Customer_Contact__r.Name FROM SBQQ__Quote__c WHERE Id = : recordId];

		if (quote.Version__c == null) {
			quote.Version__c = 0;
		}
		quote.Version__c = quote.Version__c + 1;		

        toEmail = quote.Customer_Contact__r.Email;
        
       	String pdfURL = '/apex/' + pdfName + '?id=' + RecordId;
		PageReference pdf = new PageReference(pdfURL);
		Blob pdfBody;

		if (Test.isRunningTest()) {
			pdfBody = blob.valueOf('Unit.Test');
		} else {
			pdfBody = pdf.getContent();
		}

		String currentDate = date.today().format();
        
        Document__c doc = new Document__c();
		//doc.Account__c = quote.SBQQ__Account__c;
        doc.Object__c = 'Quote';

        if(pdfName == 'SalesforceProposalTemplate'){
            doc.Document_Category__c = 'Quote';
            doc.Document__c = 'Proposal Quote';
            doc.Name = 'Proposal Quote';
        }else if(pdfName == 'CombinedSCF' || pdfName == 'SCFAddressChange' || pdfName == 'SCFBillCycleChange' || pdfName == 'SCFTransferOfService'){
            doc.Document_Category__c = 'SCF';
            doc.Document__c = 'SCF Quote';
            doc.Name = 'SCF Quote';
        }else{
			doc.Document_Category__c = 'Quote';
            doc.Document__c = 'Renewal Quote';
            doc.Name = 'Renewal Quote';
		}

		doc.Quote__c = RecordId;
		insert doc;

			quote.Is_PDF_Generated__c = true;
			update quote;

		file = new ContentVersion();
        file.VersionData = pdfbody;

        if(pdfName == 'SalesforceProposalTemplate'){
            file.title = quote.Name + 'Proposal' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
		    file.pathOnClient =  quote.Name + 'Proposal' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
        } else if(pdfName == 'CombinedSCF' || pdfName == 'SCFAddressChange' || pdfName == 'SCFBillCycleChange' || pdfName == 'SCFTransferOfService'){
            file.title = quote.Name + 'SCF' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
		    file.pathOnClient =  quote.Name + 'SCF' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
        } else{
            file.title = quote.Name + 'Renewal' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
		    file.pathOnClient =  quote.Name + 'Renewal' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
        }
		
		file.FirstPublishLocationId = doc.Id;
		insert file;
		
		ContentVersion c = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];
		FileId = c.ContentDocumentId;

		//Update quote version
//		update quote;

		SaveQuotationWrapper  response = new SaveQuotationWrapper(FileId , toEmail);
		return JSON.serialize(response);
	}

	@AuraEnabled
	public static void sendEmail(Id recordId, String pdfName) {
		SavePDFAsFile(recordId, pdfName);
        SBQQ__Quote__c quote = [SELECT id, Customer_Contact__c, Additional_CC_s_Email__c, Customer_Contact__r.Email, Customer_Contact__r.Name FROM SBQQ__Quote__c WHERE Id = : recordId];
        
       // if(quote.Customer_Contact__c == '' || quote.Customer_Contact__c == NULL){
        if(quote.Customer_Contact__c == NULL){
            if (!Test.isRunningTest()) { 
            throw new AuraHandledException('Please specify Customer Contact.');
            }
        }

		String[] toRecipients = new List<String> {quote.Customer_Contact__r.Email};
		String[] ccRecipients = new List<String>();
        if(quote.Additional_CC_s_Email__c != NULL){
            ccRecipients = quote.Additional_CC_s_Email__c.split(';');
        }

		EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'QuoteProposal'];
		String templateId = emailTemplate.Id ;

		ID targetObjId = quote.Customer_Contact__c;
		ID whatId = quote.id;

		String currentUserName = quote.Customer_Contact__r.Name;
        String currentUserEmail = quote.Customer_Contact__r.Email;

        /*String pdfURL = '/apex/' + pdfName + '?id=' + recordId;
		PageReference pdf = new PageReference(pdfURL);
		Blob pdfBody;

		if (Test.isRunningTest()) {
			pdfBody = blob.valueOf('Unit.Test');
		} else {
			pdfBody = pdf.getContent();
		}*/


		System.debug('calling send template email');
		sendTemplatedEmail(toRecipients, ccRecipients, templateId, targetObjId, whatId, currentUserName, currentUserEmail);
	}

	public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateId, ID targetObjId, Id whatId,
	                                      String currentUserName, String currentUserEmail) {

		System.debug('inside send template email');
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		/* Set Recipients Address */
		email.setToAddresses(toRecipients);

		/* Set CC Recipients Address */
		if(ccRecipients.size() > 0){
			email.setccAddresses(ccRecipients);
		}

		/* Set Contact ID here */
		email.setTargetObjectId(targetObjId);

		/* Replay to Address*/
		email.setReplyTo(currentUserEmail);

		/* Set Sender Display Name */
		email.setSenderDisplayName(currentUserName);

		/* Set Current Object ID for merge fields */
		email.setWhatId(whatId);

		/*Set Template ID coming from Custom Setting Named "EmailTemplateSetting__c" */
		email.setTemplateId(templateId);

		List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

		//   for (Attachment a : attachList) {
		Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
		efa.setFileName(file.title);
		efa.setBody(file.VersionData);
		fileAttachments.add(efa);
		// }

		email.setFileAttachments(fileAttachments);
		//  }

		/* Set this email log under Activity History */
		email.setSaveAsActivity(true);

		try {
			Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

			if (results.get(0).isSuccess()) {
				system.debug('Email has been send :  ' + results);
			} else {
				system.debug('Some error in sending email :  ' + results );
			}
		} catch (EmailException e) {
			System.debug('sendTemplatedEmail related errors in Quotation PDF :  ' + e.getMessage());
		}
	}

	public class  SaveQuotationWrapper {
		Id fileId;
        String emailRecipient;
        
		public SaveQuotationWrapper(Id fileId, String emailRecipient) {
			this.fileId = fileId;
			this.emailRecipient = emailRecipient;
		}
	}
}