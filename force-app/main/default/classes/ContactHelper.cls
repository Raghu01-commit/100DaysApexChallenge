public with sharing class ContactHelper {
    public static void sumOfContactsAmount(List<Contact> contactsList, Map<Id, Contact> oldContactMap){

        //Account Ids to aggregate the Amount of the Contact
        Set<Id> accountIds = new Set<Id>();

        //Add accountIds for Insert and Undelete scenarios
        if((Trigger.isInsert || Trigger.isUndelete || Trigger.isDelete) && contactsList != null ){
                for(Contact con : contactsList){
                    if(con.AccountId != null ){
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

        //This is a comment Test 
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



    public static void preventContactDeletion(List<Contact> contactsList){

        //Collect the Contact Ids
        Set<Id> contactIds = new Set<Id>();

        for(Contact con : contactsList){
            contactIds.add(con.Id);
        }

        Map<Id, OpportunityContactRole> contactRoleMap = new Map<Id, OpportunityContactRole>();

        //Query those OppContactRoles where the ContactId is present, it is marked as Primary and also at the same time the Opp is Open.
        List<OpportunityContactRole> contactRoles = [SELECT ContactId FROM OpportunityContactRole WHERE ContactId IN : contactIds AND     IsPrimary = TRUE AND Opportunity.StageName NOT IN ('Closed Won', 'Closed Lost')];

        if(!contactRoles.isEmpty()){
            //Query the Opp Contact Roles to find that the Contact is not a Primary Contact on an Open Opp
            for(OpportunityContactRole ocr : contactRoles){
                contactRoleMap.put(ocr.contactId, ocr);
                }
        }

        //Prevent the deletion of the Contacts
        for(Contact con : contactsList){
            if(contactRoleMap.containsKey(con.Id)){
                con.addError('This Contact is marked as Primary Contact against an Open Opportunity. You cannot delete this boss');
            }
        }

    }

    public static void countOfActiveContacts(List<Contact> contactList, Map<Id, Contact> oldContactMap){

        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accIdToCountMap = new Map<Id, Integer>();

        if(Trigger.isInsert || Trigger.isUndelete || Trigger.isDelete){
            for(Contact con : contactList){
                if(con.AccountId != null && con.Active__c){
                    accIds.add(con.AccountId);
                }
            }
        }

        if(Trigger.isUpdate){
            for(Contact con : contactList){
                if(con.AccountId != null &&
                ((oldContactMap.get(con.Id).Active__c != con.Active__c) || (con.AccountId != oldContactMap.get(con.Id).AccountId))){
                    accIds.add(con.AccountId);
                    accIds.add(oldContactMap.get(con.Id).AccountId);
                }
            }
        }

        if(!accIds.isEmpty()){
            for(AggregateResult agg : [SELECT AccountId, COUNT(Id) cnt 
                                        FROM Contact 
                                        WHERE AccountId IN : accIds 
                                        AND Active__c = true 
                                        GROUP BY AccountId]){
                accIdToCountMap.put((Id)agg.get('AccountId'),(Integer)agg.get('cnt'));
            }
        }

        List<Account> accountsToBeUpdated = new List<Account>();

        if(!accIdToCountMap.isEmpty()){
            for(Id accId : accIds){
                Account acc = new Account();
                acc.Id = accId;
                acc.Active_Contacts_Count__c = accIdToCountMap.get(accId) != null ? accIdToCountMap.get(accId) : 0;
                accountsToBeUpdated.add(acc);
            }
        }
        
        if(!accountsToBeUpdated.isEmpty()){
            update accountsToBeUpdated;
        }
    }

    //whenever there is a change in the Account of the Contact
    public static void updateContactAddress(List<Contact> newContacts, Map<Id, Contact> oldContactMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null && (oldContactMap.get(con.Id) == null || con.AccountId != oldContactMap.get(con.Id).AccountId)) {
                accountIds.add(con.AccountId);
            }
        }
    
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Id IN :accountIds]);
        //List<Contact> contactsToBeUpdated = new List<Contact>();
    
        for (Contact con : newContacts) {
            if (con.AccountId != null && accountMap.containsKey(con.AccountId)) {
                Account acc = accountMap.get(con.AccountId);

                con.MailingStreet = acc.BillingStreet;
                con.MailingCity = acc.BillingCity;
                con.MailingState = acc.BillingState;
                con.MailingCountry = acc.BillingCountry;
                con.MailingPostalCode = acc.BillingPostalCode;
            }
        }
    }

    //Challenge 14(i)
    //enforce single primary Contact on Account
    //When Inserting a Contact or before updating a Contact.
    public static void enforceSinglePrimaryContact(List<Contact> contactsList, Map<Id, Contact> oldContactsMap){

        Set<Id> accIds = new Set<Id>();

            for(Contact con : contactsList){
                if((oldContactsMap == null && con.Primary_Contact__c  && con.AccountId != null) || 
                (oldContactsMap != null && (con.Primary_Contact__c != oldContactsMap.get(con.Id).Primary_Contact__c || con.AccountId != oldContactsMap.get(con.Id).AccountId) && con.Primary_Contact__c)){
                    accIds.add(con.AccountId);
                }
            }
        

        Map<Id, Integer> accountToContactCountMap = new Map<Id, Integer>();

        if(!accIds.isEmpty()){
            for(AggregateResult agg : [SELECT AccountId, COUNT(Id) totalContacts
                                        FROM Contact WHERE AccountId IN :accIds AND Primary_Contact__c = true 
                                        GROUP BY AccountId]){

                accountToContactCountMap.put((Id)agg.get('AccountId'), (Integer)agg.get('totalContacts'));
            }
        }

        for(Contact c : contactsList){
            if(c.AccountId != null && c.Primary_Contact__c && accountToContactCountMap.containsKey(c.AccountId) && accountToContactCountMap.get(c.AccountId) > 0){
                c.addError('There is already a Primary Contact under this Account');
            }
        }
    }


    //Challenge 14(ii)
    //When the Account of a Contact is updated, in the After Update context, then the old Account should have a Primary Contact. 
    //The oldest created contact among the remaining will be updated as Primary.

    public static void updatePrimaryContactOnOldAccount (List<Contact> contactsList, Map<Id, Contact> oldContactsMap){
        List<Contact> oldContactsList = new List<Contact>();
        for(Contact con : contactsList){
            if(con.AccountId != oldContactsMap.get(con.Id).AccountId && con.Primary_Contact__c){
                oldContactsList.add(oldContactsMap.get(con.Id));
            }
        }
        if(!oldContactsList.isEmpty()){
            updatePrimaryContact(oldContactsList);
        }
    }


    //Challenge 14(iii)
    //When a Contact is deleted then the Oldest created contact should be marked as Primary Contact
    public static void updatePrimaryContact(List<Contact> oldContactsList){

        Set<Id> delContactAccIds = new Set<Id>();
            for(Contact c : oldContactsList){
                if(c.AccountId != null && c.Primary_Contact__c){
                    delContactAccIds.add(c.AccountId);
                }
            }

        Map<Id, Contact> accToOldContactMap = new Map<Id, Contact>();

        if(!delContactAccIds.isEmpty()){
            for(Contact con : [SELECT Id, AccountId, Primary_Contact__c FROM Contact WHERE AccountId IN : delContactAccIds ORDER BY CreatedDate ASC]){

                if(!accToOldContactMap.containsKey(con.AccountId)){
                    accToOldContactMap.put(con.AccountId, con);
                }
            }
        }
        // Update the Primary_Contact__c field
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Contact con : accToOldContactMap.values()) {
                con.Primary_Contact__c = true;
                contactsToUpdate.add(con);
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
    

    //Challenge 14(iv)
    //When a Contact is undeleted, if it is a Primary Contact then it should be aligned back to Primary Contact for the Account and uncheck the existing Primary Contact. When multiple Primary Contacts under same Account are deleted then the Oldest among them should be marked as Primary Contact
    public static void reevaluatePrimaryContact(List<Contact> contactsList){

        Set<Id> accIdsOfUndeletedConts = new Set<Id>();
            Set<Id> undeletedIds = new Set<Id>();
            Map<Id, List<Contact>> accToUndeletedPrimaries = new Map<Id, List<Contact>>();
            
            for(Contact con : contactsList){
                if(con.AccountId != null && con.Primary_Contact__c){
                    accIdsOfUndeletedConts.add(con.AccountId);
                    undeletedIds.add(con.Id);

                    if(!accToUndeletedPrimaries.containsKey(con.AccountId)){
                        accToUndeletedPrimaries.put(con.AccountId, new List<Contact>{con});
                    }
                    else {
                        accToUndeletedPrimaries.get(con.AccountId).add(con);
                    }
                }
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            //Process duplicate undeleted primaries
            for(Id accId : accToUndeletedPrimaries.keySet()){
                List<Contact> primaries = accToUndeletedPrimaries.get(accId); //Collecting all the Primary Contacts undeleted under a particular Account
                primaries.sort(); //Sorting the list to exclude the Oldest created Contact and mark remaining all as non Primary
                for(Integer i = 1; i < primaries.size(); i++){
                    Contact c = new Contact (Id = primaries[i].Id, Primary_Contact__c = false);
                    contactsToUpdate.add(c); //Adding to list to update at the end
                }
            }

            //Handle existing Primaries (not in undeleted Contacts)
            if(!accIdsOfUndeletedConts.isEmpty()){
                for(Contact con : [SELECT Id, Primary_Contact__c 
                                    FROM Contact 
                                    WHERE AccountId IN : accIdsOfUndeletedConts 
                                    AND Primary_Contact__c = true 
                                    AND Id NOT IN :undeletedIds]){
                    con.Primary_Contact__c = false;
                    contactsToUpdate.add(con);
                }
            }

            if(!contactsToUpdate.isEmpty()){
                update contactsToUpdate;
            }
    }

}