public class PurchaseAsGroupController {
    
    @AuraEnabled
    public static WrapperConfirmation showConfirmation(string accountId){
    
        WrapperConfirmation wrpObj = new WrapperConfirmation();
        Account accObj =[select id,Name,parentId,(select id from ChildAccounts) from account where Id=:accountId];
        if (String.isBlank(accObj.parentId)){
             wrpObj.hasParent= false; 
        } else{
             wrpObj.hasParent= true; 
        }
        list<account> childAccounts = accObj.getSobjects('ChildAccounts');
        if (childAccounts==Null || childAccounts.size()==0){
             wrpObj.hasChild=false;
        } else{
             wrpObj.hasChild=true;
        }
        wrpObj.accObj=accObj;
        return wrpObj;
        
    }
    
    @AuraEnabled
    public static topWrapper getaccount(string accountId) {
        
        topWrapper wrpObj = new topWrapper();
        wrpObj.accObj = [select Id, S29_Purchase_as_Group__c from account where id=:accountId];
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = p.name.toUpperCase();
        return wrpObj;
    }
    
    @AuraEnabled
    public static string doUpdateAccounts(String accountId,boolean onTop,boolean setGroupFlag){
       try{
        if(onTop==true){
            
              Map<Id,Account> accountsToUpdate = new Map<id,Account>();
              Account accObj =[select id,Name,parentId,(select id from ChildAccounts) from account where Id=:accountId];
              if (setGroupFlag==true){
                  accObj.S29_Purchase_as_Group__c=true;
                  accObj.S29_Top_Account_in_Hierarchy__c=accountId;
                  accObj.S30_isOnTopinHeriarchy__c=true;
              }else{
                  accObj.S29_Purchase_as_Group__c=false;
              }
              accountsToUpdate.put(accObj.Id,accObj);
              
              //Fetching First level accounts
              List<Account> childAccounts = accObj.getSobjects('ChildAccounts');
              Set<Id> firstLevelAccountIds = new Set<Id>();
              if (!childAccounts.isEmpty()){
                  for (Account accObjchild:childAccounts){
                         firstLevelAccountIds.add(accObjchild.Id);
                         Account accObjNew = new Account();
                         accObjNew.Id=accObjchild.Id;
                         if (setGroupFlag==true){
                             accObjNew.S29_Purchase_as_Group__c=true;
                             accObjNew.S29_Top_Account_in_Hierarchy__c=accountId;
                         }else{
                             accObjNew.S29_Purchase_as_Group__c=false;
                         }
                         accountsToUpdate.put(accObjNew.Id, accObjNew);                    
                  }
              }
            
              set<id> secondLevelAccounts = new Set<id>();
              // SOQL should not be used inside for loop but this is only way to get all the heriarical records.
              if (!firstLevelAccountIds.isEmpty()){
                  for (Id accountidfirst:firstLevelAccountIds){
                      if (Limits.getQueries()<Limits.getLimitQueries()){
                               List<Account> accsecondList = [select id from account where ParentId=:accountidfirst];
                               for (Account acc2Obj:accSecondList){
                                     secondLevelAccounts.add(acc2Obj.id);
                                     Account accObjNew2 = new Account();
                                     accObjNew2.Id=acc2Obj.Id;
                                     if (setGroupFlag==true){
                                         accObjNew2.S29_Purchase_as_Group__c=true;
                                         accObjNew2.S29_Top_Account_in_Hierarchy__c=accountId;
                                     }else{
                                         accObjNew2.S29_Purchase_as_Group__c=false;
                                     }
                                      accountsToUpdate.put(accObjNew2.Id, accObjNew2);  
                                  } 
                         }else{
                               return 'Records limit Exceeded.';
                         }   
                  }
             }
            
            set<id> thirdLevelAccounts = new Set<id>();
            
            if (!secondLevelAccounts.isEmpty()){
                  for (Id accountidsecond:secondLevelAccounts){
                      if (Limits.getQueries()<Limits.getLimitQueries()){
                               List<Account> accthirdList = [select id from account where ParentId=:accountidsecond];
                               for (Account acc3Obj:accthirdList){
                                     thirdLevelAccounts.add(acc3Obj.id);
                                     Account accObjNew3 = new Account();
                                     accObjNew3.Id=acc3Obj.Id;
                                     if(setGroupFlag==true){
                                        accObjNew3.S29_Purchase_as_Group__c=true;
                                        accObjNew3.S29_Top_Account_in_Hierarchy__c=accountId;
                                     }else{
                                        accObjNew3.S29_Purchase_as_Group__c=false;
                                     }
                                     accountsToUpdate.put(accObjNew3.Id, accObjNew3);
                               }
                      }else{
                           return 'Records limit Exceeded.';
                      }   
                  }
              }
            
            set<id> fourthLevelAccounts = new Set<id>();
            
            if (!thirdLevelAccounts.isEmpty()){
                  for (Id accountidsthird:thirdLevelAccounts){
                      if (Limits.getQueries()<Limits.getLimitQueries()){
                               List<Account> accfourthList = [select id from account where ParentId=:accountidsthird];
                               for (Account acc4Obj:accfourthList){
                                     fourthLevelAccounts.add(acc4Obj.id);
                                     Account accObjNew4 = new Account();
                                     accObjNew4.Id=acc4Obj.Id;
                                     if (setGroupFlag==true){
                                         accObjNew4.S29_Purchase_as_Group__c=true;
                                         accObjNew4.S29_Top_Account_in_Hierarchy__c=accountId;
                                     }else{
                                         accObjNew4.S29_Purchase_as_Group__c=false; 
                                     }
                                     accountsToUpdate.put(accObjNew4.Id, accObjNew4);
                               }
                      }else{
                           return 'Records limit Exceeded.';
                      }   
                  }
              }
           
             update accountsToUpdate.values();
             return 'Purchases as Group for all Accounts in this Hierarchy updated sucessfully.';
            
        }else{
              Account accObj = new Account();
              accObj.Id=accountId;
              if (setGroupFlag==true){
                 accObj.S29_Purchase_as_Group__c=true;
                 accObj.S29_Top_Account_in_Hierarchy__c = fetchParentAccount(accObj.Id);
              }else{
                accObj.S29_Purchase_as_Group__c=false;
              }
              update accObj;
              return 'Purchases as Group for this Account  updated sucessfully.';               
             
        }
        //End of try statement    
        }catch(exception e){
           return e.getMessage();
        }
        
    } 
    //Method to fetch parent account 
    //This will handle for the 5level.
    public static id fetchParentAccount(id accountId){
        
        ID parentId;
        Account acc=[select parentId,Id from account where id=:accountId];
        parentId = acc.Id;
        
        if (!String.isEmpty(acc.ParentId)){
            parentId =acc.ParentId;
            Account acc1 = [select id,parentId from account where id=:acc.ParentId];
            if (!string.isEmpty(acc1.ParentId)) {
                
                  parentId = acc1.id;
                  Account acc2 =[select id,parentId from account where id=:acc1.ParentId];
                  if (!string.isEmpty(acc2.ParentId)){
                      parentId = acc2.ParentId;
                      Account acc3=[select id,parentid from account where id=:acc2.ParentId];
                      
                      if (!String.isEmpty(acc3.ParentId)){
                          parentId =acc3.ParentId;
                          account acc4 =[select id ,parentid from account where id=:acc3.ParentId];
                          
                          if (!string.isEmpty(acc4.ParentId)){
                              parentId =acc4.ParentId;
                              account acc5 =[select id,parentid from account where id=:acc4.ParentId];
                              if (!String.isEmpty(acc5.ParentId)){
                                  parentId=acc5.ParentId;
                              }
                          } 
                      }
                  }
               
            }
            
        }
        
        return parentId;
        
    }
    
    public class WrapperConfirmation{
        @AuraEnabled
        public boolean hasParent;
        @AuraEnabled 
        public boolean hasChild;
        @AuraEnabled 
        public Account accObj;
    }
    
    public class topWrapper{
         @AuraEnabled
         public string currentProfile;
         @AuraEnabled
         public account accObj;
        
    }

}