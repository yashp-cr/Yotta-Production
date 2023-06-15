({
    
    doInit: function (component, event, helper) {
        var action = component.get("c.getSCFType");
        var recordidquote = component.get("v.recordId");
        
        action.setParams({
            "RecordId" : recordidquote 
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('response ::: ' + response.getState());
            if (state === "SUCCESS") {                    
                component.set('v.SCFType', response.getReturnValue());
                var statusList = component.get("v.SCFType");  
                console.log('SCFType',JSON.stringify(component.get('v.SCFType')));
                var statusList = component.get("v.SCFType");
                if(statusList == null){helper.cancel();}
                //if(statusList == '')
                else{
                    helper.getError(component, event, helper);
                }
            }
        });
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