public with sharing class UpComingInterviewEmailReminderScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        UpComingInterviewEmailReminder.sendEmailReminder();
    }
}
