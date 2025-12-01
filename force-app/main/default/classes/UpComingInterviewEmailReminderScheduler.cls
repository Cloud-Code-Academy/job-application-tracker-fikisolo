public with sharing class UpComingInterviewEmailReminderScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {

        //Date tomorrow = Date.today().addDays(1);
        // Create an Interview/Event scheduled for  next weekday (tomorrow or the next Monday if weekend) since we can't create event on weekends
        Date targetDay = EventHelper.nextWeekday(Date.today().addDays(1));
        DateTime startTime = DateTime.newInstance(targetDay, Time.newInstance(0,0,0,0));
        DateTime endTime = startTime.addDays(1);

        //get list of interviews scheduled for next day.
        List<Event> UpcomingEvents = [
            SELECT Id, OwnerId, WhoId, Who.Name, WhatId, What.Name, StartDateTime
            FROM Event 
            WHERE StartDateTime >= :startTime
            AND StartDateTime < :endTime
        ];

        if (!UpcomingEvents.isEmpty()) {
            System.enqueueJob(new UpComingnterviewEmailReminderQueueable(UpcomingEvents));
        }
        //UpComingInterviewEmailReminder.sendEmailReminder(upcomingEvents);
    }
}
