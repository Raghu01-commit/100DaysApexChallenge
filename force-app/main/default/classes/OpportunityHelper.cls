public with sharing class OpportunityHelper {
    
    public static void calculateLoyaltyPoints(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap){

        //Accounts To be updated
        Set<Id> accountIds = new Set<Id>();

        //Loop through Changed Opportunities
        for(Opportunity opp : newOpps){
            Opportunity oldOpp = oldOppsMap.get(opp.Id);
            if(opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won' && opp.AccountId != null){
                accountIds.add(opp.AccountId);
            }
    }

    //Check if the Set of Accounts are null and 
    if(!accountIds.isEmpty()){
        updateLoyaltyPoints(accountIds);
    }
}

private static void updateLoyaltyPoints(Set<Id> accIds){

    List<Account> accountsToBeUpdated = new List<Account>();

    for(AggregateResult agg : [SELECT AccountId, SUM(Amount) sumAmount FROM 
                                Opportunity WHERE StageName = 'Closed Won' AND AccountId IN :accIds GROUP BY AccountId]){
                                    Account acc = new Account();
                                    acc.Id = (Id) agg.get('AccountId');
                                    acc.Loyalty_Points__c = (Integer)(((Decimal) agg.get('sumAmount'))/10);
                                    accountsToBeUpdated.add(acc);
    }

    if(!accountsToBeUpdated.isEmpty()){
        update accountsToBeUpdated;
    }
    
}

}