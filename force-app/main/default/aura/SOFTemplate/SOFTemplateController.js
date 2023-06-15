({
    doInit: function (component, event, helper) {
        console.log('......');
        var action = component.get("c.pdfGenerationCheck");
        
        action.setParams({
            "recordId" : component.get("v.recordId")
        });

        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === 'ERROR'){
                var errorMessage = response.getError()[0].message;
                helper.showToast(component, event, 'Error', errorMessage);
            }
        });
        
        $A.enqueueAction(action);                
    },

    save: function (component, event, helper) {        
        component.set("v.spinner", true);
        helper.savePDF(component, event, helper);
        component.set("v.spinner", false);
    },

    saveandemail: function (component, event, helper) {
        component.set("v.spinner", true);
        helper.sendemail(component, event, helper);
        component.set("v.spinner", false);
    },

    cancel: function (component, event, helper) {
        helper.cancel(component, event, helper);
    }
})