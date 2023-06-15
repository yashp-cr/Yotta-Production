/*
*   Name        : IntegrationBase
*   Description : Class to create JSON requests and initiate the external integration requests.
*   Author      : Nandish Shenoy
*   Create On   : 10 May 2020
*   |-------------------------------------------------------------------------|
*   | Version | Modified By      | Date       | Comment                       |
*   |-------------------------------------------------------------------------|
*   | 0.1     | Nandish          | 10/05/2020 | Initial Version of Class      |
*   |-------------------------------------------------------------------------|
*/
public class IntegrationBase {
    
    private Map<string, Integration_Request_Template__mdt> developerNameMetadataMapping = new Map<string, Integration_Request_Template__mdt>();
    //parameters for each child template present under a parent template to be used in bulk in conditions
    private Map<string,Map<string, List<string>>> parentTemplateParameterMapping = new Map<string,Map<string, List<string>>>();
    //eg : Map<'Deployment_POS_Details', Map<'Deployment_VAS_Details', List<allparentPOSIds>>>
    //data for each child template fetched in a single query and store as a mapping parent template and child tempate data
    //eg : Map<'Deployment_POS_Details', Map<'Deployment_VAS_Details', Map<'ParentPOSID', List<AllVASAssets>>>>
    private Map<string, Map<string,Map<string,List<sObject>>>> parentTemplateDataMap = new Map<string, Map<string,Map<string,List<sObject>>>>();
    
    public static Set<Integer> errorCodeSet = new Set<Integer>();
    static{
        for (Retrial_error_code__mdt errMdt : [SELECT Error_Code__c, Error_Description__c from Retrial_error_code__mdt]) {
                errorCodeSet.add(Integer.valueOf(errMdt.Error_Code__c));
        }
    }
    
    public string CreateIntegrationRequestEnvelope(string parentTemplateName, string ID)
    {
        Integration_Request_Template__mdt integrationRequest = [SELECT Object_Type__c, SOQL_Query__c, All_Fields__c,Query_Field__c, 
                                                                Fields_to_Trigger_Integration__c,Json_Field_Names__c,Static_JSON_Data__c,
                                                               (SELECT Instance_Type__c, Instance_Name__c
                                                                ,Child_Query_Field__c, Self_Template_Name__c , Static_Condition__c,Parent_Field__c, 
                                                                Format_Parameters__c, GroupBy_Clause__c, ParentGroupField__c, DeveloperName, Classname__c,
                                                                Parameter_Value__c, Parameter_key__c
                                                                FROM Integration_Request_Child__r) FROM Integration_Request_Template__mdt
                                                                WHERE DeveloperName = :parentTemplateName];
        
        List<string> templateNames = new List<string>();
        for(Integration_Request_Child__mdt childMetadata : integrationRequest.Integration_Request_Child__r){
            if(!templateNames.contains(childMetadata.Self_Template_Name__c))
                templateNames.add(childMetadata.Self_Template_Name__c);
        }
        
        List<Integration_Request_Template__mdt> integrationRequestTemplates = [SELECT Object_Type__c, SOQL_Query__c, All_Fields__c,
                                                                Fields_to_Trigger_Integration__c,Json_Field_Names__c,Static_JSON_Data__c,DeveloperName,
                                                                (SELECT Instance_Type__c, Instance_Name__c
                                                                ,Child_Query_Field__c, Self_Template_Name__c , Static_Condition__c, Parent_Field__c,
                                                                 Format_Parameters__c, GroupBy_Clause__c, ParentGroupField__c, DeveloperName, Classname__c,
                                                                 Parameter_Value__c, Parameter_key__c
                                                                FROM Integration_Request_Child__r)
                                                               FROM Integration_Request_Template__mdt
                                                               WHERE DeveloperName in :templateNames];
        
        for(Integration_Request_Template__mdt template:  integrationRequestTemplates){
            if(developerNameMetadataMapping.get(template.DeveloperName) == null){
                developerNameMetadataMapping.put(template.DeveloperName, template);
            }
        }
        Map<string, object> jsonObject = new Map<string,object>();
        string query = integrationRequest.SOQL_Query__c + ' where ' + integrationRequest.Query_Field__c + ' = ' + '\'' + ID + '\'';
        system.debug('object query ' + query);
        sObject parentObject = Database.query(query);
        
        //get children objects(list and object)
        //populate the Request object and then serialize the object to generate JSON.
        //call the API with the JSON
        if(parentObject != null)
        {
            string[] fields = integrationRequest.All_Fields__c.split(',');
            string[] jsonKeys = integrationRequest.Json_Field_Names__c.split(',');
            createJSONObject(parentObject, fields, jsonKeys, jsonObject,integrationRequest.Static_JSON_Data__c, integrationRequest, ID);
            
        }
        
        string request = JSON.serialize(jsonObject);
        system.debug('JSON Request ' + request);
        return request;
    }

    private void createJSONObject(sObject parentObject, string[] fields, string[] jsonKeys, Map<string, object> jsonObject,
                                  string staticJsonText, Integration_Request_Template__mdt integrationRequest, string ID)
    {
        //system.debug('jsonKeys ' +jsonKeys);
        integer i=0;
        //system.debug('fields count ' + fields.size());
        for(string field : fields)
        {
            string[] fieldsRelated = field.split('\\.');
            //system.debug('fields ' + fieldsRelated);
            //system.debug('fields size' + fieldsRelated.size());
            object value;
            if(fieldsRelated.size() == 3)
            {
                //system.debug('fields Related ' + fieldsRelated);
                SObject childSObject = parentObject.getSObject(fieldsRelated[0].trim());
                if(childSObject != null)
                {
                    SObject grandChildSObject = childSObject.getSObject(fieldsRelated[1].trim());
                    
                    if(grandChildSObject != null)
                        value = parentObject.getSObject(fieldsRelated[0].trim()).getSObject(fieldsRelated[1].trim()).get(fieldsRelated[2].trim());
                }
            }
            else if(fieldsRelated.size() == 2)
            {
                SObject childSObject = parentObject.getSObject(fieldsRelated[0].trim()); if(childSObject != null) value = parentObject.getSObject(fieldsRelated[0].trim()).get(fieldsRelated[1].trim());
            }
            else if(fieldsRelated.size() == 4)
            {
                //system.debug('fields Related ' + fieldsRelated);
                SObject childSObject = parentObject.getSObject(fieldsRelated[0].trim()); SObject grandChildObject = null; SObject greatGrandChildObject = null;
                if(childSObject != null) grandChildObject = childSObject.getSObject(fieldsRelated[1].trim());
                if(grandChildObject != null) greatGrandChildObject = grandChildObject.getSObject(fieldsRelated[2].trim());
                if(greatGrandChildObject != null) value = greatGrandChildObject.get(fieldsRelated[3].trim());
                //system.debug(value);
            }
            else
                value = parentObject.get(field.trim());
            
            if(jsonKeys != null && jsonKeys.size() > 0)
            {
                string key = jsonKeys[i];
                jsonObject.put(key.trim(), value);
                i++;
            }
            else{
                jsonObject.put('', value); //blank array
            }
        }
        
        //system.debug('json data ' + jsonObject);
        
        if(String.isNotBlank(staticJsonText))
        {
            string[] staticJsonNode = staticJsonText.split('\\,');
            for(string jsonStructure : staticJsonNode)
            {
                string[] keyValue = jsonStructure.split('\\:');
                jsonObject.put(keyValue[0].trim(), keyValue[1].trim());
            }
        }
       
        checkChildMetadata(integrationRequest, ID, jsonObject,parentObject, '');
        
    }
    
    private void createJSONObjectBulk(sObject parentObject, string[] fields, string[] jsonKeys, Map<string, object> jsonObject,
                                  string staticJsonText, Integration_Request_Template__mdt integrationRequest, string ID, Map<string,Map<string,List<sObject>>> dataMap)
    {
        //system.debug('jsonKeys ' +jsonKeys);
        integer i=0;
        //system.debug('fields count ' + fields.size());
        for(string field : fields)
        {
            string[] fieldsRelated = field.split('\\.');
            //system.debug('fields ' + fieldsRelated);
            //system.debug('fields size' + fieldsRelated.size());
            object value;
            if(fieldsRelated.size() == 3)
            {
                //system.debug('fields Related ' + fieldsRelated);
                SObject childSObject = parentObject.getSObject(fieldsRelated[0].trim());
                if(childSObject != null) {
                    SObject grandChildSObject = childSObject.getSObject(fieldsRelated[1].trim());
                    if(grandChildSObject != null) value = parentObject.getSObject(fieldsRelated[0].trim()).getSObject(fieldsRelated[1].trim()).get(fieldsRelated[2].trim());
                }
            }
            else if(fieldsRelated.size() == 2)
            {
                SObject childSObject = parentObject.getSObject(fieldsRelated[0].trim());
                if(childSObject != null) value = parentObject.getSObject(fieldsRelated[0].trim()).get(fieldsRelated[1].trim());
            }
            else if(fieldsRelated.size() == 4)
            {
                //system.debug('fields Related ' + fieldsRelated);
                SObject childSObject = parentObject.getSObject(fieldsRelated[0].trim());
                SObject grandChildObject = null;
                SObject greatGrandChildObject = null;
                if(childSObject != null) grandChildObject = childSObject.getSObject(fieldsRelated[1].trim());
                if(grandChildObject != null) greatGrandChildObject = grandChildObject.getSObject(fieldsRelated[2].trim());
                if(greatGrandChildObject != null) value = greatGrandChildObject.get(fieldsRelated[3].trim());
                system.debug(value);
            }
            else
                value = parentObject.get(field.trim());
            
            if(jsonKeys != null && jsonKeys.size() > 0)
            {
                string key = jsonKeys[i];
                jsonObject.put(key.trim(), value);
                i++;
            }
            else{
                jsonObject.put('', value); //blank array
            }
        }
        
        //system.debug('json data ' + jsonObject);
        
        if(String.isNotBlank(staticJsonText))
        {
            string[] staticJsonNode = staticJsonText.split('\\,');
            for(string jsonStructure : staticJsonNode)
            {
                string[] keyValue = jsonStructure.split('\\:');
                jsonObject.put(keyValue[0].trim(), keyValue[1].trim());
            }
        }
       
        checkChildMetadataBulk(integrationRequest, ID, jsonObject,parentObject, '', dataMap);
        
    }
    
    private void checkChildMetadata(Integration_Request_Template__mdt integrationRequest, string ID, Map<string, object> jsonObject,sObject parentObject, string key)
    {
        system.debug('in check metadata data ' + integrationRequest.Integration_Request_Child__r);
        for(Integration_Request_Child__mdt childMetadata : integrationRequest.Integration_Request_Child__r)
        {
            /* New Type added by Nandish */
            if( childMetadata.Instance_Type__c == 'Custom Method') {
                /*Type t = Type.forName(childMetadata.Classname__c);
                IntegrationExtension extension = (IntegrationExtension)t.newInstance();
                String params = '';
                Map<String, Object> mapkeyToValue = new Map<String, Object>();
                List<String> lstValue = childMetadata.Parameter_Value__c.split(',');
                Integer index = 0;
                mapkeyToValue.put('templatename', childMetadata.Self_Template_Name__c );
                for( String strKey : childMetadata.Parameter_key__c.split(',')) {
                    mapkeyToValue.put( strKey, parentObject.get( lstValue[index] ) );
                    index++; 
                }
                jsonObject.put( childMetadata.Instance_Name__c, (Object)extension.runExtension(JSON.serialize(mapkeyToValue)) );*/
                jsonObject.put( childMetadata.Instance_Name__c, callCustomMethodMetaData(childMetadata, parentObject) );
                continue;
            }
            system.debug('childMetadata '+ childMetadata);
            //system.debug('in check metadata data loop' + integrationRequest.Integration_Request_Child__r);
            string[] fieldsRelated = childMetadata.Parent_Field__c.split('\\.');
            string value = '';
            //string[] fieldsRelated;
            if(fieldsRelated != null && fieldsRelated.size() == 2)
            {
                //system.debug('fields ' + fieldsRelated);
                object objValue = parentObject.getSObject(fieldsRelated[0].trim()).get(fieldsRelated[1].trim());
                if(objValue != null)
                    value = objValue.tostring();
            }
            else
            {
                Object objValue = parentObject.get(childMetadata.Parent_Field__c.trim());
                if( objValue != null )
                    value = objValue.tostring();
            }
            
            string referenceID = childMetadata.Parent_Field__c != null ? value : ID;
            //system.debug('value ' + value);
            //system.debug('reference ' + referenceID);
            if(childMetadata.Instance_Type__c == 'Single')
            {
                system.debug('child object ' + childMetadata);
                addChildObject(childMetadata,jsonObject,referenceID, null, null);
            }
            if(childMetadata.Instance_Type__c == 'List')
            {
                system.debug('child list ' + childMetadata);
                addChildList(childMetadata,jsonObject,referenceID, null, null);
            }
            if(childMetadata.Instance_Type__c == 'ListWrapper')
            {
                system.debug('child list wrapper ' + childMetadata);
                //addChildListWrapper(childMetadata,jsonObject,referenceID, null, null);
            }
            if(childMetadata.Instance_Type__c == 'ListItem')
            {
                system.debug('child list item ' + childMetadata);
                //addChildListItem(childMetadata,jsonObject.get(key),referenceID, null, null);
            }
        }
    }
    
    
    private Object callCustomMethodMetaData( Integration_Request_Child__mdt childMetadata, sObject parentObject ) {
        Type t = Type.forName(childMetadata.Classname__c);
        IntegrationExtension extension = (IntegrationExtension)t.newInstance();
        String params = '';
        Map<String, Object> mapkeyToValue = new Map<String, Object>();
        List<String> lstValue = childMetadata.Parameter_Value__c.split(',');
        Integer index = 0;
        mapkeyToValue.put('templatename', childMetadata.Self_Template_Name__c );
        for( String strKey : childMetadata.Parameter_key__c.split(',')) {
            mapkeyToValue.put( strKey, parentObject.get( lstValue[index] ) );
            index++; 
        }
    	return (Object)extension.runExtension(JSON.serialize(mapkeyToValue));
    }
    
    //valid code. Do not remove! Commented by Nandish
    private void checkChildMetadataBulk(Integration_Request_Template__mdt integrationRequest, string ID, Map<string, object> jsonObject,sObject parentObject, string key, Map<string,Map<string,List<sObject>>> dataMap)
    {
        system.debug('in check metadata data bulk' + integrationRequest.Integration_Request_Child__r);
        for(Integration_Request_Child__mdt childMetadata : integrationRequest.Integration_Request_Child__r)
        {
            //system.debug('in check metadata data loop' + integrationRequest.Integration_Request_Child__r);
            if( childMetadata.Instance_Type__c == 'Custom Method') {
                /*Type t = Type.forName(childMetadata.Classname__c);
                IntegrationExtension extension = (IntegrationExtension)t.newInstance();
                String params = '';
                Map<String, Object> mapkeyToValue = new Map<String, Object>();
                List<String> lstValue = childMetadata.Parameter_Value__c.split(',');
                Integer index = 0;
                mapkeyToValue.put('templatename', childMetadata.Self_Template_Name__c );
                for( String strKey : childMetadata.Parameter_key__c.split(',')) {
                    mapkeyToValue.put( strKey, parentObject.get( lstValue[index] ) );
                    index++; 
                }
                jsonObject.put( childMetadata.Instance_Name__c, (Object)extension.runExtension(JSON.serialize(mapkeyToValue)) );*/
                jsonObject.put( childMetadata.Instance_Name__c, callCustomMethodMetaData(childMetadata, parentObject) );
                continue;
            }
            string[] fieldsRelated = childMetadata.Parent_Field__c.split('\\.');
            string value = '';
            //string[] fieldsRelated;
            if(fieldsRelated != null && fieldsRelated.size() == 2)
            {
                //system.debug('fields ' + fieldsRelated);
                object objValue = parentObject.getSObject(fieldsRelated[0].trim()).get(fieldsRelated[1].trim());
                if(objValue != null)
                    value = objValue.tostring();
            }
            else
            {
                value = parentObject.get(childMetadata.Parent_Field__c.trim()).tostring();
            }
            
            string referenceID = childMetadata.Parent_Field__c != null ? value : ID;
            //system.debug('value ' + value);
            //system.debug('reference ' + referenceID);
            if(childMetadata.Instance_Type__c == 'Single')
            {
                //system.debug('child object ' + childMetadata);
                sObject data = null;
                List<sObject> dataList = null;
                List<sObject> allDataList = new List<sobject>();
                if(dataMap.get(childMetadata.Self_Template_Name__c) != null){
                    dataList = dataMap.get(childMetadata.Self_Template_Name__c).get(referenceID);
                    for(List<sobject> allObjects: dataMap.get(childMetadata.Self_Template_Name__c).values()){
                        allDataList.addAll(allObjects);
                    }
                }
                
                
                if(dataList != null){
                    data = dataList[0];
                }
                addChildObject(childMetadata,jsonObject,referenceID, data, allDataList);
            }
            if(childMetadata.Instance_Type__c == 'List')
            {
                system.debug('child list ' + childMetadata);
                system.debug('child list map' + dataMap);
                List<sObject> dataList = null;
                List<sObject> allDataList = new List<sobject>();
                //system.debug('child metadata' + childMetadata.Self_Template_Name__c);
                //system.debug('child metadata ref' + referenceID);
                system.debug('=====dataMap Temp-01' + dataMap.get(childMetadata.Self_Template_Name__c) );
                if(dataMap.get(childMetadata.Self_Template_Name__c) != null){
                    dataList = dataMap.get(childMetadata.Self_Template_Name__c).get(referenceID);
                    system.debug('=====dataList' + dataList );
                    system.debug('===referenceID' + referenceID);
                    for(List<sobject> allObjects: dataMap.get(childMetadata.Self_Template_Name__c).values()){
                        allDataList.addAll(allObjects);
                    }
                }
                
                //system.debug('data list' + dataList);
                //system.debug('all data ' + allDataList);
                addChildList(childMetadata,jsonObject,referenceID, dataList, allDataList);
            }
            /*if(childMetadata.Instance_Type__c == 'ListWrapper')
            {
                system.debug('child list wrapper ' + childMetadata);
                List<sObject> dataList = null;
                List<sObject> allDataList = new List<sobject>();
                if(dataMap.get(childMetadata.Self_Template_Name__c) != null){
                    dataList = dataMap.get(childMetadata.Self_Template_Name__c).get(referenceID);
                    for(List<sobject> allObjects: dataMap.get(childMetadata.Self_Template_Name__c).values()){
                        allDataList.addAll(allObjects);
                    }
                }
                
                addChildListWrapper(childMetadata,jsonObject,referenceID, dataList, allDataList);
            }
            if(childMetadata.Instance_Type__c == 'ListItem')
            {
                system.debug('child object ' + childMetadata);
                sObject data = null;
                List<sObject> dataList = null;
                List<sObject> allDataList = new List<sobject>();
                if(dataMap.get(childMetadata.Self_Template_Name__c) != null){
                    dataList = dataMap.get(childMetadata.Self_Template_Name__c).get(referenceID);
                    for(List<sobject> allObjects: dataMap.get(childMetadata.Self_Template_Name__c).values()){
                        allDataList.addAll(allObjects);
                    }
                }
                
                
                if(dataList != null){
                    data = dataList[0];
                }
                system.debug('child list item ' + childMetadata);
                
                addChildListItem(childMetadata,jsonObject.get(key),referenceID, data, allDataList);
            }*/
         }
    }
    
    //valid code. Do not remove! Commented by Nandish
    private Map<string, List<string>> getParametersBulk(Integration_Request_Template__mdt integrationRequest, string ID, Map<string, object> jsonObject,sObject parentObject, string key, Map<string, List<string>> parametersMap)
    {
        system.debug('in get Parameters Bulk ' + integrationRequest.Integration_Request_Child__r);
        for(Integration_Request_Child__mdt childMetadata : integrationRequest.Integration_Request_Child__r)
        {
            //system.debug('in check metadata data loop' + integrationRequest.Integration_Request_Child__r);
            /*if( childMetadata.Instance_Type__c == 'Custom Method' ) {
                continue;
            }*/
            if( childMetadata.Instance_Type__c == 'Custom Method') {
                continue;
            }
            string[] fieldsRelated = childMetadata.Instance_Type__c != 'Custom Method' ? childMetadata.Parent_Field__c.split('\\.') : childMetadata.Parameter_Value__c.split('\\.');
            String ogFeilds = childMetadata.Instance_Type__c != 'Custom Method' ? childMetadata.Parent_Field__c : childMetadata.Parameter_Value__c;
            //system.debug('parentField ' + fieldsRelated);
            string value = '';
            //string[] fieldsRelated;
            if(fieldsRelated != null && fieldsRelated.size() == 2)
            {
                //system.debug('fields ' + fieldsRelated);
                object objValue = parentObject.getSObject(fieldsRelated[0].trim()).get(fieldsRelated[1].trim());
                if(objValue != null)
                    value = objValue.tostring();
            }
            else
            {
                value = parentObject.get(ogFeilds).tostring();
            }
            
            string referenceID = ogFeilds != null ? value : ID;
            
            //system.debug('loop parameters ' + referenceID);
            //system.debug('loop parameters ' + parametersMap);
            
            if(parametersMap.get(ogFeilds) != null){
                //system.debug('in paramet');
                if(!parametersMap.get(ogFeilds).contains(referenceID))
                    parametersMap.get(ogFeilds).add(referenceID);
            }
            else{
                //system.debug('out paramet');
                List<string> parameterValues = new List<string>();
                parameterValues.add(referenceID);
                parametersMap.put(ogFeilds, parameterValues);
                //system.debug(parametersMap);
            }
        }
        return parametersMap;
    }
    
    //valid code. Do not remove! Commented by Nandish
    private Map<string,Map<string,List<sObject>>> getDataBulk(Integration_Request_Template__mdt integrationRequest, Map<string, List<string>> parametersMap, Map<string,object> jsonRequest)
    {
        Map<string,Map<string,List<sObject>>> data = new Map<string,Map<string,List<sObject>>>();
        for(Integration_Request_Child__mdt childMetadata : integrationRequest.Integration_Request_Child__r)
        {
            string query = '';
            
            system.debug('json request ' + jsonRequest);
            system.debug('child Metadata request ' + childMetadata);
            
            if( childMetadata.Instance_Type__c == 'Custom Method' ) {
                continue;
            }

            string staticCondition = childMetadata.Static_Condition__c;
            if(!string.isBlank(childMetadata.Format_Parameters__c) && !string.isBlank(childMetadata.Static_Condition__c)){
                string[] parameterNames = childMetadata.Format_Parameters__c.split(',');
                //system.debug('parameterNAmes ' + parameterNames);
                List<string> parameters = new List<string>();
                for(string parameter : parameterNames){
                    parameters.add(string.valueOf(jsonRequest.get(parameter)));
                }
                //system.debug('parameterNAmes ' + parameters);
                staticCondition = string.format(childMetadata.Static_Condition__c, parameters);
            }
            
            Integration_Request_Template__mdt childRequest = getIntegrationMetadata(childMetadata.Self_Template_Name__c);
            List<string> parameterValues = parametersMap.get(childMetadata.Parent_Field__c);
            //system.debug(parameterValues);
            query = childRequest.SOQL_Query__c + ' where ' + childMetadata.Child_Query_Field__c + ' in :parameterValues' + (staticCondition != null ?' and ' + staticCondition : '');
        
            
            if(!string.IsBlank(childMetadata.GroupBy_Clause__c)){
                query = query + ' ' + childMetadata.GroupBy_Clause__c;
            }
            
                system.debug(query);
            
                //string parentValue = childObj.get(childMetadata.Parent_Field__c);
                string[] fieldsRelated = null;
                if(childMetadata.ParentGroupField__c != null)
                    fieldsRelated = childMetadata.ParentGroupField__c.split('\\.');
                string value = '';
                //string[] fieldsRelated;
                
            
            List<sObject> childObjectList = Database.query(query);
            system.debug('child object list ' + childObjectList);
            for(sObject childObj : childObjectList){
                if(fieldsRelated != null && fieldsRelated.size() == 2)
                {
                    //system.debug('fields ' + fieldsRelated);
                    object objValue = childObj.getSObject(fieldsRelated[0].trim()).get(fieldsRelated[1].trim());
                    if(objValue != null)
                        value = objValue.tostring();
                }
                else
                {
                    value = childObj.get(childMetadata.ParentGroupField__c.trim()).tostring();
                }
                
                //system.debug('value' + value);
                if(data.get(childMetadata.Self_Template_Name__c) != null){
                    //system.debug('in values');
                    if(data.get(childMetadata.Self_Template_Name__c).get(value) != null){
                        data.get(childMetadata.Self_Template_Name__c).get(value).add(childObj);
                    }
                    else{
                        //system.debug('out values');
                        Map<string,List<sObject>> dataMap = data.get(childMetadata.Self_Template_Name__c);
                        List<sObject> dataList=new List<sObject>();
                        dataList.add(childObj);
                        dataMap.put(value, dataList);
                        data.put(childMetadata.Self_Template_Name__c, dataMap);
                    }
                }
                else{
                    //system.debug('last values');
                    Map<string,List<sObject>> dataMap = new Map<string,List<sObject>>();
                    List<sObject> dataList=new List<sObject>();
                    dataList.add(childObj);
                    dataMap.put(value, dataList);
                    data.put(childMetadata.Self_Template_Name__c, dataMap);
                }
                
                system.debug('data' + data);
            }
        }
        
        
        return data;
    }


    /*
        Integration_Request_Template__mdt integrationRequest = [Select Object_Type__c, SOQL_Query__c, All_Fields__c,
                                                                Fields_to_Trigger_Integration__c,Json_Field_Names__c,Static_JSON_Data__c,
                                                                (Select Instance_Type__c, Instance_Name__c
                                                                ,Child_Query_Field__c, Self_Template_Name__c , Static_Condition__c, Parent_Field__c,
                                                                 Format_Parameters__c, GroupBy_Clause__c
                                                                from Integration_Request_Child__r)
                                                               from Integration_Request_Template__mdt
                                                               where DeveloperName = :metadataObject.Self_Template_Name__c];*/
    /*                                                           
    private void addChildObject(Integration_Request_Child__mdt metadataObject, Map<string,object> jsonRequest,string ID, SObject passedChildObject, List<sObject> allDataList)
    {
        
        Integration_Request_Template__mdt integrationRequest = getIntegrationMetadata(metadataObject.Self_Template_Name__c);
        List<sObject> childObject = null;
        if(passedChildObject == null){
            string query = integrationRequest.SOQL_Query__c + ' where ' + metadataObject.Child_Query_Field__c + ' = ' + '\'' + ID + '\'' + (metadataObject.Static_Condition__c != null ?' and ' + metadataObject.Static_Condition__c : '');
            system.debug('query ' + query);
            childObject = Database.query(query);
        } else {
            childObject = new List<sObject>();
            childObject.add(passedChildObject);
        }     
        Map<string, object> fieldsMap = new Map<string,object>();
        
        SObject relevantObject;
        if(passedChildObject != null){
            relevantObject = passedChildObject;
        }
        if(childObject != null && childObject.size() > 0)
        {
            string[] fields = integrationRequest.All_Fields__c.split(',');
            string[] jsonKeys = integrationRequest.Json_Field_Names__c.split(',');
            relevantObject = childObject[0];
            createJSONObject(relevantObject, fields, jsonKeys, fieldsMap,integrationRequest.Static_JSON_Data__c, integrationRequest,relevantObject.ID);
        }
        
        jsonRequest.put(metadataObject.Instance_Name__c,fieldsMap);
    }*/

    private void addChildObject(Integration_Request_Child__mdt metadataObject, Map<string,object> jsonRequest,string ID, SObject passedChildObject, List<sObject> allDataList)
    {
        Integration_Request_Template__mdt integrationRequest = getIntegrationMetadata(metadataObject.Self_Template_Name__c);
        List<sObject> childObject = null;
        if(passedChildObject == null){
            string query = integrationRequest.SOQL_Query__c + ' where ' + metadataObject.Child_Query_Field__c + ' = ' + '\'' + ID + '\'' + (metadataObject.Static_Condition__c != null ?' and ' + metadataObject.Static_Condition__c : '');
            system.debug('query ' + query);
            childObject = Database.query(query);
        }       
        Map<string, object> fieldsMap = new Map<string,object>();
        
        SObject relevantObject;
        if(passedChildObject != null){
            relevantObject = passedChildObject;
        }
        
        system.debug('metadata ' + metadataObject.Self_Template_Name__c);
        system.debug('relevant data ' + relevantObject);
        
        if(childObject != null && childObject.size() > 0)
        {
            relevantObject = childObject[0];
        }
        
        if(relevantObject != null){
            string[] fields = integrationRequest.All_Fields__c.split(',');
            string[] jsonKeys = integrationRequest.Json_Field_Names__c.split(',');
            createJSONObject(relevantObject, fields, jsonKeys, fieldsMap,integrationRequest.Static_JSON_Data__c, integrationRequest,relevantObject.ID);
        }
        else{
            fieldsMap = null;
        }
        
        jsonRequest.put(metadataObject.Instance_Name__c,fieldsMap);
    }
    
    private void addChildList(Integration_Request_Child__mdt metadataObject, Map<string,object> jsonRequest,string ID, List<SObject> childObjects, List<sObject> allDataList)
    {
        /*Integration_Request_Template__mdt integrationRequest = [Select Object_Type__c, SOQL_Query__c, All_Fields__c, 
                                                                Fields_to_Trigger_Integration__c, Json_Field_Names__c,Static_JSON_Data__c,
                                                                (Select Instance_Type__c, Instance_Name__c
                                                                 ,Child_Query_Field__c, Self_Template_Name__c , Static_Condition__c, Parent_Field__c, 
                                                                 Format_Parameters__c, GroupBy_Clause__c
                                                                from Integration_Request_Child__r)
                                                               from Integration_Request_Template__mdt
                                                               where DeveloperName = :metadataObject.Self_Template_Name__c];*/
        Integration_Request_Template__mdt integrationRequest = getIntegrationMetadata(metadataObject.Self_Template_Name__c);
        
        system.debug('json request ' + jsonRequest);
        
        string query = '';
        
        string staticCondition = metadataObject.Static_Condition__c;
        if(!string.isBlank(metadataObject.Format_Parameters__c) && !string.isBlank(metadataObject.Static_Condition__c)){
            string[] parameterNames = metadataObject.Format_Parameters__c.split(',');
            List<string> parameters = new List<string>();
            for(string parameter : parameterNames){
                parameters.add(string.valueOf(jsonRequest.get(parameter)));
            }
            system.debug('parameterName request ' + parameterNames);
            staticCondition = string.format(metadataObject.Static_Condition__c, parameters);
        }
        
        List<sObject> childObjectList = null;
        if(childObjects == null){
            query = integrationRequest.SOQL_Query__c + ' where ' + metadataObject.Child_Query_Field__c + ' = ' + '\'' + ID + '\'' + (staticCondition != null ?' and ' + staticCondition : '');
        
            if(!string.IsBlank(metadataObject.GroupBy_Clause__c)){
                query = query + ' ' + metadataObject.GroupBy_Clause__c;
            }
            system.debug('query ' + query);
            childObjectList = Database.query(query);
        }
        else{
            childObjectList = childObjects;
        }
        system.debug('results ' + childObjectList);
        //system.debug('child list' + childObjectList);
        string[] fields = integrationRequest.All_Fields__c.split(',');
        List<Map<string,object>> fieldsMapList = new List<Map<string,object>>();
        List<Object> fieldsMapValues = new List<Object>();
        Map<string, List<string>> parametersMap = new Map<string, List<string>>();
        Map<string,Map<string,sObject>> parentMetadataDataMapping = null;
                
        if(childObjectList != null && childObjectList.size() > 0)
        {
            if(true || (childObjects != null && childObjects.size() > 0) || (allDataList != null && allDataList.size() > 20) || childObjectList.size() > 20){
                //valid code. Do not remove! Commented by Nandish
                if(parentTemplateParameterMapping.get(metadataObject.Self_Template_Name__c) == null){
                    if(allDataList != null && allDataList.size() > 0){
                        for(sObject obj: allDataList){
                            getParametersBulk(integrationRequest, ID, jsonRequest, obj, metadataObject.Instance_Name__c, parametersMap);
                        }    
                    }
                    else{
                        for(sObject obj: childObjectList){
                            getParametersBulk(integrationRequest, ID, jsonRequest, obj, metadataObject.Instance_Name__c, parametersMap);
                        }   
                    }
                
                    parentTemplateParameterMapping.put(metadataObject.Self_Template_Name__c, parametersMap);    
                    system.debug('parametersMap' + parametersMap);
                }
                else{
                    parametersMap = parentTemplateParameterMapping.get(metadataObject.Self_Template_Name__c);
                }
                
                Map<string,Map<string,List<sObject>>> dataMap = new Map<string,Map<string,List<sObject>>>();
                if(parentTemplateDataMap.get(metadataObject.Self_Template_Name__c) == null){
                    dataMap = getDataBulk(integrationRequest, parametersMap, jsonRequest);
                    system.debug('data Map ' + JSON.serialize(dataMap));    
                    parentTemplateDataMap.put(metadataObject.Self_Template_Name__c, dataMap);
                }
                else{
                    dataMap = parentTemplateDataMap.get(metadataObject.Self_Template_Name__c);
                }
                
                
                
                for(sObject obj : childObjectList)
                {
                    Map<string, object> fieldsMap = new Map<string,object>();
                    string[] jsonKeys;
                    if(integrationRequest.Json_Field_Names__c != null)
                        jsonKeys = integrationRequest.Json_Field_Names__c.split(',');
                    //system.debug('json keys ' + jsonKeys);
                    
                    //integer i=0;
                    createJSONObjectBulk(obj, fields, jsonKeys, fieldsMap, integrationRequest.Static_JSON_Data__c, integrationRequest, obj.Id,dataMap);
                    if(jsonKeys == null || jsonKeys.size() == 0)
                    {
                        fieldsMapValues.add(fieldsMap.get(''));
                    }
                    
                    fieldsMapList.add(fieldsMap);
                }
            }
            else{
                for(sObject obj : childObjectList)
                {
                    Map<string, object> fieldsMap = new Map<string,object>();
                    string[] jsonKeys;
                    if(integrationRequest.Json_Field_Names__c != null)
                        jsonKeys = integrationRequest.Json_Field_Names__c.split(',');
                    //system.debug('json keys ' + jsonKeys);
                    
                    //integer i=0;
                    createJSONObject(obj, fields, jsonKeys, fieldsMap, integrationRequest.Static_JSON_Data__c, integrationRequest, obj.Id);
                    if(jsonKeys == null || jsonKeys.size() == 0)
                    {
                        fieldsMapValues.add(fieldsMap.get(''));
                    }
                    
                    fieldsMapList.add(fieldsMap);
                }
            }
        }
        
        if(fieldsMapValues.size() >= 1)
            jsonRequest.put(metadataObject.Instance_Name__c,fieldsMapValues);
        else
            jsonRequest.put(metadataObject.Instance_Name__c,fieldsMapList);
    }
    
    /* //valid code. Do not remove! Commented by Nandish
    private void addChildListWrapper(Integration_Request_Child__mdt metadataObject, Map<string,object> jsonRequest,string ID, List<sObject> dataList, List<sObject> allDataList)
    {
        Integration_Request_Template__mdt integrationRequest = getIntegrationMetadata(metadataObject.Self_Template_Name__c);
        
        //system.debug('integration request ' + integrationRequest);
        
        string query = integrationRequest.SOQL_Query__c + ' where ' + metadataObject.Child_Query_Field__c + ' = ' + '\'' + ID + '\'' + (metadataObject.Static_Condition__c != null ?' and ' + metadataObject.Static_Condition__c : '');
        //system.debug('query ' + query);
        List<sObject> childObjectList = Database.query(query);
        List<Map<string,object>> fieldsMapList = new List<Map<string,object>>();
        if(childObjectList != null && childObjectList.size() > 0)
        {
            for(sObject obj : childObjectList)
            {
                Map<string, object> fieldsMap = new Map<string,object>();
                //string[] jsonKeys = integrationRequest.Json_Field_Names__c.split(',');
                //integer i=0;
                List<string> blankArray = new List<string>();
                jsonRequest.put(metadataObject.Instance_Name__c, new List<Object>());
                //createJSONObject(obj, blankArray, blankArray, fieldsMap, integrationRequest.Static_JSON_Data__c, integrationRequest, obj.Id);
                checkChildMetadata(integrationRequest, ID, jsonRequest, obj, metadataObject.Instance_Name__c);
                //fieldsMapList.add(fieldsMap);
                //system.debug('wrapper ' + jsonRequest);
            }
        }
    }*/
    
     //valid code. Do not remove! Commented by Nandish
    /*private void addChildListItem(Integration_Request_Child__mdt metadataObject, Object listRequest,string ID, sObject passedChildObject, List<sObject> allDataList)
    {
        Integration_Request_Template__mdt integrationRequest = getIntegrationMetadata(metadataObject.Self_Template_Name__c);
        
        sObject relevantObject = null;
        if(passedChildObject == null){
            string query = integrationRequest.SOQL_Query__c + ' where ' + metadataObject.Child_Query_Field__c + ' = ' + '\'' + ID + '\'' + (metadataObject.Static_Condition__c != null ?' and ' + metadataObject.Static_Condition__c : '');
            //system.debug('query ' + query);
            List<sObject> childObject = Database.query(query);
            if(childObject != null && childObject.size() > 0)
            {
                relevantObject = childObject[0];
            }
        }
        else{
            relevantObject = passedChildObject;
        }
        
            Map<string, object> fieldsMap = new Map<string,object>();
        
            if(relevantObject != null)
            {
                string[] fields = integrationRequest.All_Fields__c.split(',');
                string[] jsonKeys = integrationRequest.Json_Field_Names__c.split(',');
                createJSONObject(relevantObject, fields, jsonKeys, fieldsMap,integrationRequest.Static_JSON_Data__c, integrationRequest,relevantObject.ID);
            }
        
        ((List<Object>)listRequest).add(fieldsMap);
    }*/
    
    private Integration_Request_Template__mdt getIntegrationMetadata(string templateName){
        
        if(developerNameMetadataMapping.get(templateName) != null){
            return developerNameMetadataMapping.get(templateName);
        }
        else{
            Integration_Request_Template__mdt integrationRequest = [Select Object_Type__c, SOQL_Query__c, All_Fields__c,
                                                                Fields_to_Trigger_Integration__c,Json_Field_Names__c,Static_JSON_Data__c,DeveloperName,
                                                                (Select Instance_Type__c, Instance_Name__c
                                                                ,Child_Query_Field__c, Self_Template_Name__c , Static_Condition__c, Parent_Field__c, 
                                                                 Format_Parameters__c, GroupBy_Clause__c, ParentGroupField__c, DeveloperName, Classname__c,
                                                                 Parameter_Value__c, Parameter_key__c
                                                                from Integration_Request_Child__r)
                                                               from Integration_Request_Template__mdt
                                                               where DeveloperName = :templateName];
            
            developerNameMetadataMapping.put(templateName, integrationRequest);
            return developerNameMetadataMapping.get(templateName);
        }
        
    }
    
    //CALLOUT
    //Make a callout to external system and return HTTP Response
    public HttpResponse makeCallout(String requestEnvelope, String method, String endpoint) {
        //System.debug(LoggingLevel.INFO, 'request envelope in makeCallout is :' + requestEnvelope);
        HttpRequest req = new HttpRequest();
        Http mHttp = new Http();
        if (requestEnvelope != null || String.isNotBlank(requestEnvelope)) {
            req.setBody(requestEnvelope);
        }
        req.setMethod(method); //method ='GET' / 'POST'
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //req.setHeader('Authorization', 'bearer ' + accessToken);
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        HttpResponse res = null;
        if(System.Test.isRunningTest()){
            res = new HttpResponse();
            res.setStatusCode(200);
        }
        else{
            res = mHttp.send(req);    
        }
        
        //System.debug('responseEnvelope in makeCallout is' + res);
        //System.debug('responseEnvelope in makeCallout is' + res.getBody());
        return res;
    }
    
    public HttpResponse makeCalloutWithHeader(String requestEnvelope, String method, String endpoint, Map<String, Object> header) {
        //System.debug(LoggingLevel.INFO, 'request envelope in makeCallout is :' + requestEnvelope);
        HttpRequest req = new HttpRequest();
        Http mHttp = new Http();
        if (requestEnvelope != null) {
            req.setBody(requestEnvelope);
        }
        req.setMethod(method); //method ='GET' / 'POST'
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //req.setHeader('Authorization', authorization); //to be passed as part of header
        for(string key : header.keySet()){
            req.setHeader(key, (String)header.get(key));
        }
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        HttpResponse res = null;
        if(System.Test.isRunningTest()){
            res = new HttpResponse();
            res.setStatusCode(200);
        }
        else{
            res = mHttp.send(req);    
        }
        System.debug('responseEnvelope in makeCallout is' + res);
        System.debug('responseEnvelope in makeCallout is' + res.getBody());
        return res;
    }
  
    //IM CREATION
    public Integration_Message__c createIMRecord(ID imID, ID sObjectId, String operation, String integrationType, 
                                                 String loginRequest, string loginResponse, String requestEnvelope, String responseEnvelope,
                                                 boolean validForRetrial, String parentTemplateName) {
            
            Integration_Message__c im = new Integration_Message__c();
            im.ID = imID;
            String sObjectType = sObjectId.getSObjectType().getDescribe().getName();
            if ( sObjectId.getSObjectType() == Address__c.sObjectType )
                im.Address__c = sObjectId;
            else if (sObjectId.getSObjectType() == Account.sObjectType ) 
                im.Account__c = sObjectId;
            else if ( sObjectId.getSObjectType() == Contact.sObjectType )
                im.Contact__c = sObjectId;
            else if( sObjectId.getSobjectType() == Contract.sObjectType ) 
                im.Contract__c = sObjectId;
            else if(sObjectId.getSobjectType() == Product2.sObjectType)
                im.Product2__c = sObjectId;
            else if(sObjectId.getSobjectType() == Document__c.sObjectType)
                im.Document__c = sObjectId;
                
            im.Object_Type__c = sObjectType;
            im.Operation__c = operation;
            im.Interface_Name__c = sObjectType + '_' + operation;
           // im.Interface_Priority__c = 1;
            im.Integration_Type__c = integrationType;
            im.Login_Request_Envelope__c = loginRequest;
            im.Login_Response_Envelope__c = loginResponse;
            im.Request_Envelope__c = requestEnvelope;
            im.Response_Envelope__c = responseEnvelope;
            im.Valid_for_Retrial__c = validForRetrial;
            im.Parent_Template_Name__c = parentTemplateName;
            return im;
        }
    
    //IM CREATION
    public Integration_Message__c createMinimalisticIMRecord(ID imID, ID sObjectId, String integrationType, String operation, String responseEnvelope,
                                                 boolean validForRetrial, string messageType, string uniqueKey, string status) {
            
            Integration_Message__c im = new Integration_Message__c();
            im.ID = imID;
            String sObjectType = sObjectId.getSObjectType().getDescribe().getName();
            if (sObjectType.equalsIgnoreCase('Address__c'))
                im.Address__c = sObjectId;
           else if (sObjectType.equalsIgnoreCase('Account'))
                im.Account__c = sObjectId;
            else if (sObjectType.equalsIgnoreCase('Contact'))
                im.Contact__c = sObjectId;
    
            im.Object_Type__c = sObjectType;
            im.Operation__c = operation;
            im.Integration_Type__c = integrationType;
            im.Response_Envelope__c = responseEnvelope;
            im.Valid_for_Retrial__c = validForRetrial;
            im.Message_Type__c = messageType;
            im.Unique_Key__c = uniqueKey;
            im.Integration_Status__c = status;
            return im;
        }

        //Function to validate im is valid for Retrial or not
        public Boolean validForRetrial(Integer errorCode, Integer numberOfRetrials) {

            if (errorcodeSet.contains(errorCode) && Integer.valueOf(numberOfRetrials) < Integer.valueOf(Label.Max_Integration_Retrial_Count)) {
                return true;
            }
            return false;
        }
		
        @AuraEnabled
        public static string getIntegrationMessageJSON( Id recordId ){
            Integration_Message__c objMsg = [Select Id, Name, Request_Envelope__c, Document__c FROM Integration_Message__c Where Id=:recordId];
            if( objMsg.Document__c != null ) {
                String jsonString = objMsg.Request_Envelope__c;
                return JSON.serializePretty( JSON.deserializeUntyped( jsonString ) );
            } else {
                ContentDocumentLink cdLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId Order by Id DESC LIMIT 1];
                ContentVersion objContentVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =: cdLink.ContentDocumentId LIMIT 1];  
                system.debug('===' + objContentVersion.VersionData.toString());          
                return JSON.serializePretty( JSON.deserializeUntyped( objContentVersion.VersionData.toString()));
            }
        }

        public HttpResponse getAuthorizationToken( String authorizationMetadata ) {
            Integration_Authorization__mdt authMdt = [SELECT ID, Token_Endpoint__c 
                                                        FROM Integration_Authorization__mdt 
                                                        WHERE DeveloperName =: authorizationMetadata];
            return getTokenCallout( authMdt );                                            
        }
        
        public HttpResponse getAuthorizationToken( Id authorizationMetadataId ) {
            Integration_Authorization__mdt authMdt = [SELECT ID, Token_Endpoint__c 
                                                        FROM Integration_Authorization__mdt 
                                                        WHERE Id =: authorizationMetadataId];
            return getTokenCallout( authMdt );
        } 

        private HttpResponse getTokenCallout( Integration_Authorization__mdt authMdt ) {
            List<Integration_Credential_Key_Pair__mdt> lstKeyPair = [ SELECT Id, Value__c, Key__c, Include_in_Header__c, Include_In_Param__c 
                                                                        FROM Integration_Credential_Key_Pair__mdt
                                                                        WHERE Integration_Authorization__c =: authMdt.Id 
                                                                        AND isActive__c = true];
            List<String> lstParams = new List<String>();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setTimeout(120000);
            for(Integration_Credential_Key_Pair__mdt objCred: lstKeyPair) {
                if( objCred.Include_in_Header__c ) {
                    req.setHeader(objCred.Key__c, objCred.Value__c);
                }
                if( objCred.Include_In_Param__c ) {
                    lstParams.add( objCred.Key__c + '=' + objCred.Value__c );
                }
            }
            system.debug('===' + req);
            system.debug('authMdt ' + authMdt);
            String endpoint = authMdt.Token_Endpoint__c + '?' + String.join(lstParams, '&');
            req.setEndpoint(endpoint);
            HttpResponse res = null;
            if(System.Test.isRunningTest()){
                res = new HttpResponse();
                res.setStatusCode(200);
                /*kafkaAuthToken token = new kafkaAuthToken();
                token.access_token = 'sample access token';
                token.token_type = 'sample access token';
                token.refresh_token = 'sample access token';
                token.expires_in = 200;
                token.scope = 'test class';
                return token.access_token;*/
                kafkaAuthToken token = new kafkaAuthToken();
                token.access_token = 'sample access token';
                token.token_type = 'sample access token';
                token.refresh_token = 'sample access token';
                token.expires_in = 200;
                token.scope = 'test class';
                String responseJSON = JSON.serialize( token );
                res.setBody( responseJSON );
                return res;
            } else {
                /*res = new HttpResponse();
                res.setStatusCode(500);
                kafkaAuthToken token = new kafkaAuthToken();
                token.access_token = 'sample access token';
                token.token_type = 'sample access token';
                token.refresh_token = 'sample access token';
                token.expires_in = 200;
                token.scope = 'test class';
                String responseJSON = JSON.serialize( token );
                res.setBody( responseJSON );
                return res;*/
                return ( new HTTP() ).send( req );
                /*Http mHttp = new Http(); res = mHttp.send(req);   
                if( res.getStatusCode() == 200 || res.getStatusCode() == 201 ) {
                    kafkaAuthToken token = (kafkaAuthToken)JSON.deserialize(res.getBody(), kafkaAuthToken.class);return token.access_token;
                } else { return 'dummy_token';}*/
            }
        }

        public class kafkaAuthToken {
            public String access_token ;
            public String token_type ;
            public String refresh_token ;
            public Decimal expires_in ;
            public String scope ;            
        }

    }