public with sharing class CaseTriggerHandler extends TriggerHandler {

    private List<Case> newCases;
    private List<Case> oldCases;
    private Map<Id, Case> newCaseMap;
    private Map<Id, Case> oldCaseMap;

    public CaseTriggerHandler() {
        this.newCases = (List<Case>) Trigger.new;
        this.oldCases = (List<Case>) Trigger.old;
        this.newCaseMap = (Map<Id, Case>) Trigger.newMap;
        this.oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
    }
    
    public override void beforeInsert() {
        CaseHelper.assignCasesToQueues(newCases, oldCaseMap); //Challenge 9
    } 

    public override void afterinsert() {
        CaseHelper.updateLatestCaseNumberOnAccount(newCases, oldCaseMap); //Challenge 11
    }

    public override void beforeUpdate() {
        Casehelper.assignCasesToQueues(newCases, oldCaseMap); //Challenge 9
    }
    
    public override void afterUpdate() { 
        CaseHelper.updateLatestCaseNumberOnAccount(newCases, oldCaseMap); //Challenge 11
    } 

    /* public override void beforeDelete() {
        
    } */

    /* public override void afterDelete() {
        
    } */

    /* public override void afterUndelete() {
        
    } */
}