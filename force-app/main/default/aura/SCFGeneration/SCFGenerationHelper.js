({    
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
});