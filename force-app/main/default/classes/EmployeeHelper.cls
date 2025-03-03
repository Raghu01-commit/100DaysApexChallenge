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

        Map<Id, Decimal> employerToMaxSalaryMap = new Map<Id, Decimal>(); 
        Map<Id, Decimal> employerToMinSalaryMap = new Map<Id, Decimal>();

        List<Employer__c> employersToBeUpdated = new List<Employer__c>();
        //Aggregate result to get the Min, Max Salary for each employer
        if(!employerIds.isEmpty()){
            for(AggregateResult empAgg : [SELECT Employer__c employerId, MIN(Salary__c) minSal, MAX(Salary__c) maxSal
                                        FROM Employee__c 
                                        WHERE Employer__c IN :employerIds
                                        GROUP BY Employer__c]){
                employerToMaxSalaryMap.put((Id)empAgg.get('employerId'), (Decimal)empAgg.get('maxSal'));
                employerToMinSalaryMap.put((Id)empAgg.get('employerId'), (Decimal)empAgg.get('minSal'));                           
            }

            for(Id employerId : employerIds){
                Employer__c employer = new Employer__c (Id = employerId, 
                                                    Highest_Salary__c = employerToMaxSalaryMap.get(employerId),
                                                    Least_Salary__c = employerToMinSalaryMap.get(employerId));
                                                    
                employersToBeUpdated.add(employer);                                                                       
            }
        }

        if(!employersToBeUpdated.isEmpty()){
            update employersToBeUpdated;
        }
    }
}