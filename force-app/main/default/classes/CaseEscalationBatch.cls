//Challenge 17
public class CaseEscalationBatch implements Database.Batchable<sObject> {

    private List<Case> casesToUpdate = new List<Case>();
    private List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    private String supportManagerEmail = 'support.manager@company.com'; // Use Custom Label or Custom Metadata
    
    public Database.QueryLocator start(Database.BatchableContext BC) {

        /*This query returns any of the existing Cases with either CaseComments/EmailMessage records that are created after the SLA_Marked_Time__c(the time when the priority is updated because that's when the SLA Due Date is updated) and before the SLA_Due_Date__c field*/
        return Database.getQueryLocator('SELECT Id, SLA_Due_Date__c,SLA_Marked_Time__c,Status, OwnerId,' +
                                            '(SELECT Id FROM CaseComments' +
                                            'WHERE CreatedDate >= SLA_Marked_Time__c' +
                                            'AND CreatedDate < SLA_Due_Date__c),' +
                                            '(SELECT Id FROM EmailMessages' +
                                            'WHERE CreatedDate >= SLA_Marked_Time__c' +
                                            'AND CreatedDate < SLA_Due_Date__c)' +
                                        'FROM Case' +
                                        'WHERE Status NOT IN (\'Closed\', \'Escalated\') ' +
                                        'AND IsClosed = FALSE ' +
                                        'AND SLA_Due_Date__c != null'
                                        );
    }
    
    public void execute(Database.BatchableContext BC, List<Case> scope) {

        DateTime nowInPST = System.now().addHours(-8); //Converts to Standard PST time
        
        for (Case c : scope) {
            // Check if current time is past SLA due date
            if (nowInPST >= c.SLA_Due_Date__c) {
                // Check if no child records exist
                if (c.CaseComments.isEmpty() && c.EmailMessages.isEmpty()) {
                    // Update case status
                    c.Status = 'Escalated';
                    casesToUpdate.add(c);
                    
                    // Prepare escalation email
                    sendEscalationEmail(c);
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Update cases
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
        
        // Send emails
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
    
    private void sendEscalationEmail(Case c) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String>{supportManagerEmail});
        mail.setSubject('Case Escalated:: ' + c.CaseNumber);
        mail.setPlainTextBody(
            'Case ' + c.CaseNumber + ' has been escalated as there is no initial response given to the Case before SLA deadline.\n' +
            'SLA Due Date: ' + c.SLA_Due_Date__c.format() + '\n'
        );
        emailsToSend.add(mail);
    }
}
