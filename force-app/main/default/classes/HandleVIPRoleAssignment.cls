public class HandleVIPRoleAssignment implements Queueable {
    private Set<Id> userIds;

    public HandleVIPRoleAssignment(Set<Id> userIds) {
        this.userIds = userIds;
    }

    public void execute(QueueableContext context) {
        Set<Id> assignedUserIds = new Set<Id>();
        // Fetch Contacts related to these Users
        List<Contact> relatedContacts = [SELECT Id, VIP__c, Assigned_User__c FROM Contact WHERE Assigned_User__c IN :userIds];

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact c : relatedContacts) {
            contactMap.put(c.Assigned_User__c, c);
        }
        // Create or update Contact records based on the related User's Role
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactsToInsert = new List<Contact>();

        for (User usr : [SELECT Id, Email, Name FROM USER WHERE Id IN :userIds]) {
            // Check if the user has an associated contact
            Contact relatedContact = contactMap.get(usr.Id);
            if (relatedContact != null) {

                // If related contact exists, update VIP__c
                relatedContact.VIP__c = true;
                contactsToUpdate.add(relatedContact);
            } else {
                // If no related contact, create a new one
                contactsToInsert.add(new Contact(
                    LastName = 'VIP User - ' + usr.Name,
                    FirstName = 'VIP',
                    Email = usr.Email,
                    Assigned_User__c = usr.Id, // Link to User
                    VIP__c = true // Set VIP__c field to true
                ));
            }
        }

        // Insert new contacts if any
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }

        // Update existing contacts if any
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}