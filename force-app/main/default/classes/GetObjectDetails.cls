public with sharing class GetObjectDetails {
    //Get all sObject Fields
    public static String getObjectFieldDetails(String objName){
        String query = '';
        Map<String,String> mapOfRefFields = new Map<String,String>();
        
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            //system.debug(dfield.getname() + ' -- '+ dfield.getType()+ ' -- '+ dfield.isCalculated() + ' -- ' + dfield.isAutoNumber() + ' -- ' +dfield.isUpdateable() + '--' + dfield.getRelationshipOrder());
            
            if(dfield.isUpdateable() || (dfield.getRelationshipOrder() == 0)){
                query = (query <> '' ? query +', '+ dfield.getname() : dfield.getname());
            }
        }
        
        System.debug('Fields.........'+ query);
        return query;
    }
}