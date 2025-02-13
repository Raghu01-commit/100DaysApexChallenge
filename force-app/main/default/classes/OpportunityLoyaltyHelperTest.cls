@isTest
public class OpportunityLoyaltyHelperTest {

    @isTest
    static void testOpportunityLoyaltyPoints() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Opportunity - Not Closed Won
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 1000,
            AccountId = acc.Id
        );
        insert opp;

        // Update Opportunity to Closed Won
        opp.StageName = 'Closed Won';
        update opp;

        // Retrieve Updated Account
        Account updatedAcc = [SELECT Id, Loyalty_Points__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100, updatedAcc.Loyalty_Points__c, 'Loyalty Points should be calculated as Amount/10');
    }

    @isTest
    static void testOpportunityNoStageChange() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Opportunity - Already Closed Won
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 1000,
            AccountId = acc.Id
        );
        insert opp;

        // Update Opportunity Without Changing Stage
        opp.Amount = 2000;
        update opp;

        //Loyalty points remain 0 as they the Opportunity Stage is not Closed Won. Loyalty Points are calculated only when the Stage becomes 'Closed Won'.
        Account updatedAcc = [SELECT Id, Loyalty_Points__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, updatedAcc.Loyalty_Points__c, 'Loyalty Points should not be updated. They should be zero as the Opportunity is not Closed Won.');
    }

    @isTest
    static void testOpportunityNoAccountId() {
        // Create Opportunity without Account
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity No Account',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 1000
        );
        insert opp;

        // Update Opportunity to Closed Won
        opp.StageName = 'Closed Won';
        update opp;

        // No errors should occur, and no account updates expected
         // Ensure no account was updated
        List<Account> updatedAccounts = [SELECT Id, Loyalty_Points__c FROM Account WHERE Loyalty_Points__c != null];
        System.assertEquals(0, updatedAccounts.size(), 'No accounts should be updated when Opportunity has no AccountId');
    }

}
