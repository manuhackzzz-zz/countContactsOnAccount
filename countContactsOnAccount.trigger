// Trigger to update contact count on Account record's ContactCount__c field

trigger countContactsOnAccount on Contact(after insert, after update, after delete, after undelete){
  
  Set<Id> accountIds = new Set<Id>();

  if (Trigger.isInsert) { // Insert
    for(Contact c : Trigger.New) {
        accountIds.add(c.AccountId);
    }
  } else if (Trigger.isDelete) { // Delete
    for(Contact c : Trigger.old) {
        accountIds.add(c.AccountId);
    }
  } else if (Trigger.isUpdate){  //Update 
    for(Contact c : Trigger.New) {
        if(Trigger.oldMap.get(c.Id).AccountId != c.AccountId) {
            accountIds.add(c.AccountId);
            accountIds.add(Trigger.oldMap.get(c.Id).AccountId);
        }
    }
  } else if (Trigger.isUndelete) { // Undelete
    for(Contact c : Trigger.New) {
        accountIds.add(c.AccountId);
    }
  }

   if(accountIds.contains(null)) { accountIds.remove(null);} 

    List<Account> accList = new List<Account>();
    for (AggregateResult aggr : [SELECT AccountId AcctId, Count(id) ContactCount 
                               FROM Contact 
                               WHERE AccountId in: accountIds 
                               GROUP BY AccountId]){
        Account acc = new Account();
        acc.Id = (Id) aggr.get('AcctId');
        acc.ContactCount__c = (Integer) aggr.get('ContactCount');
        accList.add(acc);
    }

    update accList;
}