({
	contractHandler : function(component, event, helper) {
		if( component.get('v.contractfields') && !component.get('v.calledHandler') ) {
			var obectPayload = JSON.parse(component.get('v.contractfields.Request_Envelope__c'));
			//component.set('v.beautifiedJSON', JSON.stringify( obectPayload, null, 4));
			console.log('=====>>>>', helper.syntaxHighlight(obectPayload) )
			component.set('v.beautifiedJSON', helper.syntaxHighlight(obectPayload));
			component.set('v.calledHandler', true); 
        }
	},
	doInit: function(component, event, helper) {
		var action = component.get('c.getIntegrationMessageJSON');
		action.setParams({
			recordId: component.get('v.recordId')
		});
		action.setCallback(this, function(response){
			console.log('===>>>> ', response.getReturnValue());
			component.set('v.beautifiedJSON', response.getReturnValue());
		});
		$A.enqueueAction(action);
	},
	copyHardcoreText : function(component, event, helper) {
        // get HTML hardcore value using aura:id
        var textForCopy = component.find('jsonBracket').getElement().innerHTML;
        // calling common helper class to copy selected text value
        helper.copyTextHelper(component,event,textForCopy);
    }
})