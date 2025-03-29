//Challenge 19
public with sharing class ScheduleQuarterlyDiscounts implements Schedulable {
    public void execute(SchedulableContext sc){
        QuarterlyDiscountBatch qdb = new QuarterlyDiscountBatch();
        // execute the batch
        Database.executeBatch(qdb);
        
    }
    
}


//To schedule this Batch Execution to run at every quarter run this below code one time so that a Scheduled Apex Job is created in org

//System.schedule('Quarterly Discount Update', '0 0 12 1 JAN,APR,JUL,OCT ? *', new ScheduleQuarterlyDiscounts());

