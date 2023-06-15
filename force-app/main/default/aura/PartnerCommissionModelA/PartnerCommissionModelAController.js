({
    doInit : function(component, event, helper) {  
        console.log('actionnnn');
        var action = component.get("c.profileName");
        console.log('action');
        var recordidquote = component.get("v.recordId");
        
        console.log(recordidquote);
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('Successs');
            console.log('response ::: ' + response.getState());
            if (state === "SUCCESS") {
                component.set("v.userProfile", response.getReturnValue());
                var userProf = component.get("v.userProfile");
                console.log("userProfile",userProf);
                if(userProf == "Yotta Partner Manager Profile" || userProf == "System Administrator" || userProf == 'Yotta Sales Head Profile'){
                        console.log('Get go')
                        helper.getQuoteStatus(component,event,helper);

                }
                
                else{

                 helper.showToast({
                                            "title": "Error!!",
                                            "type": "error",
                                            "message": "Only Yotta Partner Manager can edit the Partner Commission Model."
                                        });
                                        helper.redirectToOptyRecord(component, event);
                }
            }
            else if(state === "ERROR")
            { console.log('some problem'+response.getError());}
            

            
        });
        $A.enqueueAction(action);

        
        
        
    },


    onSave : function (component, event, helper) {        
        var modelDetails = component.get("v.CommissionModelList");
        var count = 0;
        var arrayLength = modelDetails.length;
        for (var i = 0; i < arrayLength; i++) {
            if((modelDetails[i].Partner_Commission__c <0  || modelDetails[i].Sales_Rep_Commission__c<0 )||
               (modelDetails[i].Partner_Commission__c >100 ||modelDetails[i].Sales_Rep_Commission__c> 100)){
                count = count + 1;                          
            }     
        }
        
        if(count > 0){ 
            console.log('greater than 100');
            helper.showToast({
                "title": "Error!!",
                "type": "error",
                "message": "Please enter a positive value less than or equal to 100."
            });
            
        }
        else{
            component.set("v.HideSpinner", true);
            helper.saveModelType(component,event,helper);
            //component.set("v.HideSpinner", false);
            //component.set("v.HideSpinner", true);
            helper.saveDataTable(component, event, helper); 
            //component.set("v.HideSpinner", false);
        }       
    }, 
    
    onSaveModelB : function (component, event, helper) {
        
        var modelDetails = component.get("v.partnerBModelList");
        var count = 0;
        var arrayLength = modelDetails.length;
        for (var i = 0; i < arrayLength; i++) {
            if((modelDetails[i].TCV_Formula_for_Year_1__c<0  || modelDetails[i].TCV_Formula_for_Year_2__c<0 || modelDetails[i].TCV_Formula_for_Year_3__c<0 ||
                modelDetails[i].TCV_Formula_for_Year_4__c<0  || modelDetails[i].TCV_Formula_for_Year_5__c<0 || 
                modelDetails[i].Partner_Commission__c<0  || modelDetails[i].Sales_Rep_Commission__c<0 ) ||
               (modelDetails[i].TCV_Formula_for_Year_1__c >100  || modelDetails[i].TCV_Formula_for_Year_2__c>100  || modelDetails[i].TCV_Formula_for_Year_3__c>100  ||
                modelDetails[i].TCV_Formula_for_Year_4__c>100   || modelDetails[i].TCV_Formula_for_Year_5__c>100   ||
                modelDetails[i].Partner_Commission__c>100  || modelDetails[i].Sales_Rep_Commission__c>100  )){
                count = count + 1;
                
            }      
        }
        
        if(count > 0){  
            console.log('greater than 100');
            helper.showToast({
                "title": "Error!!",
                "type": "error",
                "message": "Please enter a positive value less than or equal to 100."
            });           
        }
        else{
            component.set("v.HideSpinner", true);
            helper.saveModelType(component,event,helper);
            component.set("v.HideSpinner", false);
            console.log('saveDataTableModelB');
            component.set("v.HideSpinner", true);
            helper.saveDataTableModelB(component, event, helper); 
            component.set("v.HideSpinner", false);
        }       
    },  

    onSaveType : function (component, event, helper) {
            var picklist=component.find('InputSelectSingle');
            var picklistvalue= picklist.get('v.value');
            console.log('picklistvalue',picklistvalue);
            component.set("v.HideSpinner", true);

            component.set("v.modelType", picklistvalue);
            helper.getModelType(component, event, helper)
            component.set("v.HideSpinner", false);

        },
    
    onCancel: function(component, event, helper){
        component.set("v.HideSpinner", true);
        helper.cancel(component, event, helper);
        component.set("v.HideSpinner", false);
    },
    
})