trigger FileTrigger on ContentDocument (before delete) {
    
    //----Restrict Files Deletion, create triggerhandler class and move below code to separate method if more operations are required------
    Id userProfileId = userinfo.getProfileId();
    String userProfileName = [SELECT ID, Name from Profile Where Id = : userProfileId].Name;
    if( userProfileName != 'System Administrator'){
        for(ContentDocument cd : trigger.old){
            if(Trigger.isBefore && Trigger.isDelete)
            	cd.adderror('File Cannot be deleted, please contact administrator.');
        }
    }
    //----End of Restrict Files Deletion------
}