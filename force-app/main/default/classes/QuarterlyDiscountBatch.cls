//Challenge 19
public with sharing class QuarterlyDiscountBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private Decimal totalRevenueProcessed = 0;
    private Decimal totalDiscount = 0;
    private Integer numOfProcessedCustomers = 0;

    public Database.QueryLocator start(database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Total_Purchase__c, Discount__c FROM Account WHERE Total_Purchase__c > 0'); //Assuming that Total Purchase of all Accounts is reset to zero at every quarter and the data is archived for future use.
    }

    public void execute(Database.BatchableContext bc, List<Account> accList){

        List<Account> accountsToUpdate = new List<Account>();
        
        for(Account acc : accList){
            Decimal totalPurchase = acc.Total_Purchase__c;
            Decimal discount = 0;

            if(totalPurchase > 100000){
                discount = 20;
            }
            else if(totalPurchase > 50000){
                discount = 15;
            }
            else if(totalPurchase > 10000){
                discount = 10;
            }
            else {
                discount = 5;
            }

            acc.Discount__c = discount;
            accountsToUpdate.add(acc);

            //Stateful will carry the variables across the batches
            totalRevenueProcessed += totalPurchase;
            totalDiscount =+ discount;
            numOfProcessedCustomers++;
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc){
        Decimal avgDiscount = numOfProcessedCustomers > 0 ? (totalDiscount/numOfProcessedCustomers) : 0;

        System.debug('🚀 Total Revenue Processed: ' + totalRevenueProcessed);
        System.debug('📊 Total Accounts Processed: ' + numOfProcessedCustomers);
        System.debug('⭐ Average Discount Applied: ' + avgDiscount + '%');
    }
}