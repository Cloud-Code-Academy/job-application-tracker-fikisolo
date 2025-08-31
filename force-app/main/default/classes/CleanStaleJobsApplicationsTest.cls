@isTest
private with sharing class CleanStaleJobsApplicationsTest {

    @testSetup
    static void setupTestData() {
        List<Job_Application__c> jobs = new List<Job_Application__c>();

        // Stale job application (older than 30 days & status not Closed/Accepted)
        jobs.add(new Job_Application__c(
            Name = 'Stale Job',
            Status__c = 'Saved',
            Company_Name__c = 'ABC',
            Job_Title__c = 'Salesforce Developer',
            Follow_up_date__c = Date.today().addDays(-31)
        ));

        // Not stale (Follow-up date within 30 days)
        jobs.add(new Job_Application__c(
            Name = 'Recent Job',
            Status__c = 'Saved',
            Company_Name__c = 'ABC',
            Job_Title__c = 'Salesforce Developer',
            Follow_up_date__c = Date.today().addDays(-5)
        ));

        // Already closed
        jobs.add(new Job_Application__c(
            Name = 'Closed Job',
            Status__c = 'Closed',
            Company_Name__c = 'ABC',
            Job_Title__c = 'Salesforce Developer',
            Follow_up_date__c = Date.today().addDays(-40)
        ));

        insert jobs;
    }

    @isTest
    static void testBatchUpdatesStaleJobs() {
        // Run batch
        Test.startTest();
        Database.executeBatch(new CleanStaleJobsApplications(), 50);
        Test.stopTest();

        // Query jobs again
        List<Job_Application__c> results = [
            SELECT Id, Name, Status__c, Notes__c 
            FROM Job_Application__c
        ];

        // Assertions
        for (Job_Application__c job : results) {
            if (job.Name == 'Stale Job') {
                System.assertEquals('Closed', job.Status__c, 'Stale job should be closed');
                System.assertEquals('Job auto-closed due to 30 days of inactivity.', job.Notes__c);
            } 
            else if (job.Name == 'Recent Job') {
                System.assertEquals('Saved', job.Status__c, 'Recent job should not be updated');
                System.assertNotEquals('Job auto-closed due to 30 days of inactivity.', job.Notes__c, 'Recent job notes should remain empty');
            }
            else if (job.Name == 'Closed Job') {
                System.assertEquals('Closed', job.Status__c, 'Already closed job should remain closed');
            }
        }
    }
}
