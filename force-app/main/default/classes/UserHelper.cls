public with sharing class UserHelper {

    public static void updateUserPS(List<User> usersList, Map<Id, User> oldUsersMap){

        List<User> vipUsers = new List<User>();

        Map<Id, user> userWithRoleMap = new Map<Id, User>([SELECT Id, UserRoleId, UserRole.DeveloperName FROM User WHERE Id IN :usersList]);

        for(User usr : usersList){
            String userRole = userWithRoleMap.get(usr.Id).UserRole.DeveloperName;
            if(usr.UserRoleId != null && String.valueOf(usr.UserRoleId) != String.valueOf(oldUsersMap.get(usr.Id).UserRoleId) && userRole == 'VIP_Role'){
                vipUsers.add(usr);
            }
        }

        //Assign 'VIP PS' Permission Set to the User
        PermissionSet vipPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'VIP_PS' LIMIT 1];

        if (vipPermissionSet == null) {
            System.debug('Permission Set VIP PS not found!');
            return;
        }

        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();

        Map<Id, PermissionSetAssignment> userToPSAMap = new Map<Id, PermissionSetAssignment>();

        for(PermissionSetAssignment psa : [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :vipPermissionSet.Id AND AssigneeId IN : vipUsers]){
            userToPSAMap.put(psa.AssigneeId, psa);
        }

        Set<Id> userIds = new Set<Id>();
        // Collect the User IDs to later query Contacts
        for (User usr : vipUsers) {
            userIds.add(usr.Id);
            if(userToPSAMap.containsKey(usr.Id)){
                continue;
            }
            psaList.add(new PermissionSetAssignment(
                AssigneeId = usr.Id,
                PermissionSetId = vipPermissionSet.Id
            ));
        }
        // Insert Permission Set Assignments
        if (!psaList.isEmpty()) {
            insert psaList; // Permission Set assignment
        }

        if (!userIds.isEmpty()) {
            System.enqueueJob(new HandleVIPRoleAssignment(userIds)); // Call Queueable to handle the operations asynchronously
        }
    }
}