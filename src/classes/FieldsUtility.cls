/*********************************************************************************
Name:           FieldsUtility
Author:         Himanshu Verma [Fujitsu]
Purpose:        It returns the query with all the fields on the basis of sobjectname
Created Date:   29/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public class FieldsUtility{


 public static string fetchAllFields(String sobjName){
 
    String query='select ';
    try{   
        Map<String, Schema.SObjectField> fieldMap= Schema.getGlobalDescribe().get(sobjName).getDescribe().SObjectType.getDescribe().fields.getMap();
        list<string> fieldsNames= new list<string>();
        for(Schema.SObjectField field : fieldMap.values()){
               if(field.getDescribe().isAccessible()){
                  fieldsNames.add(field.getDescribe().getName());
               }
               if(field.getDescribe().isCustom() && field.getDescribe().isAccessible() 
                   && field.getDescribe().getType()==Schema.DisplayType.Reference){
                  fieldsNames.add(field.getDescribe().getName().replace('__c','__r.Name'));
               }
        }
    
        for(String fieldname : fieldsNames)
            query+= fieldname+',';
    
        query = query.subString(0,query.length()-1);
         
        query +=' From '+sobjName;
        }catch(exception e){}
    return query ;
 }
 


}