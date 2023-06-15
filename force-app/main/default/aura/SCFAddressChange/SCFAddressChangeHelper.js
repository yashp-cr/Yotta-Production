({    
    getError: function(component, event,helper){
         var action = component.get("c.isValidContract");
        console.log('inside do Init 2');
        action.setParams({ 
            ConId: component.get("v.recordId") });
        console.log('inside do Init 3');
        action.setCallback(this, function (response) {
            console.log('inside do Init 4');
            var state = response.getState();
            console.log('state doInit:::::', state);
            if (state === "SUCCESS") {
                console.log("ABCD-->", response);
                console.log("response.getReturnValue() in Lightning Generation-->", JSON.stringify(response.getReturnValue()));
                var isError = response.getReturnValue().isError;
                component.set("v.isError", isError);
                var errorMsg = response.getReturnValue().errorMsg;
               console.log('is Error is', isError);
               console.log('is Error is', errorMsg);
      
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
            else {
                //showPDF != false
            }
        });
        console.log('inside do Init 5');
        $A.enqueueAction(action);
    
    },
        save1: function (component, event,helper) {
        var action = component.get("c.SavePDFAsFile");
        var recordidquote = component.get("v.recordId");
        console.log('Called helper for save',recordidquote);
        action.setParams({
            "RecordId" : recordidquote
        });
        console.log('aa',recordidquote);
        action.setCallback(this, function (response) {
            console.log("Called actionSetCallBack");
            console.log('aa',recordidquote);
            var state = response.getState();
            console.log('State=' +state);
            console.log((response.getReturnValue()));
            var resp = JSON.parse(response.getReturnValue());
            console.log('response=',resp);
            
                
                 if (state === "SUCCESS") {
                helper.showToast(component, event,helper);
                     var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();

            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }

            
        });
        $A.enqueueAction(action);
        
    },
    
   
    showToast : function(component, event,helper){
        console.log('Inside Toast');
        
        var sMsg = component.get("v.ErrorMessage");
        console.log('v.ErrorMessage', sMsg);
        var toastEvent = $A.get("e.force:showToast");
        if(sMsg != ''){
            //displays a toast message "error"
            console.log('Error Message:::'+sMsg);
            toastEvent.setParams({
                mode: 'sticky',
                message: sMsg,
                type : 'error'
                
            });
            toastEvent.fire();
        }
        else{
            //displays a toast message "Success!"
            console.log('Else statement');
            toastEvent.setParams({
                mode: 'dismissible',
                message: 'Success',
                type : 'Success',
                duration: 30
                
            });
            toastEvent.fire();
        }            
    },
       cancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
    },
});