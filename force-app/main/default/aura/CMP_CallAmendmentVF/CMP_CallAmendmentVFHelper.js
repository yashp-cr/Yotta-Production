({
	redirectToAmmendVF : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var vfURL = '/apex/SBQQ__AmendContract?id=' + component.get("v.recordId");
        console.log("VF URL: ",vfURL);
        urlEvent.setParams({
        	"url": vfURL
        });
        urlEvent.fire();
    }
})