public with sharing class CleanStaleJobsApplications implements Database.Batchable<sObject> {
    /*Checks if a job application is stale and moves the record status to closed. 
    Update the notes field that the job application was closed by an automated process.
    Stale Criteria:
    ●	Status is not Closed or Accepted
    ●	Follow up date 30 days old or more
    */
    // Start method 
    public Database.QueryLocator start(Database.BatchableContext bc) {
       //query all jobs application that meet the criteria
        Date cutoffDate = Date.today().addDays(-30);
        return Database.getQueryLocator(
            'SELECT Id, Name FROM Job_Application__c '
            + ' WHERE Status__c NOT IN (\'Closed\',\'Accepted\')'
            + ' AND Follow_up_date__c <= :cutoffDate'
        );
    }
        // Execute method 
    public void execute(Database.BatchableContext bc, List<Job_Application__c> staledjobs) {
        
        for (Job_Application__c job : staledjobs) {

            job.Status__c = 'Closed';
            job.Notes__c = 'Job auto-closed due to 30 days of inactivity.';
        }
        
        if (!staledjobs.isEmpty()) {
            update staledjobs;
        }
    }

    // Finish method 
    public void finish(Database.BatchableContext bc) {
        // Post-processing logic
        System.debug('Batch processing to update status of stale Job\'s completed.');
    }
}