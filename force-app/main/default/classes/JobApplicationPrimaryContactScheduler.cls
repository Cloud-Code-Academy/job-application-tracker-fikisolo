public with sharing class JobApplicationPrimaryContactScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        // Query all Job Applications with no Primary Contact
        List<Job_Application__c> jobsWithoutPrimary = [
            SELECT Id, Primary_Contact__c
            FROM Job_Application__c
            WHERE Primary_Contact__c = null
        ];

        // Call setPrimaryContact methods 
        if (!jobsWithoutPrimary.isEmpty()) {
            AssignPrimaryContact.setPrimaryContact(jobsWithoutPrimary);
        }
    }
}
