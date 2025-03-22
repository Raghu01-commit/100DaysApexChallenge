public with sharing class EmployeeHelper {
    public static void updateMinAndMaxSalary(List<Employee__c> newEmployees, Map<Id, Employee__c> oldEmployeesMap){

        Set<Id> employerIds = new Set<Id>();

        //Loop to get the EmployerId of all the new employee records or the updated employee records where there is a change in the Employer or Salary
        for(Employee__c emp : newEmployees){
            if(oldEmployeesMap == null && emp.Employer__c != null){
                employerIds.add(emp.Employer__c);
            }
            else if(oldEmployeesMap != null && emp.Employer__c != null &&( (emp.Employer__c != oldEmployeesMap.get(emp.Id).Employer__c) || (emp.Salary__c != oldEmployeesMap.get(emp.Id).Salary__c))){
                employerIds.add(emp.Employer__c);
                employerIds.add(oldEmployeesMap.get(emp.Id).Employer__c);
            }
        }

        Map<Id, List<Decimal>> employerToSalaryMap = new Map<Id, List<Decimal>>();

        List<Employer__c> employersToBeUpdated = new List<Employer__c>();
        //Aggregate result to get the Min, Max Salary for each employer

        if(!employerIds.isEmpty()){
            for(AggregateResult empAgg : [SELECT Employer__c employerId, MIN(Salary__c) minSal, MAX(Salary__c) maxSal
                                        FROM Employee__c 
                                        WHERE Employer__c IN :employerIds
                                        GROUP BY Employer__c]){
                employerToSalaryMap.put((Id)empAgg.get('employerId'), new List<Decimal>{(Decimal)empAgg.get('maxSal'),(Decimal)empAgg.get('minSal')});                                                                                 
            }

            for(Id employerId : employerIds){
                Employer__c employer = new Employer__c (Id = employerId, 
                                                    Highest_Salary__c = employerToSalaryMap.get(employerId)[0],
                                                    Least_Salary__c = employerToSalaryMap.get(employerId)[1]);
                employersToBeUpdated.add(employer);                                                                       
            }
        }

        if(!employersToBeUpdated.isEmpty()){
            update employersToBeUpdated;
        }
    }
}