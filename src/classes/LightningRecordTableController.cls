/**************************************************************************************************
 * Class : LightningRecordTableController
 * Created By : Ameya Wadke
 --------------------------------------------------------------------------------------------------
 * Description : Controller for fetching the records and 
 				 checking of the fields for the specified object
 --------------------------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ameya Wadke       26/07/2017    Initial Development
 **************************************************************************************************/

public with sharing class LightningRecordTableController {
   private static String SELECTCLAUSE = 'SELECT ';
    private static String FROMCLAUSE = 'FROM ';
    private static String ORDER_BY = ' ORDER BY ';
    private static String LIMITCLAUSE = ' LIMIT ';
    private static String SPACE = ' ';
    private static Map<String,String> referenceFields ;
    private static Map<String,String> mapOfObjNameAndRelationName = new Map<String,String> ();
    private static Map<String,String> mapOfObjNameAndFieldRelatedName = new Map<String,String> ();
    
    /**
     * Method for returning records to component
     *
     * @param objectName String Name of object
     * @param selectedFields String Fileds needs to be shown in list view
     * @param filterCondition String filter condition
     * @param orderBy String orderby clause
     *
     * @return RecordsInfo Wrapper contact records
     */
    @AuraEnabled
    public static RecordsInfo getRecords(String objectName,String selectedFields, String filterCondition, String orderBy) {
        List<Sobject> records = new List<Sobject>();
        String errorMessage = '';
        String query = getQuery(
            objectName,
            selectedFields,
            filterCondition,
            orderBy
            
        );
        records = Database.query(query);
        
        if(records.isEmpty() ){
            errorMessage = Label.NoRecordsFound;
        }
       
        RecordsInfo recInfo = new RecordsInfo(
            records,
            getColumnHeaders(
                selectedFields.split(','),
                objectName
            ),
            String.isBlank(errorMessage) ? null : errorMessage,
            referenceFields
        );
        return recInfo;
    }

    /**
     * Method for returning record table's Column Headers.
     * If value is provided in columnHeaders, they are returned as it is otherwise return's field's
     * Label name as column header
     *
     * @param colFields list of String provided field's api names
     * @param objectName String Name of object
     *
     * @return colHeaders list of String Column headers
     */
    public static List<String> getColumnHeaders(List<String> colFields, String objectName) {
        Map<String,Schema.SobjectType> globalDesc = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> objectFields;
        List<String> colHeaders = new List<String>();

        if(globalDesc.containskey(objectName)) {
            Schema.DescribeSObjectResult result = globalDesc.get(objectName).getDescribe();
            objectFields = result.fields.getMap();
        }
        for(Integer i = 0; i < colFields.size(); i++) {
            if (objectFields != null && objectFields.containsKey(colFields[i])) {
                Schema.DescribeFieldResult fldResult = objectFields.get(colFields[i]).getDescribe();
                colHeaders.add(fldResult.getLabel());
            }
            else {
                colHeaders.add(colFields[i]);
            }
        }
        return colHeaders;
    }

    /**
     * Method for returning and generating dynamic query with provided paramenters 
     * @param objectName String Name of object
     * @param selectedFields String Fileds needs to be shown in list view
     * @param filterCondition String filter condition
     * @param orderBy String orderby clause
     *
     * @return query String precomplied query
     */
    private static String getQuery (String objectName, String selectedFields, String filterCondition, String orderBy) {
        String query = '';
        String queryParameters = '';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        
        List<String> apiNames = new List<String>();
        referenceFields = new Map<String,String>();
        
        for(String field : selectedFields.split(',')){
           Schema.DisplayType typeOfField = fieldMap.get(field).getDescribe().getType();
           if(typeOfField == Schema.DisplayType.REFERENCE){
                Schema.DescribeFieldResult f = fieldMap.get(field).getDescribe();
                apiNames.add(field);
                for(Schema.SObjectType reference : f.getReferenceTo()) {
                    String referencefield = getRefernceFieldName(objectName,String.valueOf(reference));
                    apiNames.add(referencefield);
                    referenceFields.put(field,referencefield);
                }
           }else{
           		if(fieldMap.containsKey(field)){
           			apiNames.add(field);
           		}
           }
        }
        
        if(!apiNames.isEmpty()){
            for(String field: apiNames){
                queryParameters += field;
                queryParameters +=', ';
            }
        }

        selectedFields = queryParameters.removeEnd(', ');

        query += SELECTCLAUSE + selectedFields;
        
        query += SPACE + FROMCLAUSE + objectName;
        if(String.isNotBlank(filterCondition)) {
            query += SPACE + filterCondition;
        }
        if(String.isNotBlank(orderBy)) {
            query += ORDER_BY + orderBy;
        }
        return query;
    }

    /**
     * Method to return the relationshipFieldName
     *
     * @param parentObj String containing the parent object Api name
     *
     * @return relationshipName String that is relationship name so that to use it in query
     **/
    public static String getRefernceFieldName(String objectName,String parentObj){
        Schema.DescribeFieldResult result = getRelatedObjName(objectName,parentObj);
        String relationshipName = result.getRelationshipName();
        relationshipName +='.Name';
        return relationshipName;
    }

   /**
    * Method to return the relationshipFieldName
    *
    * @param parentObj String containing the parent object Api name
    *
    * @return relationshipName String that is relationship name so that to use it in query
    **/
    public static Schema.DescribeFieldResult getRelatedObjName (String childObjName, String parentObjName) {
        Schema.DescribeFieldResult relName;
        Schema.DescribeFieldResult relNameClone;
            if (childObjName != null && parentObjName != null) {
                Map<String, Schema.SObjectField> sObjFieldMap = retrieveSObjectFieldsMap(childObjName);
                if (sObjFieldMap != null) {
                    for (Schema.SObjectField sObjField : sObjFieldMap.values()) {
                        relName = sObjField.getDescribe();
                        List<Schema.SobjectType> lstToken = relName.getReferenceTo();
                        if (!relName.isNamePointing() && lstToken.size() > 0 && 
                            lstToken.get(0) == createObject(parentObjName).getSobjectType()) {
                            relNameClone = relName;
                            return relNameClone;
                        }
                    } // End for
                } // End if
            } // End if 
        return relNameClone;
    }

    /**
     * A method to convert a String into sObject Name
     *
     * @param: objName : Name of the object for which the instance has 
     * to be created
     *
     * @return: sObject instance
     */
    public static sObject createObject (String objName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
           return null;
        }
        // Instantiate an sObject with the type passed in as an argument
        //  at run time.
        return targetType.newSObject();
    }
    
    /**
     * A method is used to retrieve sObject Fields Map
     *
     * @param: objName : Name of the object for which the fields are required
     *
     * @return
     */ 
    public static Map<String, Schema.SObjectField> retrieveSObjectFieldsMap (String objName) {
        Map<String, Schema.SObjectField> fieldMap;
        if (objName != null && objName != '') {
            Schema.Describesobjectresult objectDescribe = Schema.getGlobalDescribe().get(objName).getDescribe();
            if (objectDescribe != null) {
                fieldMap = objectDescribe.fields.getMap();
            } // End if
        } // End if
        return fieldMap;
    } // End method

    
    
    
    /**
     * Method for returning error related to fields if any
     *
     * @param objectName String Name of object
     * @param selectedFields String Fileds needs to be shown in list view
     *
     * @return RecordsInfo Wrapper record
     */
    @AuraEnabled 
    public static RecordsInfo checkFields(String objectName,String selectedFields) {
    	Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        String errorFields = '';
        RecordsInfo objRecord = new RecordsInfo();
        
        for(String fieldName : selectedFields.split(',')){
        	if(!fieldMap.containsKey(fieldName)){
        		errorFields += fieldName +', ';
        	}
        }
        if(String.isNotBlank(errorFields)){
        	if(errorFields.endsWith(',')){
        		errorFields.removeEnd(',');
        	}
        }
        objRecord.errorMessage = errorFields;
        return objRecord;
    }
    
   
    /**
     * Class for returning Records and its info to controller
     */
    public class RecordsInfo {
        @AuraEnabled
        public List<Sobject> records;
        @AuraEnabled
        public List<String> columnHeaders;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled 
        public Map<String,String> apiNamesAndReferenceNames;
       
	    public RecordsInfo(){}
	    
        public RecordsInfo(
            List<Sobject> records,
            List<String> columnHeaders,
            String errorMessage,
            Map<String,String> apiAndReferenceNames
          
        ){
            this.records = records;
            this.columnHeaders = columnHeaders;
            this.errorMessage = errorMessage;
            this.apiNamesAndReferenceNames = apiAndReferenceNames;
           
        }
    }
}