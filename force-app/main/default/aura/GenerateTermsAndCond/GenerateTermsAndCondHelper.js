({
	generateTerms : function(component, event) {

        var action = component.get("c.createTermsandCondition");     

        action.setParams({
            quoteId: component.get("v.recordId")            
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                this.showToast(component, event, 'Success', 'T&C have been successfully generated.');
            } else if(response.getState() === 'ERROR'){
                var errorMessage = response.getError()[0].message;
                
                if(errorMessage == undefined){
                    if(response.getError()[0].pageErrors.length != 0){
                        errorMessage = response.getError()[0].pageErrors[0].message;   
                    }else if(response.getError()[0].fieldErrors.length != 0){
                        errorMessage = response.getError()[0].fieldErrors.Account__c[0].message;   
                    }
                }
                
                console.log('.........', errorMessage);
                this.showToast(component, event, 'Error', errorMessage);
            }

            component.set("v.toggleSpinner", false);
        });
        $A.enqueueAction(action);
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
})