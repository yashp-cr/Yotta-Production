/**
 * Created by CloudRoute on 21-01-2022.
 */
({
	onCallApex : function(component, event, helper) {
        //get the method parameters
		var params = event.getParams().arguments;
         var callerComponent = params.component;
                var controllerMethod = params.controllerMethod;
                var actionParameters = params.actionParameters;
                var successCallback = params.successCallback;
                var parentHelper = params.parentHelper;
                helper.callApex(callerComponent, controllerMethod, actionParameters, successCallback,parentHelper);
	}
})