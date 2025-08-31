public with sharing class AssignPrimaryContact {
   /* 
    Sets the primary contact on the job application if the primary contact is null 
    and there is at least one related contact. 
    Assign the first contact available in the contact-related list to primary contact
    */
    public static void setPrimaryContact(List<Job_Application__c> JobList) {
        //set of job Id's with null Primary_Contact__c
        Set<Id> jobIds = new Set<Id>();
        for (Job_Application__c job : JobList) {
            if (job.Primary_Contact__c == null) {
                jobIds.add(job.Id);
            }
        }

        if (jobIds.isEmpty()) return;
        //Get contact-related list for Job applications that don't have primary contact assigned
        List<JobApplicationContact__c> JobAppContactsList = [
                SELECT Job_Application__c, Contact__c 
                FROM JobApplicationContact__c 
                WHERE Job_Application__c IN :jobIds
                ORDER BY CreatedDate ASC];

        //Map job IDs to first contact found
        Map<Id, Id> JobIdToContIdMap = new Map<Id, Id>();
        //Put the first contact found for the job to the Map
        for (JobApplicationContact__c jobCont : JobAppContactsList) {
            if (!JobIdToContIdMap.containsKey(jobCont.Job_Application__c)) {
                JobIdToContIdMap.put(jobCont.Job_Application__c, jobCont.Contact__c); 
            }
        }
        List<Job_Application__c> jobAppToUpdate = new List<Job_Application__c>();
        for (Job_Application__c jobApp : JobList) {
            if (jobApp.Primary_Contact__c == null && jobIdToContIdMap.containsKey(jobApp.Id)) {
                jobApp.Primary_Contact__c = JobIdToContIdMap.get(jobApp.Id);
                jobAppToUpdate.add(jobApp);
            }
        }

        if(!jobAppToUpdate.isEmpty()) {
           update jobAppToUpdate;
        }
    }
}