public with sharing class OppLineItemDiscountHelper {
    public OppLineItemDiscountHelper() {

    }

    public static void updateOriginalAmount(List<OpportunityLineItem> oppLineItems){

        Set<Id> oppIds = new Set<Id>();
        
        for(OpportunityLineItem oppLineItem : oppLineItems){
            if(oppLineItem.OpportunityId != null){
                oppIds.add(oppLineItem.OpportunityId);
        }

        Map<Id, Decimal> oppOrigAmountMap = new Map<Id, Decimal>();

        if(!oppIds.isEmpty()){

            for(AggregateResult agg : [SELECT OpportunityId, SUM(Subtotal) totalAmount 
                                    FROM OpportunityLineItem
                                    WHERE OpportunityId IN :oppIds
                                    GROUP BY OpportunityId]){

            oppOrigAmountMap.put((Id)agg.get('OpportunityId'), (Decimal)agg.get('totalAmount'));
            }
        }
        

    List<Opportunity> oppsToBeUpdated = new List<Opportunity>();

    for(Id oppId : oppIds){
        Opportunity opp = new Opportunity(Id = oppId, Original_Amount__c = oppOrigAmountMap.get(oppId) != null ? oppOrigAmountMap.get(oppId) : 0);
        oppsToBeUpdated.add(opp);
    }

    if(!oppsToBeUpdated.isEmpty()){
        update oppsToBeUpdated;
    }
    }
    }

    private static Boolean isAlreadyUpdated = false;

    public static void calculateDiscount(List<OpportunityLineItem> oppLineItems) {

        //Prevent recursion
        if (isAlreadyUpdated) {
            return;  // Exit if already updated
        } 

        isAlreadyUpdated = true; // Mark as updated to prevent infinite loop


        //Set to query for existing discounts
        Set<Id> oppIds = new Set<Id>();

        for(OpportunityLineItem oppLineItem : oppLineItems){
            if(oppLineItem.OpportunityId != null){
                oppIds.add(oppLineItem.OpportunityId);
        }
    }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Original_Amount__c FROM Opportunity WHERE Id IN :oppIds]);

        // List to hold records for explicit update
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();

        for(OpportunityLineItem oli : oppLineItems){
            if(oppMap.containsKey(oli.OpportunityId)){
                Opportunity opp = oppMap.get(oli.OpportunityId);
                Decimal discount = 0;

                if(opp.Original_Amount__c > 200000){
                    discount = 10;
                } else if(opp.Original_Amount__c >= 50000 && opp.Original_Amount__c < 200000){
                    discount = 5;
                }

                //Create a new instance to update

                OpportunityLineItem updatedOli = new OpportunityLineItem(Id = oli.Id, Discount = discount);
                //oli.Discount = discount;
                //OpportunityLineItemsToUpdate.add(oli););
                oliToUpdate.add(updatedOli);
                
            }

        }

            // Perform DML update outside loop
            if (!oliToUpdate.isEmpty()) {
            update oliToUpdate;  
            }

            isAlreadyUpdated = false;  // Reset flag after update to allow for next update
    }

}