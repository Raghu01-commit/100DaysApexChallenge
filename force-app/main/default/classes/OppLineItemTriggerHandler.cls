public with sharing class OppLineItemTriggerHandler extends TriggerHandler {
    List<OpportunityLineItem> newOppLineItems;
    List<OpportunityLineItem> oldOppLineItems;
    Map<Id, OpportunityLineItem> oldOppLineItemsMap;
    Map<Id, OpportunityLineItem> newOppLineItemsMap;
    public OppLineItemTriggerHandler() {
        this.newOppLineItems = (List<OpportunityLineItem>) Trigger.new;
        this.oldOppLineItems = (List<OpportunityLineItem>) Trigger.old;
        this.oldOppLineItemsMap = (Map<Id, OpportunityLineItem>) Trigger.oldMap;
        this.newOppLineItemsMap = (Map<Id, OpportunityLineItem>) Trigger.newMap;
    }

    /* public override void beforeInsert() {
        
    } */

    public override void afterinsert() {
        OppLineItemHelper.updateOriginalAmount(newOppLineItems);//Challenge 4
        OppLineItemHelper.calculateDiscount(newOppLineItems);//Challenge 4
        OppLineItemHelper.updateOppProdOnAccount(newOppLineItems);//Challenge 7
    }

    /* public override void beforeUpdate() {
        
    } */

    public override void afterUpdate() {
        OppLineItemHelper.updateOriginalAmount(newOppLineItems);//Challenge 4
        OppLineItemHelper.calculateDiscount(newOppLineItems);//Challenge 4
    }

    /* public override void beforeDelete() {
        
    } */

    public override void afterDelete() {
        OppLineItemHelper.updateOriginalAmount(oldOppLineItems);//Challenge 4
        OppLineItemHelper.calculateDiscount(oldOppLineItems);//Challenge 4
        OppLineItemHelper.updateOppProdOnAccount(oldOppLineItems);//Challenge 7
    }

    public override void afterUndelete() {
        OppLineItemHelper.updateOriginalAmount(newOppLineItems);//Challenge 4
        OppLineItemHelper.calculateDiscount(newOppLineItems);//Challenge 4
    }


}