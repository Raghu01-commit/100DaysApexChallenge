@isTest
public class ActiveContactsCountTest {
    
    @TestSetup
    static void makeData(){
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 3; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert testAccounts;
        
        // Create test contacts
        List<Contact> testContacts = new List<Contact>();
        for(Account acc : testAccounts) {
            testContacts.add(new Contact(LastName = 'Test Contact 1', AccountId = acc.Id, Active__c = true));
            testContacts.add(new Contact(LastName = 'Test Contact 2', AccountId = acc.Id, Active__c = false));
        }
        insert testContacts;
    }
    
    @isTest
    static void testInsertContacts() {
        Test.startTest();
        Contact newContact = new Contact(LastName = 'New Active Contact', AccountId = [SELECT Id FROM Account LIMIT 1].Id, Active__c = true);
        insert newContact;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Active_Contacts_Count__c FROM Account WHERE Id = :newContact.AccountId];
        System.assertEquals(2, updatedAccount.Active_Contacts_Count__c, 'Active contacts count should be 2 after inserting a new active contact');
    }
    
    @isTest
    static void testUpdateContacts() {
        Contact contactToUpdate = [SELECT Id, Active__c, AccountId FROM Contact WHERE Active__c = false LIMIT 1];
        Account originalAccount = [SELECT Id FROM Account WHERE Id != :contactToUpdate.AccountId LIMIT 1];
        
        Test.startTest();
        contactToUpdate.Active__c = true;
        contactToUpdate.AccountId = originalAccount.Id;
        update contactToUpdate;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Active_Contacts_Count__c FROM Account WHERE Id = :originalAccount.Id];
        System.assertEquals(2, updatedAccount.Active_Contacts_Count__c, 'Active contacts count should be 2 after updating a contact to active');
    }
    
    @isTest
    static void testDeleteContacts() {
        Contact contactToDelete = [SELECT Id, AccountId FROM Contact WHERE Active__c = true LIMIT 1];
        Id accountId = contactToDelete.AccountId;
        
        Test.startTest();
        delete contactToDelete;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Active_Contacts_Count__c FROM Account WHERE Id = :accountId];
        System.assertEquals(0, updatedAccount.Active_Contacts_Count__c, 'Active contacts count should be 0 after deleting the only active contact');
    }
    
    @isTest
    static void testUndeleteContacts() {
        Contact contactToUndelete = [SELECT Id, AccountId FROM Contact WHERE Active__c = true LIMIT 1];
        Id accountId = contactToUndelete.AccountId;
        delete contactToUndelete;
        
        Test.startTest();
        undelete contactToUndelete;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Active_Contacts_Count__c FROM Account WHERE Id = :accountId];
        System.assertEquals(1, updatedAccount.Active_Contacts_Count__c, 'Active contacts count should be 1 after undeleting an active contact');
    }
}
