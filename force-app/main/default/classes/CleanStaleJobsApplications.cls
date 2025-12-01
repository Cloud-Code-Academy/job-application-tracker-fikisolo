public with sharing class CleanStaleJobsApplications implements Database.Batchable<sObject> {
    /*Checks if a job application is stale and moves the record status to closed. 
    Update the notes field that the job application was closed by an automated process.
    Stale Criteria:
    ●	Status is not Closed or Accepted
    ●	Follow up date 30 days old or more
    */
    
    private static final String JOB_APPLICATION_OBJECT = 'Job_Application__c';
    @testvisible
    private  static final String CLOSED_STATUS = 'Closed';
    @testvisible
    private static final String  STALE_JOB_NOTES = 'Job auto-closed due to 30 days of inactivity.';
    private  static final Integer NUM_OF_DAYS_OLD = 30;
    // Start method 
    public Database.QueryLocator start(Database.BatchableContext bc) {
       //query all jobs application that meet the criteria
       // exclude also records with null follow-up dates
        Date cutoffDate = Date.today().addDays(-NUM_OF_DAYS_OLD);
        return Database.getQueryLocator(
            'SELECT Id, Name FROM Job_Application__c '
            + ' WHERE Status__c NOT IN (\'Closed\',\'Accepted\')'
            + ' AND Follow_up_date__c != null'
            + ' AND Follow_up_date__c <= :cutoffDate'
        );
    }
        // Execute method 
    public void execute(Database.BatchableContext bc, List<Job_Application__c> scope) {

        //check that the scope isn't null before proceeding with any execute logic
        if (scope == null || scope.isEmpty()) {
            return;
        }
        
        for (Job_Application__c job : scope) {

            job.Status__c = CLOSED_STATUS;
            job.Notes__c = STALE_JOB_NOTES;
        }
        
        try {
             //Turn trigger off for batch update
            TriggerBypassControl.bypassJobApplicationTrigger = true;
            Database.SaveResult[] results = Database.update(scope, false);
            //enable trigger
            TriggerBypassControl.bypassJobApplicationTrigger = false; 

            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error err : results[i].getErrors()) {
                        String msg =
                            'Job_Application__c Id ' + scope[i].Id +
                            ' failed to update. StatusCode=' + String.valueOf(err.getStatusCode()) +
                            ', Message=' + err.getMessage();

                        // log error msg
                        System.debug(LoggingLevel.ERROR, 'CleanStaleJobsApplications error: ' + msg);
                    }
                }
            }
        } catch (Exception e) {
            // Catch any unexpected exceptions that occur before/around Database.update
            String msg = 'Unexpected exception in CleanStaleJobsApplications.execute: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, msg);
        }
    }
    // Finish method 
    public void finish(Database.BatchableContext bc) {
        // Post-processing logic
        System.debug('Batch processing to update status of stale Job\'s completed.');
    }
}