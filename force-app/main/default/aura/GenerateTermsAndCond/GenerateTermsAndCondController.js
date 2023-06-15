({
    doInit : function(component, event, helper) {
        component.set("v.toggleSpinner", true); 
        helper.generateTerms(component, event);
    }    
})