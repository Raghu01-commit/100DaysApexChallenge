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
        OppLineItemDiscountHelper.updateOriginalAmount(newOppLineItems);
        OppLineItemDiscountHelper.calculateDiscount(newOppLineItems);
    }

    /* public override void beforeUpdate() {
        
    } */

    public override void afterUpdate() {
        OppLineItemDiscountHelper.updateOriginalAmount(newOppLineItems);
        OppLineItemDiscountHelper.calculateDiscount(newOppLineItems);
    }

    /* public override void beforeDelete() {
        
    } */

    public override void afterDelete() {
        OppLineItemDiscountHelper.updateOriginalAmount(oldOppLineItems);
        OppLineItemDiscountHelper.calculateDiscount(oldOppLineItems);
    }

    public override void afterUndelete() {
        OppLineItemDiscountHelper.updateOriginalAmount(newOppLineItems);
        OppLineItemDiscountHelper.calculateDiscount(newOppLineItems);
    }


}