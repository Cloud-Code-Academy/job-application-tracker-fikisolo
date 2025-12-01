@IsTest
private with sharing class PreventDoubleBookingTest {
    @TestSetup
    static void setupData() {
        // Create a test user (owner of events)
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuser' + System.currentTimeMillis() + '@example.com'
        );
        insert u;

        // Choose the next weekday (tomorrow or the next Monday if weekend) since we can't create event on weekends
        Date targetDay = nextWeekday(Date.today().addDays(1));
        DateTime targetday10am = DateTime.newInstance(targetDay, Time.newInstance(10, 0, 0, 0));
        DateTime targetday11am = DateTime.newInstance(targetDay, Time.newInstance(11, 0, 0, 0));

        // Create an existing weekday event
        Event existingEvent = new Event(
            OwnerId = u.Id,
            StartDateTime = targetday10am, // Tomorrow 10 AM
            EndDateTime = targetday11am,   // Tomorrow 11 AM
            Subject = 'Existing Event'
        );
        insert existingEvent;
    }

    @IsTest
    private static void testNoConflictWeekday() {
    User u = [SELECT Id FROM User WHERE Email LIKE 'testuser%@example.com' LIMIT 1];
    
     // Choose the next weekday (tomorrow or the next Monday if weekend)
    Date targetDay = nextWeekday(Date.today().addDays(1));
    DateTime targetday12am = DateTime.newInstance(targetDay, Time.newInstance(12, 0, 0, 0));
    DateTime targetday13am = DateTime.newInstance(targetDay, Time.newInstance(13, 0, 0, 0));

    // New event with no conflict (after existing one)
    Event newEvent = new Event(
        OwnerId = u.Id,
        StartDateTime = targetday12am,
        EndDateTime = targetday13am,
        Subject = 'Non-conflicting Event'
    );

    Test.startTest();
    PreventDoubleBooking.checkDoubleBooking(
        new List<Event>{ newEvent },
        null
    );
    Test.stopTest();

    // Assert that there is no errors
    System.assertEquals(0, newEvent.getErrors().size(), 'Event should not have errors for non-conflicting time slot.');
    }
    @IsTest
    private static void testOverlapBooking() {
        User u = [SELECT Id FROM User WHERE Email LIKE 'testuser%@example.com' LIMIT 1];
        Event existingEvent = [SELECT Id, StartDateTime, EndDateTime FROM Event LIMIT 1];

        // Create overlapping event (starts 10:30 AM while existing is 10–11 AM)
        Event overlapEvent = new Event(
            OwnerId = u.Id,
            StartDateTime = existingEvent.StartDateTime.addMinutes(30),
            EndDateTime = existingEvent.EndDateTime.addHours(1),
            Subject = 'Overlapping Event'
        );

        Test.startTest();
        PreventDoubleBooking.checkDoubleBooking(
            new List<Event>{ overlapEvent },
            null
        );
        Test.stopTest();

        System.assert(overlapEvent.getErrors().size() > 0, 'Overlapping event should trigger error.');
        System.assertEquals(
            'You have interview scheduled that overlaps with this time.',
            overlapEvent.getErrors()[0].getMessage()
        );
    }
      // Helper: return the next weekday on/after the given date
    private static Date nextWeekday(Date d) {
        Date givenDate = d;

        // toStartOfWeek() returns the Sunday of that week
        // daysBetween() gives the date difference/offset between two dates in integer

        while (givenDate.toStartOfWeek().daysBetween(givenDate) == 0  // Sunday
                || givenDate.toStartOfWeek().daysBetween(givenDate) == 6) // Saturday
                {
                    givenDate = givenDate.addDays(1);
                }
        return givenDate;
    }

}
