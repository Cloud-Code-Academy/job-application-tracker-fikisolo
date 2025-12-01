public with sharing class AssignPrimaryContact {
   /* 
    Sets the primary contact on the job application if the primary contact is null 
    and there is at least one related contact. 
    Assign the first contact available in the contact-related list to primary contact
      - uses partial success DML 
      - logs failures but does not stop execution
    */
    public static void setPrimaryContact(List<Job_Application__c> jobList) {
        // Returning early for null or empty input
        if (jobList == null || jobList.isEmpty()) {
            return;
        }
        //set of job Id's with null Primary_Contact__c
        Set<Id> jobIds = new Set<Id>();
        for (Job_Application__c job : jobList) {
            if (job == null || job.Primary_Contact__c != null) {
                continue; 
            }
            jobIds.add(job.Id);
        }

        if (jobIds.isEmpty()) {
            return;
        }
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
            //since the SOQL guarantees non-null jobCont and Job_Application__c, you could even drop this null check entirely unless you’re being ultra-defensive.
            if (jobCont == null || jobCont.Job_Application__c == null || jobCont.Contact__c == null) {
                continue;
            }
            if (!JobIdToContIdMap.containsKey(jobCont.Job_Application__c)) {
                JobIdToContIdMap.put(jobCont.Job_Application__c, jobCont.Contact__c); 
            }
        }
        List<Job_Application__c> jobAppToUpdate = new List<Job_Application__c>();
        for (Job_Application__c jobApp : jobList) {
            //Check jobApp is not null before trying to access any of its fields.
            //   // skip null records or records that already have a primary contact
            if (jobApp == null || jobApp.Id == null || jobApp.Primary_Contact__c != null) {
                continue;
            }
  
            if (!JobIdToContIdMap.containsKey(jobApp.Id)) {
                continue;
            }
            jobApp.Primary_Contact__c = JobIdToContIdMap.get(jobApp.Id);
            jobAppToUpdate.add(jobApp);
        }

        if(jobAppToUpdate.isEmpty()) {
            System.debug(LoggingLevel.INFO, 'No Job Applications qualified to update with a primary contact.');
            return;
        }

        // Partial update
          //Turn trigger off for batch update
        TriggerBypassControl.bypassJobApplicationTrigger = true;
        Database.SaveResult[] results = Database.update(jobAppToUpdate, false);
          //Turn trigger off for batch update
        TriggerBypassControl.bypassJobApplicationTrigger = false;
        
        Integer success = 0, failure = 0;

        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                success++;
            } else {
                failure++;
                for (Database.Error err : results[i].getErrors()) {
                    System.debug(LoggingLevel.ERROR,
                        'Failed to update Job_Application__c with primary contact ' + jobAppToUpdate[i].Id +
                        ' — ' + err.getMessage()
                    );
                }
            }
        }

        // Summary log
        System.debug(LoggingLevel.INFO, 'AssignPrimaryContact completed — Success: ' + success + ', Failed: ' + failure);
    }
}