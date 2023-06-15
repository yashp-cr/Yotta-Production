({  
    getQuoteStatus : function(component,event,helper){

         component.find("service").callApex(component,helper,
                                    "c.contractApprovedfun",
                                    {
                                        'recordId': component.get("v.recordId")
                                    },this.contractApprovedfunSuccess);
        var modelType = component.get("v.opportunity.Partner_Commision_Model__c");
        var action = component.get("c.getQuoteStatus");
        var recordidquote = component.get("v.recordId");
        action.setParams({
            "recordId" : recordidquote
        });
        console.log(recordidquote);
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('response ::: ' + response.getState());
            if (state === "SUCCESS") {         
                component.set('v.quoteStatusList', response.getReturnValue());
                var statusList = component.get("v.quoteStatusList");
                var arrayLength = statusList.length;
                console.log('arrayLength' ,arrayLength);
                var sList = JSON.stringify(statusList);
                console.log('partnerLineStatusList',JSON.stringify(component.get('v.partnerLineStatusList')));
                for (var i = 0; i < arrayLength; i++) {
                    console.log('outside if 1' , sList);
                    console.log('partner Commission');
                    console.log('Quote ',statusList[i].SBQQ__PrimaryQuote__c);
                  if(statusList[i].SBQQ__PrimaryQuote__c == null){
                      console.log('Quote not Created');
                      helper.showToast({
                                                  "title": "Error!!",
                                                  "type": "error",
                                                  "message": "Quote is not generated"
                                              });
                                              helper.redirectToOptyRecord(component, event);
                  }else if((statusList[i].SBQQ__PrimaryQuote__r.SBQQ__Status__c != "Approved" &&
                        statusList[i].SBQQ__PrimaryQuote__r.SBQQ__Status__c != "Presented" &&
                        statusList[i].SBQQ__PrimaryQuote__r.SBQQ__Status__c != "Customer Accepted") ){
                        console.log((statusList[i].SBQQ__PrimaryQuote__r.SBQQ__Status__c));
                        console.log(statusList[i].SBQQ__PrimaryQuote__r.SBQQ__Status__c);
                        console.log(statusList[i].SBQQ__PrimaryQuote__r.Contracted__c == false);
                        helper.showToast({
                            "title": "Error!!",
                            "type": "error",
                            "message": "Partner Commission can only be updated after quote is approved."
                        }); 
                        helper.redirectToOptyRecord(component, event);
                        

                    } else if(statusList[i].Partner_Commision_Model__c == "TP"){
                        helper.showToast({
                                                    "title": "Error!!",
                                                    "type": "error",
                                                    "message": "Commission model cannot be changed to Transfer price model, please close cancel this opportunity and create new one for the same"
                                                });
                                                helper.redirectToOptyRecord(component, event);
                    }

                   /* else if(statusList[i].SBQQ__PrimaryQuote__r.Contracted__c == true){
                        console.log('Hiii');
                        component.set('v.quoteStatus','Contracted');
                        helper.showToast({
                            "title": "Error!!",
                            "type": "error",
                            "message": "Contract is already generated, Partner model cannot be modified."
                        });
                        helper.redirectToOptyRecord(component, event);
                    }*/

                        else if((!statusList[i].PrimarySource__c.includes('Partner') &&
                                !statusList[i].SecondarySource__c.includes('Partner') &&
                                !statusList[i].TertiarySource__c.includes('Partner')) || statusList[i].Partner_Commision_Model__c == null
                               ) 
                                {
                            console.log('Hiii');
                            component.set('v.quoteStatus','NoPartner');
                            helper.showToast({
                                "title": "Error!!",
                                "type": "error",
                                "message": "This feature is not available as this is not partner opportunity."
                            });
                            helper.redirectToOptyRecord(component, event);  
                        }
                         
                    
                            else {
                                console.log('else');
                                console.log('ModelType',statusList[i].Partner_Commision_Model__c);

                                if(!statusList[i].Partner_Commision_Model__c ){
                                        component.set('v.quoteStatus', 'False');
                                        component.find("InputSelectSingle").set("v.value","None");
                                }else{
                                       component.set('v.quoteStatus', 'False');
                                        component.set('v.partnerModelType',statusList[i].Partner_Commision_Model__c);
                                        component.find("InputSelectSingle").set("v.value",statusList[i].Partner_Commision_Model__c);
                                        component.set('v.modelType',statusList[i].Partner_Commision_Model__c);
                                }

                                helper.getModelType(component, event,helper);
                            }
                    
                }
            }
            
            
            else if(state === "ERROR")
            { console.log('some problem'+response.getError());}
        });
        
        $A.enqueueAction(action);

        
    },

    contractApprovedfunSuccess : function(component, returnValue, helper){
        console.log('ReturnValue for Approved',returnValue);
                if(returnValue == true){
                    component.set("v.Contracted",returnValue);
                    console.log('Contracted',component.get("v.Contracted"));
                   /* helper.showToast({
                                                    "title": "Error!!",
                                                    "type": "error",
                                                    "message": "Cannot Update Commission Model because Contract are Approved"
                                                });
                                                 helper.redirectToOptyRecord(component, event);*/

                }

        },

    
    getModelType : function(component,event,helper){
        var modelType= component.get('v.modelType');
        console.log('modelType',modelType);
        var modelAction = component.get("c.getModelType");
        var modelBAction = component.get("c.updatePartnerB");
        
        var action = component.get("c.getPartnerLineList");
        var recordidquote = component.get("v.recordId");
        component.get('v.quoteStatus');
        console.log('quoteStatus',JSON.stringify(component.get('v.quoteStatus')));
        
        
        if (modelType == "Model A"){
            
            //helper.cancel(component, event, helper);
            component.set('v.partnerModelType', 'Model A');
            console.log('modelType',JSON.stringify(component.get('v.modelType')));
            console.log('cancellll');
            
            this.getCommissionModel(component, recordidquote, action);                         
        }
        if(modelType == "Model B"){
            
            // helper.cancel(component, event, helper); 
            component.set('v.partnerModelType', 'Model B');
            //this.CheckSalesRep(component,event,helper);
            this.getModelB(component,recordidquote, modelBAction);                        
        }
        



    },

    CheckSalesRep : function(component, event, helper){
        var modelAction = component.get("c.checkSalesRepModelB");
         var recordidvalue = component.get("v.recordId");
        modelAction.setParams({
             "recordId": component.get("v.recordId")
        });

        modelAction.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var responseValue = response.getReturnValue();

                /*if(responseValue === true){
                    helper.redirectToOptyRecord(component, event);
                    this.showToast({
                                     "title": "Error!!",
                                     "type": "error",
                                     "message": "Please Add Partner Sales Rep on Opportunity for the given Opportunity"
                                        });
                }*/
            }
        });
                $A.enqueueAction(modelAction);
    },





    getModelB : function(component, recordidquote, modelBAction){
        var modelBAction = component.get("c.updatePartnerB");
        var recordid = component.get("v.recordId");
        console.log("updatePartnerB");
        console.log(recordidquote);
        modelBAction.setParams({
            "recordId" : recordidquote
        });
        console.log(recordidquote);
        modelBAction.setCallback(this,function(response) {
            var state = response.getState();
            console.log('response ::: ' + response.getState());
            if (state === "SUCCESS") {                    
                component.set('v.partnerLineStatusList', response.getReturnValue());
                console.log('Response Value', response.getReturnValue());

                var statusList = component.get("v.partnerLineStatusList");
                var arrayLength = statusList.length;
                var count;
                console.log('arrayLength' ,arrayLength);
                var sList = JSON.stringify(statusList);
                console.log('partnerLineStatusList',JSON.stringify(component.get('v.partnerLineStatusList')));
                for (var i = 0; i < arrayLength; i++) {
                    console.log('outside if 1' , sList);
                    console.log('Contracted', statusList[i].Contracted__c);
                    console.log('outside if 1' , sList.includes("Partner_Commission__r"));
                    //console.log('statusList',statusList[i].Partner_Commission__r.Approval_Status__c);
                    if(sList.includes("Partner_Commission__r")){
                        console.log('inside if 1');
                        if((statusList[i].Partner_Commission__r.Approval_Status__c == 'Approved' )||
                           (statusList[i].Partner_Commission__r.Approval_Status__c == 'Submitted for Approval' )){            
                            count = 1;
                            console.log("count");
                        }
                        else {
                            console.log("partnerBModelList");
                            component.set('v.partnerBModelList', response.getReturnValue());
                        }}
                    
                    else {
                        console.log("partnerBModelList");
                        component.set('v.partnerBModelList', response.getReturnValue());
                    }
                }
                if(count > 0){
                    helper.cancel();
                    helper.showToast({
                        "title": "Error!!",
                        "type": "error",
                        "message": "The process has already been sent for approval."
                    });
                }
                
                console.log( response.getReturnValue());             
            }
            else if(state === "ERROR")
            { console.log('some problem'+response.getError());}
        });
        
        $A.enqueueAction(modelBAction);
        
        
    },
    
    getCommissionModel : function(component, recordidquote, action) {
        
        var recordid = component.get("v.recordId"); 
        var action = component.get("c.getPartnerLineList");
        
        action.setParams({
            "recordId" : recordidquote
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('response ::: ' + response.getState());
            if (state === "SUCCESS") {                    
                component.set('v.partnerLineStatusList', response.getReturnValue());
                var statusList = component.get("v.partnerLineStatusList");
                
                var arrayLength = statusList.length;
                var count;
                console.log('arrayLength' ,arrayLength);
                console.log(arrayLength === 0);
                var sList = JSON.stringify(statusList);
                console.log('hey');
                
                if (arrayLength === 0){
                    console.log('hiixxxxi');
                    this.cancel(component);
                    this.showToast({
                        "title": "Error!!",
                        "type": "error",
                        "message": "The products are not added on the quote."
                    });
                }
                else{
                    for (var i = 0; i < arrayLength; i++) {
                        console.log('outside if 1' , sList);
                        console.log('outside if 1' , sList.includes("Partner_Commission__r"));
                        if(statusList[i].Sales_Rep_Commission__c != null){
                            if(statusList[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.Partner_Sales_Rep__c == null){
                                this.showToast({
                                                        "title": "Error!!",
                                                        "type": "error",
                                                        "message": "Kindly Add Partner Sales Rep on Opportunity."
                                                    });
                    this.cancel(component);
                            }
                        }
                        //console.log('statusList',statusList[i].Partner_Commission__r.Approval_Status__c);
                        if(sList.includes("Partner_Commission__r")){
                            console.log('inside if 1');
                            if((statusList[i].Partner_Commission__r.Approval_Status__c == 'Approved' )||
                               (statusList[i].Partner_Commission__r.Approval_Status__c == 'Submitted for Approval' )){            
                                count = 1;
                                console.log("count");
                            }
                            else {
                                console.log("CommissionModelList");
                                component.set('v.CommissionModelList', response.getReturnValue());
                            }}
                        
                        else {
                            console.log("CommissionModelList");
                            component.set('v.CommissionModelList', response.getReturnValue());
                        }
                        if(statusList[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.PrimarySource__c.includes('Distributor') ||
                        (statusList[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.SecondarySource__c != null && statusList[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.SecondarySource__c.includes('Distributor')) ||
                        (statusList[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.TertiarySource__c != null && statusList[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.TertiarySource__c.includes('Distributor'))){
                            component.set("v.partnerType", true);
                            console.log('PartnerType',component.get("v.partnerType"));
                        }

                    }
                    if(count > 0){
                        helper.cancel();
                        helper.showToast({
                            "title": "Error!!",
                            "type": "error",
                            "message": "The process has already been sent for approval."
                        });
                    }
                    
                    console.log( response.getReturnValue());             
                }
            }
            else if(state === "ERROR")
            {
            var errors = response.getError();
            console.log('some problem'+errors[0].message);
            this.showToast({
                                        "title": "Error!!",
                                        "type": "error",
                                        "message": "Error : "+errors[0].message
                                    });
                                                    this.cancel(component);
}
        });

        $A.enqueueAction(action);
    },
    
    saveDataTable : function(component, event, helper) {
        console.log('CommissionModelList1234566',JSON.stringify(component.get('v.CommissionModelList')));
        var recordidquote = component.get("v.recordId");
        var editedRecords = component.get('v.CommissionModelList');
        var action = component.get("c.updatePartnerCommission");
        console.log('saving model A');
        action.setParams({
            "editedList" : editedRecords,
            "recordId" : recordidquote 
        });
        //console.log('setCallback');
        action.setCallback(this,function(response) {
            console.log('stateeeee');
            var state = response.getState();
            console.log('state',state);
            if (state !== 'SUCCESS') {
                //if update got failed
                component.set("v.HideSpinner", false);
                helper.showToast({
                    "title": "Error!!",
                    "type": "error",
                    "message": "Error in update"
                });
            } else {                  
                $A.get('e.force:refreshView').fire();
                helper.showToast({
                    "title": "Record Update",
                    "type": "success",
                    "message": "Records Updated"
                });
                component.set("v.HideSpinner", false);
                helper.redirectToOptyRecord(component, event);
            }
            
        });
        console.log('enqueue action');
        $A.enqueueAction(action);
        // helper.redirectToOptyRecord(component, event);
        //helper.cancel();
    },
    saveModelType : function(component, event, helper) {
        var recordidquote = component.get("v.recordId");
        var picklist=component.find('InputSelectSingle');
        var modelType= picklist.get('v.value');
        var action = component.get("c.getModelType");
        action.setParams({
            "recordId" : recordidquote,
            "modelType" : modelType 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {                  
                $A.get('e.force:refreshView').fire();
                helper.showToast({
                    "title": "Record Update",
                    "type": "success",
                    "message": "Records Updated"
                });
                
            } else{ //if update got failed
                helper.showToast({
                    "title": "Error!!",
                    "type": "error",
                    "message": "Error in update"
                });
            }
            
        });
        
        $A.enqueueAction(action);
        helper.redirectToOptyRecord(component, event);
        //helper.cancel();
    },
    
    saveDataTableModelB : function(component, event, helper) {
        console.log('partnerBModelList',JSON.stringify(component.get('v.partnerBModelList')));
        var recordidquote = component.get("v.recordId");
        var editedRecords = component.get('v.partnerBModelList');
        var action = component.get("c.updatePartnerCommissionModelB");
        var action = component.get("c.updatePartnerCommissionModelB");
        action.setParams({
            "editedList" : editedRecords,
            "recordId" : recordidquote 
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('state',state)
            if (state === "SUCCESS") {                  
                $A.get('e.force:refreshView').fire();
                
                helper.showToast({
                    "title": "Record Update",
                    "type": "success",
                    "message": "Records Updated"
                });   
                component.set("v.HideSpinner", false);
            } else{ //if update got failed
                helper.showToast({
                    "title": "Error!!",
                    "type": "error",
                    "message": response.getError()[0].message
                });
                component.set("v.HideSpinner", false);
            }
            
        });
        $A.enqueueAction(action);
        helper.redirectToOptyRecord(component, event);
        helper.cancel();
    },
    
    showToast : function(params){
        console.log('showToast');
        console.log('inside showToast');
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams(params);
            toastEvent.fire();
        } else{
            alert(params.message);
        }
    },
    
    
    
    redirectToOptyRecord : function(component, event) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId") ,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    
    cancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    change: function(component, event, helper) {
        console.log(component.get('v.CommissionModelList'));  
    }
})