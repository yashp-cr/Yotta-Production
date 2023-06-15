({
    doInit: function (component, event, helper) {
        component.set("v.toggleSpinner", true); 
        console.log('===', component.get('v.pdfName'));
        helper.initiatePDFGeneration(component, event);        
    },
    
    save: function (component, event, helper) {
        component.set("v.toggleSpinner", true);
        component.set("v.functioncalled", "save");
        helper.savePDF(component, event, helper);        
        component.set("v.toggleSpinner", false);
    },    
    
    saveandemail: function (component, event, helper) {
        component.set("v.toggleSpinner", true);
        
        //helper.save1(cmp, event, helper);
        helper.sendemail(component,event,helper);
        //helper.handleEmail(cmp,event,helper);
        component.set("v.toggleSpinner", false);
    },

    cancel: function (component, event, helper){
        helper.cancel(component,event,helper);
    }
})