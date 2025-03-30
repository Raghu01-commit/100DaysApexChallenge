//Challenge 20
public with sharing class ProductUpdateBulkEmailNotifications implements Queueable {

    private Integer offsetValue; //Need this variable to handle more records

    public ProductUpdateBulkEmailNotifications(Integer offset){
        this.offsetValue = offset;
    }

    public void execute(QueueableContext qc){
        //Fetch Customer who signedup for updates
        List<Contact> customers = [SELECT Id, FirstName, LastName, Email
                                    FROM Contact
                                    WHERE Subscribe_to_product_updates__c = true AND Email != null
                                    LIMIT 5000 OFFSET :offsetValue];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        if(!customers.isEmpty()){
            for(Contact c : customers){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('New Product Update');
                email.setToAddresses(new List<String>{c.Email});
                email.setPlainTextBody('Here is our new Latest Product');
                emails.add(email);
            }
        }

        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }

        //Chain another Queueable Job if more records exist
        if(customers.size() == 5000){
            system.enqueueJob(new ProductUpdateBulkEmailNotifications(offsetValue + 5000), 5);
        }
    }
}


//Now add this Apex Jobs by running this code in Execute Anonymous window
//System.enqueueJob(new ProductUpdateBulkEmailNotifications(0)); 