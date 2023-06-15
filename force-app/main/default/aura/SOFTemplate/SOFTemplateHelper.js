({    
    getError: function(component, event,helper){
        var action = component.get("c.isValidContract");
        action.setParams({ 
            ConId: component.get("v.recordId") 
        });
       
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isError = response.getReturnValue().isError;
                component.set("v.isError", isError);
                var errorMsg = response.getReturnValue().errorMsg;
          
                if (isError) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": errorMsg,
                        "type": "Error",
                        "mode": "sticky"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
            
        $A.enqueueAction(action);    
    },

    savePDF: function (component, event, helper) {
        var action = component.get("c.SavePDFAsFile");
        
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resp = JSON.parse(response.getReturnValue());
            
            if (state === "SUCCESS") {
                this.showToast(component, event, 'Success', 'PDF has been successfully saved.');
            } else if (state === "ERROR") {
                var errorMessage = response.getError()[0].message;
                this.showToast(component, event, 'Error', errorMessage);
            }            
        });
        $A.enqueueAction(action);        
    },

    sendemail: function (component, event, helper) {
        console.log('inside sendemaiil');
        var action = component.get("c.sendEmail");
       
       action.setParams({
           "recordId" : component.get("v.recordId")
       });
       
       action.setCallback(this, function (response) {
           var state = response.getState();
           
           if (state === "SUCCESS") {
               this.showToast(component, event, 'Success', 'PDF has been successfully saved and emailed.');                
           } else if (state === "ERROR") {
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
});