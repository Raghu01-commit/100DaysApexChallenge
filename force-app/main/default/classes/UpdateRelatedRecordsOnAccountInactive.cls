public with sharing class UpdateRelatedRecordsOnAccountInactive implements Queueable{
    
    public void execute(QueueableContext qc){
        //Fetch Account records that are marked as Inactive
        List<Account> inactiveAccs = [SELECT Id, IsInactive__c 
                                    FROM Account 
                                    WHERE IsInactive__c = true AND Is_Processed__c = true];
        Set<Id> accIds = new Set<Id>();

        if(!inactiveAccs.isEmpty()){
            for(Account acc : inactiveAccs){
                accIds.add(acc.Id);
            }
        }
        
        //Fetch all related Opportunities, Contacts, Cases
        List<Opportunity> oppsToUpdate = [SELECT Id, StageName FROM Opportunity WHERE AccountId IN :accIds];
        List<Contact> contactsToUpdate = [SELECT Id, Active__c FROM Contact WHERE AccountId IN : accIds];
        List<Case> casesToUpdate = [SELECT Id, Status FROM Case WHERE AccountId IN :accIds];

        //Make respective changes to the records
        for(Opportunity opp : oppsToUpdate){
            opp.StageName = 'Closed Lost';
        }

        for(Contact con : contactsToUpdate){
            con.Active__c = false;
        }

        for(Case cs : casesToUpdate){
            cs.Status = 'Closed';
        }
        
        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }
        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }

        //Mark the Accounts as IsProcessed to avoid from triggering again
        for(Account acc : inactiveAccs){
            acc.Is_Processed__c = true;
        }
        update inactiveAccs;

        //If there are any additional actions such as log update, sendingEmails we can chain Queueable Jobs here
    }
}