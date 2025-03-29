//Challenge 17
public with sharing class CaseEscalationBatchSchedulable implements Schedulable {
    public void execute(SchedulableContext sc){
        CaseEscalationBatch cb = new CaseEscalationBatch();
    }
}


//Schedule this by using a CRON expression
//If you are trying to update is already scheduled and has pending or in-progress jobs always remember that Salesforce does not allow 
//modifications to a Schedulable class while it has active scheduled jobs.
/*
String cronExpression = '0 0 * * * ?';
System.schedule('Case Escalation Hourly Batch Job', cronExpression, new CaseEscalationBatchSchedulable());
*/