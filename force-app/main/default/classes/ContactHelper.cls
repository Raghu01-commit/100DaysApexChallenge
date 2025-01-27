public with sharing class ContactHelper {
    public ContactHelper() {

    }

    public static void sumOfContactsAmount(List<Contact> contactsList, Map<Id, Contact> oldContactMap){

        //Account Ids to aggregate the Amount of the Contact
        Set<Id> accountIds = new Set<Id>();

        if((Trigger.isInsert || Trigger.isUndelete) && contactsList != null ){
                for(Contact con : contactsList){
                    if(con.AccountId != null){
                        accountIds.add(con.AccountId);
                    }
                }
        }

        if (Trigger.isDelete) {  // ✅ Explicitly add AccountIds for delete scenario
            for (Contact con : contactsList) {
                if (con.AccountId != null) {
                    accountIds.add(con.AccountId);
                }
            }
        }

        if(Trigger.isUpdate && contactsList != null){
            for(Contact con : contactsList){
                if(con.AccountId != null && 
                ((oldContactMap.get(con.Id).AccountId != con.AccountId) || oldContactMap.get(con.Id).Amount__c != con.Amount__c )){
                    accountIds.add(con.AccountId);
                }
            }
        }

        //Return from this process if there are no AccountIds related to the Contacts
        if(accountIds.isEmpty()){
            return;
        }


        Map<Id, Decimal> accountToSumOfContactAmount = new Map<Id, Decimal>();

        
        for(AggregateResult aggResult: [SELECT AccountId, SUM(Amount__c) sumAmount 
                                        FROM Contact WHERE AccountId IN :accountIds 
                                        GROUP BY AccountId]){

            accountToSumOfContactAmount.put(
                (Id) aggResult.get('AccountId'), (Decimal) aggResult.get('sumAmount')
            );

            }
            List<Account> listOfAccountsToBeUpdated = new List<Account>();

            
            for(Id accId : accountIds){
                Decimal newAmount = accountToSumOfContactAmount.containsKey(accId) ? accountToSumOfContactAmount.get(accId) : 0;
                listOfAccountsToBeUpdated.add(new Account(Id = accId, Sum_of_Amount__c =  newAmount));
            }
        

        if(!listOfAccountsToBeUpdated.isEmpty()){
            update listOfAccountsToBeUpdated;
        }
    }
}