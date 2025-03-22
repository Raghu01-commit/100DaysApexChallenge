public with sharing class ContactTriggerHandler extends TriggerHandler {
    
    private List<Contact> newContacts;
    private List<Contact> oldContacts;
    private Map<Id, Contact> oldContMap;
    private Map<Id, Contact> newContMap;

    public ContactTriggerHandler() {

        this.newContacts = (List<Contact>) Trigger.new;
        this.oldContacts = (List<Contact>) Trigger.old;
        this.newContMap = (Map<Id, Contact>) Trigger.newMap;
        this.oldContMap = (Map<Id, Contact>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        ContactHelper.enforceSinglePrimaryContact(newContacts, oldContMap); //Challenge 14(i)
    }

    public override void afterinsert() {
        ContactHelper.sumOfContactsAmount(newContacts, oldContMap);//Challenge 1
        ContactHelper.countOfActiveContacts(newContacts, oldContMap);//Challenge 6
    }

    public override void beforeUpdate() {
        ContactHelper.updateContactAddress(newContacts, oldContMap);//Challenge 8
        ContactHelper.enforceSinglePrimaryContact(newContacts, oldContMap); //Challenge 14(i)
    }

    public override void afterUpdate() {
        ContactHelper.sumOfContactsAmount(newContacts, oldContMap);//Challenge 1
        ContactHelper.countOfActiveContacts(newContacts, oldContMap);//Challenge 6
        ContactHelper.updatePrimaryContactOnOldAccount(newContacts, oldContMap); //Challenge 14(ii)
        
    }

    public override void beforeDelete() {
        ContactHelper.preventContactDeletion(oldContacts);//Challenge 2
    }

    public override void afterDelete() {
        ContactHelper.sumOfContactsAmount(oldContacts, oldContMap);//Challenge 1
        ContactHelper.countOfActiveContacts(oldContacts, oldContMap);//Challenge 6
        ContactHelper.updatePrimaryContact(oldContacts); //Challenge 14(iii)
    }

    public override void afterUndelete() {
        ContactHelper.sumOfContactsAmount(newContacts, oldContMap);//Challenge 1
        ContactHelper.countOfActiveContacts(newContacts, oldContMap);//Challenge 6
        ContactHelper.reevaluatePrimaryContact(newContacts); //Challenge 14(iv)
    }
}