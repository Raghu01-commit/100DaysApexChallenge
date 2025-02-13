trigger OppLineItemTrigger on OpportunityLineItem (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new OppLineItemTriggerHandler().run();
}