({
    doInit : function(component, event, helper) {
        component.set("v.toggleSpinner", true); 
        helper.initiateContractCreation(component, event);        
    }
})