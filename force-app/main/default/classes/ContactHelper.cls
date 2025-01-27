public with sharing class ContactHelper {
    public ContactHelper() {

    }

    public static void sumOfContactsAmount(List<Contact> contactsList, Map<Id, Contact> oldContactMap){

        //Account Ids to aggregate the Amount of the Contact
        Set<Id> accountIds = new Set<Id>();

        //Add accountIds for Insert and Undelete scenarios
        if((Trigger.isInsert || Trigger.isUndelete) && contactsList != null ){
                for(Contact con : contactsList){
                    if(con.AccountId != null){
                        accountIds.add(con.AccountId);
                    }
                }
        }

        // Explicitly add AccountIds for delete scenario
        if (Trigger.isDelete) {  
            for (Contact con : contactsList) {
                if (con.AccountId != null) {
                    accountIds.add(con.AccountId);
                }
            }
        }

        //add accountids for the update scenario
        if(Trigger.isUpdate && contactsList != null){
            for(Contact con : contactsList){
                //Amount on Account changes when the Account is changed or amount is changed
                if(con.AccountId != null && 
                ((oldContactMap.get(con.Id).AccountId != con.AccountId) || oldContactMap.get(con.Id).Amount__c != con.Amount__c )){ 
                    accountIds.add(con.AccountId);
                    accountIds.add(oldContactMap.get(con.Id).AccountId);
                }
            }
        }

        //Return from this process if there are no AccountIds related to the Contacts
        if(accountIds.isEmpty()){
            return;
        }

        //Map that stores the accountid and its sum of Amount for the related Contacts
        Map<Id, Decimal> accountToSumOfContactAmount = new Map<Id, Decimal>();

        //Aggregate query for the AccountId and sum of Amount to be stored in the Map
        for(AggregateResult aggResult: [SELECT AccountId, SUM(Amount__c) sumAmount 
                                        FROM Contact WHERE AccountId IN :accountIds 
                                        GROUP BY AccountId]){

            accountToSumOfContactAmount.put(
                (Id) aggResult.get('AccountId'), (Decimal) aggResult.get('sumAmount')
            );

            }

            //List of accounts to be updated
            List<Account> listOfAccountsToBeUpdated = new List<Account>();

            
            for(Id accId : accountIds){
                //the aggregate query doesn't add the row of the account that doesn't have any contacts related. So to handle the scenario when all the contacts are deleted, 
                //then amount should be 0
                Decimal newAmount = accountToSumOfContactAmount.containsKey(accId) ? accountToSumOfContactAmount.get(accId) : 0;
                listOfAccountsToBeUpdated.add(new Account(Id = accId, Sum_of_Amount__c =  newAmount));
            }
        

        if(!listOfAccountsToBeUpdated.isEmpty()){
            update listOfAccountsToBeUpdated;
        }
    }
}