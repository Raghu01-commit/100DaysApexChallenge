public with sharing class AccountHelper {

    public static void sendNewTierAccountEmails(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){

        //Since we don't want to trigger emails to users when the test methods are executing we can prevent that by using the below method
        if(Test.isRunningTest()){
            return;
        }
        //I hardcoded the email values here but in general we get the emails to be dynamically sent based on the values in the records
        
        List<String> targetEmails = new List<String> {'test@gmail.com'};

        //Method to hold single email messages
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for(Account acc : newAccounts){

            if(acc.Loyalty_Tier__c != null && acc.Loyalty_Tier__c != oldAccountsMap.get(acc.Id).Loyalty_Tier__c){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(targetEmails);
                email.setSubject('Your Account Tier has changed from - ' + oldAccountsMap.get(acc.Id).Loyalty_Tier__c + ' to ' + acc.Loyalty_Tier__c);
                email.setPlainTextBody('Dear Customer,\n \n' + 
                'This is a notification to let you know that your account has been updated from - ' + oldAccountsMap.get(acc.Id).Loyalty_Tier__c + ' to ' + acc.Loyalty_Tier__c + '\n \n' +
                'Account Name: ' + acc.Name + '\n' +
                'Account Loyalty Tier: ' + acc.Loyalty_Tier__c + '\n' +
                'Latest Loyalty Points: ' + acc.Loyalty_Points__c );

                emailsToSend.add(email);
            }
            
            
        }
        if(!emailsToSend.isEmpty()){
            Messaging.sendEmail(emailsToSend);
        }

    }

    public static void updateAccountDescription(List<Account> newAccounts){
        for(Account acc : newAccounts){
            acc.Description = UserInfo.getName() + ' ' + Datetime.now();
        }
    }

    public static void createContacts(List<Account> newAccounts){
        List<Contact> contactsToBeCreated = new List<Contact>();
        for(Account acc : newAccounts){
            for(Integer i = 1; i <= 3; i++){
                Contact con = new Contact(LastName = acc.Name + ' - ' +'Contact '+i, AccountId = acc.Id);
                contactsToBeCreated.add(con);
            }
        }
        insert contactsToBeCreated;
    }
}