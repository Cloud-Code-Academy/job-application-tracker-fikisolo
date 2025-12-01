@IsTest
private with sharing class UpComingInterviewEmailReminderTest {

    @TestSetup
    private static void setupTestData() {
        // Create a test user to be the owner of the Event
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        //create a job application
                // Create a test Job Applications with no primary contact assigned
        Job_Application__c jobApp = new Job_Application__c(
                Name = 'Salesforce Developer at ABC',
                Status__c = 'Saved',
                Company_Name__c = 'ABC',
                Job_Title__c = 'Salesforce Developer'
            );
        insert jobApp;

        // Create a test Contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Smith',
            Email = 'john.smith@example.com'
        );
        insert testContact;

        // Create an Interview/Event scheduled for  next weekday (tomorrow or the next Monday if weekend) since we can't create event on weekends
        Date targetDay = EventHelper.nextWeekday(Date.today().addDays(1));
        
        Event interviewEvent = new Event(
            OwnerId = testUser.Id,
            WhoId = testContact.Id,
            WhatId = jobApp.Id,
            Subject = 'Interview',
            StartDateTime = DateTime.newInstance(targetDay, Time.newInstance(10,0,0,0)),
            EndDateTime = DateTime.newInstance(targetDay, Time.newInstance(11,0,0,0)),
            IsAllDayEvent = false,
            ActivityDate = targetDay
        );
        insert interviewEvent;
    }

    @IsTest
    private static void testSendEmailReminder_Positive() {

        List<Event> upcomingEvents = [
            SELECT Id, OwnerId, WhoId, Who.Name, WhatId, What.Name, StartDateTime
            FROM Event 
        ];

        Test.startTest();
        // Call the method
        UpComingInterviewEmailReminder.sendEmailReminder(upcomingEvents);
        Test.stopTest();

        // Verify that EmailMessage records are created
        List<EmailMessage> emails = [SELECT Id, Subject, ToAddress FROM EmailMessage];
        System.assert(emails.size() > 0, 'At least one email should be generated');
        System.assertEquals('You have upcoming interview tomorrow', emails[0].Subject);
    }

    @IsTest
    private static void testSendEmailReminder_NoEvents() {
        // Delete all Events to test negative scenario
        delete [SELECT Id FROM Event];

        Test.startTest();
        // Call the method, should not throw errors
        UpComingInterviewEmailReminder.sendEmailReminder(new List<Event>());
        Test.stopTest();

        // Verify no EmailMessage created
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage];
        System.assertEquals(0, emails.size(), 'No emails should be generated when no events exist');
    }
}
