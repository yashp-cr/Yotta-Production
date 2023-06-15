({
    initiateContractCreation : function(component, event) {
        var action = component.get("c.createContract");
        
        action.setParams({
            "quoteId" : component.get("v.recordId"),
        });

        action.setCallback(this,function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {                    
                this.showToast(component, event, 'Success', 'Contract Generation process has been initiated. Please refresh the screen in 2-3 minutes.');
            } else if(response.getState() === 'ERROR'){
                var errorMessage = response.getError()[0].message;
				this.showToast(component, event, 'Error', errorMessage);
            }
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