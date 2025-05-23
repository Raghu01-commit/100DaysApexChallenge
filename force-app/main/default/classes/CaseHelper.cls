public with sharing class CaseHelper {

    public static void assignCasesToQueues(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        
        // Query for all active queue assignments
        List<Case_Queue_Assignment__mdt> queueAssignments = [SELECT Product_Category__c, Queue_Developer_Name__c 
                                                        FROM Case_Queue_Assignment__mdt 
                                                        WHERE Active__c = true];
        // Create a map of product categories to queue developer names
        Map<String, String> categoryToQueueMap = new Map<String, String>();

        //Collection to query the Queues
        Set<String> queueNames = new Set<String>();

        for (Case_Queue_Assignment__mdt qa : queueAssignments) {
            categoryToQueueMap.put(qa.Product_Category__c, qa.Queue_Developer_Name__c);
            queueNames.add(qa.Queue_Developer_Name__c);
        }
        
        // Query for queue Ids
        Map<String, Id> queueMap = new Map<String, Id>();

        for (Group queue : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :queueNames]) {
            queueMap.put(queue.DeveloperName, queue.Id);
        }

        
        List<Case> casesToUpdate = new List<Case>();

        // Process cases
        for (Case c : newCases) {
            if(oldCasesMap == null && c.Status != 'Closed' && String.isNotBlank(c.Product_Category__c)){
                assignQueues(c, categoryToQueueMap, queueMap, casesToUpdate);
            }
            else if(c.Product_Category__c != oldCasesMap.get(c.Id).Product_Category__c && c.Status != 'Closed' && String.isNotBlank(c.Product_Category__c)){
                assignQueues(c, categoryToQueueMap, queueMap, casesToUpdate);
            }
        }
    }

    private static void assignQueues(Case c, Map<String, String> categoryToQueueMap, Map<String, Id> queueMap, List<Case> casesToUpdate){
        String queueDeveloperName = categoryToQueueMap.get(c.Product_Category__c);
        if (queueDeveloperName != null && queueMap.containsKey(queueDeveloperName)) {
            c.OwnerId = queueMap.get(queueDeveloperName);
        }
    }

    public static void updateLatestCaseNumberOnAccount(List<Case> newCases, Map<Id, Case> oldCasesMap){

        Set<Id> acctIds = new Set<Id>();

        for(Case cs : newCases){
            if(oldCasesMap == null && cs.AccountId != null){
                acctIds.add(cs.AccountId);
            }
            else if((oldCasesMap != null && cs.AccountId != null && ((cs.AccountId != oldCasesMap.get(cs.Id).AccountId) || (cs.Priority != oldCasesMap.get(cs.Id).Priority)))){
                acctIds.add(cs.AccountId);
                acctIds.add(oldCasesMap.get(cs.Id).AccountId);
            }
        }

        Map<Id, Case> accIdToCaseMap = new Map<Id, Case>();

        //Querying the records to fetch them in the order we need
        List<Case> latestCases = [SELECT Id, CaseNumber, CreatedDate, Priority, AccountId 
                                    FROM Case 
                                    WHERE AccountId IN : acctIds AND Status != 'Closed'
                                    ORDER BY Priority ASC, CreatedDate DESC, AccountId, CaseNumber DESC];    
                                    
                                    
        if(!latestCases.isEmpty()){
            for(Case cs : latestCases){
                if(!accIdToCaseMap.containsKey(cs.AccountId)){
                    accIdToCaseMap.put(cs.AccountId, cs);
                }
                else {
                    continue; //iterate over the next case if there is a latest case mapped to an Account already
                }
                
            }
        }

        List<Account> accountsToUpdate = new List<Account>();

        for(Id accId : acctIds){

            if(accIdToCaseMap.containsKey(accId)){
                Case c = accIdToCaseMap.get(accId);
                accountsToUpdate.add(new Account(Id = accId, Latest_Case_Number__c = c.CaseNumber));
            }
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }

    }

    //Challenge 16
    public static void updateCaseSLA(List<Case> casesList, Map<Id, Case> oldCasesMap){
        //Get Business Hours for Customer Support Team
        BusinessHours csTeamBH = [SELECT Id FROM BusinessHours WHERE Name = 'Customer Support Team'];

        Integer slaHours = 0;

        for(Case c : casesList){

            if((oldCasesMap == null && c.Priority != null) || (oldCasesMap != null && c.Priority != null && c.Priority != oldCasesMap.get(c.Id).Priority)){
                
                if(c.Priority == 'High'){
                    slaHours = 4;
                }
                else if (c.Priority == 'Medium'){
                    slaHours = 8;
                }
                else {
                    slaHours = 24;
                }
                c.SLA_Marked_Time__c = system.now();
                c.SLA_Due_Date__c = BusinessHours.add(csTeamBH.Id, system.now() , (long)(slaHours * 60 * 60 * 1000));
            }
        }
    }

    //Challenge 18
    public static void updateCaseStatusOnAccount(List<Case> casesList, Map<Id, Case> oldCasesMap){

        List<Account> accountsToBeUpdated = new List<Account>();

        Set<Id> accIds = new Set<Id>();

        for(Case c : casesList){
            system.debug('Entered into the for loop:::::');
            if(c.Status == 'Closed' && oldCasesMap.containsKey(c.Id) && oldCasesMap.get(c.Id).Status != 'Closed' && c.AccountId != null){
                accIds.add(c.AccountId);
            }
        }

        system.debug('These AccIds are collected :::: '+accIds);

        Map<Id, Integer> accIdToOpenCasesMap = new Map<Id, Integer>();

        //the aggregate query doesn't add the row of the account that doesn't have any open cases related. So to handle the scenario when //all the cases are closed, then the amount should be 0.

        for (Id accId : accIds) {
            accIdToOpenCasesMap.put(accId, 0);  // Default to 0, assuming no open cases
        }

        //The reason why we are initializing zero here is we have to validate if the count is 0 or not. So for that to happen there should be a key-value pair in the map. Reference : ContactHelper.sumOfContactsAmount()

        if(!accIds.isEmpty()){
            for(AggregateResult agg : [SELECT Count(Id) openCasesCount, AccountId 
                                        FROM Case 
                                        WHERE Status != 'Closed' AND AccountId IN : accIds 
                                        GROUP By AccountId]){

                accIdToOpenCasesMap.put((Id) agg.get('AccountId'), (Integer) agg.get('openCasesCount'));
            }
        }

        if(!accIdToOpenCasesMap.isEmpty()){
            for(Id accId : accIds ){
                if(accIdToOpenCasesMap.get(accId) == 0){
                    accountsToBeUpdated.add(new Account(Id = accId, Case_Status__c = 'All cases resolved')); //Assuming that all Accounts have open cases, updating only this Status explicitly.
                }
                
            }
        }

        if(!accountsToBeUpdated.isEmpty()){
            update accountsToBeUpdated;
        }
    }
}