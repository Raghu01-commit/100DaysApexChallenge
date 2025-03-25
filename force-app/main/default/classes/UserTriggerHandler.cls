public with sharing class UserTriggerHandler extends TriggerHandler {

    private List<User> newUsers;
    private List<User> oldUsers;
    private Map<Id, User> newUserMap;
    private Map<Id, User> oldUserMap;

    public UserTriggerHandler() {
        this.newUsers = (List<User>) Trigger.new;
        this.oldUsers = (List<User>) Trigger.old;
        this.newUserMap = (Map<Id, User>) Trigger.newMap;
        this.oldUserMap = (Map<Id, User>) Trigger.oldMap;
    }
    
    /*public override void beforeInsert() {
    } */

    /*public override void afterinsert() {
    }*/

    /*public override void beforeUpdate() {
    }*/
    
    public override void afterUpdate() { 
        UserHelper.updateUserPS(newUsers, oldUserMap);
    }

    /* public override void beforeDelete() {
        
    } */

    /* public override void afterDelete() {
        
    } */

    /* public override void afterUndelete() {
        
    } */
}