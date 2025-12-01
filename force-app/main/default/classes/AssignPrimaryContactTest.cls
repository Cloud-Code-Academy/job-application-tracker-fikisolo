@IsTest
private with sharing class AssignPrimaryContactTest {
    //Test classes should be private unless they are being used as test data factories for shared data setup across multiple other test classes.
    @TestSetup
    private static void setupTestData() {
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
    private static void testSetPrimaryContact() {
        // Retrieve the Job Applications
        List<Job_Application__c> jobs = [SELECT Id, Primary_Contact__c FROM Job_Application__c];

        // Call the method to set primary contact
        /*The method being tested should be called from within a test context using Test.startTest() and Test.stopTest()
        This is important for several reasons, but mainly to clearly define the method under test and 
        provide a fresh set of governor limits for the test transaction.*/
        Test.startTest();
        AssignPrimaryContact.setPrimaryContact(jobs);
        Test.stopTest();
        

        // Verify results
        List<Job_Application__c> updatedJobs = [SELECT Id, Primary_Contact__c FROM Job_Application__c];
        System.assertNotEquals(null, updatedJobs[0].Primary_Contact__c, 'Primary Contact should be set for Job');
        System.assertEquals(updatedJobs[0].Primary_Contact__c, [SELECT Contact__c FROM JobApplicationContact__c WHERE Job_Application__c = :updatedJobs[0].Id ORDER BY CreatedDate ASC LIMIT 1].Contact__c, 
                            'Primary Contact should match the first related contact');
    }
}