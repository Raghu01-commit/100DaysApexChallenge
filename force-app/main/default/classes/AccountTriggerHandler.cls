public with sharing class AccountTriggerHandler extends TriggerHandler {

    private List<Account> newAccounts;
    private List<Account> oldAccounts;
    private Map<Id, Account> newAccountMap;
    private Map<Id, Account> oldAccountMap;

    public AccountTriggerHandler() {
        this.newAccounts = (List<Account>) Trigger.new;
        this.oldAccounts = (List<Account>) Trigger.old;
        this.newAccountMap = (Map<Id, Account>) Trigger.newMap;
        this.oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
    }

    /* public override void beforeInsert() {
        
    } */

    public override void afterinsert() {
        AccountHelper.createContacts(newAccounts); //Challenge 5(ii)
    }

    public override void beforeUpdate() {
        AccountHelper.updateAccountDescription(newAccounts); //Challenge 5(i)
    }

    public override void afterUpdate() {
        AccountHelper.sendNewTierAccountEmails(newAccounts, oldAccountMap);//Challenge 3
        AccountHelper.updateContactAddress(newAccountMap,oldAccountMap);//Challenge 8
        OpportunityHelper.updateOppStage(newAccounts, oldAccountMap); //Challenge 10
    }

    /* public override void beforeDelete() {
        
    } */

    /* public override void afterDelete() {
        
    } */

    /* public override void afterUndelete() {
        
    } */
}