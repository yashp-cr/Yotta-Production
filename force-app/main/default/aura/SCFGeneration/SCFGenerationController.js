({

    doInit: function (component, event, helper) {
      var action = component.get("c.isValidAccount");
        console.log('inside do Init 2');
        action.setParams({ 
            AccId: component.get("v.recordId") });
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
               
          
 

    save: function (component, event, helper) {
        // Get the list of uploaded files
        //var uploadedFiles = event.getParam("files");
        //set action to call updatePicturePath method from Server-side controller
        //helper.save1(cmp, event,helper);
        console.log('before spinner');
        component.set("v.spinner", true);
        console.log('spinner is true');
        var spinnerval = component.get("v.spinner");
        console.log("spinnerval", spinnerval);
        component.set("v.functioncalled", "save");
        console.log("functioncalled is save");
        var label = component.get("v.functioncalled");
        console.log("label:::", label);
        console.log("after label is set");
        helper.save1(component, event, helper);
        console.log('After Save Only');
        component.set("v.spinner", false);
    },


    cancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },


    saveandemail: function (cmp, event, helper) {
        cmp.set("v.spinner", true);
        var spinnerval = cmp.get("v.spinner");
        console.log("spinnerval", spinnerval);
        console.log("A333");
        cmp.set("v.OnlineAcceptance", true);
        var OnlineAcceptanceval = cmp.get("v.OnlineAcceptance");
        console.log("OnlineAcceptanceval", OnlineAcceptanceval);
        cmp.set("v.functioncalled", "saveandemail");
        console.log("abcdabcd");
        /*component.get("v.functioncalled");
         console.log('functioncalled',functioncalled);*/
        var label = cmp.get("v.functioncalled");
        console.log("label:::", label);
        console.log("abcd1abcd1");
        helper.save1(cmp, event, helper);
        console.log("After Save!!!");
        cmp.set("v.spinner", false);
    }
}
)