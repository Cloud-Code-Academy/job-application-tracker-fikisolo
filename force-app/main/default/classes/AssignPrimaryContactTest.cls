@IsTest
public with sharing class AssignPrimaryContactTest {
    @TestSetup
    static void setupTestData() {
        // Create 3 test Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= 3; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + i,
                Email = 'test' + i + '@example.com'
            ));
        }
        insert contacts;

        // Create a test Job Applications with no primary contact assigned
        Job_Application__c jobApp = new Job_Application__c(
                Name = 'Test Job ',
                Status__c = 'Saved',
                Company_Name__c = 'ABC',
                Job_Title__c = 'Salesforce Developer'
            );
        insert jobApp;

        // Create junction records (JobApplicationContact__c) linking contacts to the job app.
        List<JobApplicationContact__c> jobContacts = new List<JobApplicationContact__c>();
        jobContacts.add(new JobApplicationContact__c(
            Name = 'JobContact1',
            Job_Application__c = jobApp.Id,
            Contact__c = contacts[0].Id,
            Role__c = 'HM'
        ));
        jobContacts.add(new JobApplicationContact__c(
            Name = 'JobContact2',
            Job_Application__c = jobApp.Id,
            Contact__c = contacts[1].Id,
            Role__c = 'HM'
        ));
        jobContacts.add(new JobApplicationContact__c(
            Name = 'JobContact3',
            Job_Application__c = jobApp.Id,
            Contact__c = contacts[2].Id,
            Role__c = 'HM'
        ));
        insert jobContacts;
    }

    @IsTest
    static void testSetPrimaryContact() {
        // Retrieve the Job Applications
        List<Job_Application__c> jobs = [SELECT Id, Primary_Contact__c FROM Job_Application__c];

        // Call the method to set primary contact
        AssignPrimaryContact.setPrimaryContact(jobs);

        // Verify results
        List<Job_Application__c> updatedJobs = [SELECT Id, Primary_Contact__c FROM Job_Application__c];
        System.assertNotEquals(null, updatedJobs[0].Primary_Contact__c, 'Primary Contact should be set for Job');
        System.assertEquals(updatedJobs[0].Primary_Contact__c, [SELECT Contact__c FROM JobApplicationContact__c WHERE Job_Application__c = :updatedJobs[0].Id ORDER BY CreatedDate ASC LIMIT 1].Contact__c, 
                            'Primary Contact should match the first related contact');
    }
}