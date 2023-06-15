({    
    initiatePDFGeneration : function(component, event) {
        var action = component.get("c.pdfGenerationCheck");
        
        action.setParams({
            "recordId" : component.get("v.recordId")
        });

        action.setCallback(this,function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set('v.Status', true);
                component.set('v.pdfName', response.getReturnValue());
            } else if(response.getState() === 'ERROR'){
                var errorMessage = response.getError()[0].message;
                this.showToast(component, event, 'Error', errorMessage);
            }
        });
        component.set("v.toggleSpinner", false); 
        $A.enqueueAction(action);
    },
    
    savePDF: function (component, event,helper) {
        var action = component.get("c.SavePDFAsFile");
       
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "pdfName" : component.get("v.pdfName")
        });
       
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resp = JSON.parse(response.getReturnValue());
            console.log('........reposnse.....', response);
            if (state === "SUCCESS") {
                //helper.showToast(component, event,helper);
                component.set("v.FileId",resp.fileId);
                component.set("v.toEmail",resp.emailRecipient);
                this.showToast(component, event, 'Success', 'PDF has been successfully saved.');
                //helper.handleEmail(component, event ,helper);
            } else if (state === "ERROR") {
                var errorMessage = response.getError()[0].message;
                this.showToast(component, event, 'Error', errorMessage);
            }
            
            
        });
        $A.enqueueAction(action);
        
    },
    
    sendemail: function (component, event,helper) {
         console.log('inside sendemaiil');
        var action = component.get("c.sendEmail");
        
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "pdfName" : component.get("v.pdfName")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resp = JSON.parse(response.getReturnValue());
            
            if (state === "SUCCESS") {
                this.showToast(component, event, 'Success', 'PDF has been successfully saved and emailed.');
            } else if (state === "ERROR") {
                var errorMessage = response.getError()[0].message;
                this.showToast(component, event, 'Error', errorMessage);
            }            
        });
        $A.enqueueAction(action);
        
    },
    
    handleEmail: function(component, event, helper){
        console.log("called handleEmail"  );
        var args = {actionName :"SendEmail"};
        console.log('after send email');
        
        $A.get("e.force:closeQuickAction").fire();
        var actionAPI = component.find("quickActionAPI");
                
        actionAPI.getAvailableActionFields(args).then(function(result){
           // console.log('result is :', result);
            helper.SetEmailActionFeilds(component, event, helper);
            //All available action fields shown for Log a Call
        }).catch(function(e){
            if(e.errors){
                console.log("error ::: "+JSON.stringify(e));
                //If the specified action isn't found on the page, show an error message in the my component 
            } 
        }); 
    },
    
    SetEmailActionFeilds : function( cmp, event, helper ) {

        var actionAPI = cmp.find("quickActionAPI");
        var args = {actionName :"SendEmail", entityName:"SBQQ__Quote__c" };
        actionAPI.getAvailableActionFields(args).then(function(result){
            console.log('......&&&&.EMAIL.....', JSON.stringify(result));
        }).catch(function(e){
            if(e.errors){
                //If the specified action isn't found on the page, show an error message in the my component 
            }
        });

        console.log("Called udpate email!!");
        var actionAPI = cmp.find("quickActionAPI");
        var FileId = cmp.get("v.FileId");
        
        var fields = {ToAddress: {value: cmp.get("v.toEmail")}, EmailTemplateId:{value:"00X1m000000Pjj9EAC"}};
        
        var args = {actionName: "SendEmail", targetFields: fields}; 
        console.log('......^^^...****..', fields);
        actionAPI.setActionFieldValues(args).then(function(){
            //actionAPI.invokeAction(args); 
        }).catch(function(e){
            console.error('Isnide Catch');
            console.error('Errors',e);
            console.error('Errors 2',e);
        });
        
        console.log("Called Cancel");
        //$A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire();
    }, 

    showToast: function(component, event, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({ "title": title, "type": title, "message": message });
        toastEvent.fire();

        this.cancel(component, event, helper);
    },

    toggleSpinner: function(component, event){
        var trgSpinner = component.find("spinner");
        $A.util.toggleClass(trgSpinner, "slds-hide");
    },

    cancel: function (component, event, helper) {
		$A.get('e.force:refreshView').fire();
		$A.get("e.force:closeQuickAction").fire();
	}
});