public with sharing class UpComingnterviewEmailReminderQueueable implements Queueable {

private List<Event> upcomingEvents;

    public UpComingnterviewEmailReminderQueueable(List<Event> upcomingEvents) {
        this.upcomingEvents = upcomingEvents;
    }

    public void execute(QueueableContext qc) {

        if (upcomingEvents == null || upcomingEvents.isEmpty()) {
            return;
        }

        // Build a chunk of up to 10 events
        List<Event> currentEvents = new List<Event>();
        //So the number of iterations adjusts to the actual remaining list length.
        //example If list has 3 records → chunkSize = 3 or If list has 10 or more → chunkSize = 10
        //This prevents out-of-bounds errors and ensures we never try to pull more items than exist. 
   
        Integer chunkSize = Math.min(10, upcomingEvents.size());

        // Take from the front to avoid index-shift problems
        for (Integer i = 0; i < chunkSize; i++) {
            currentEvents.add(upcomingEvents.remove(0));
        }

        // Send emails only for this chunk (<= 10)
        UpComingInterviewEmailReminder.sendEmailReminder(currentEvents);

        // If any events remain, chain another queueable
        if (!upcomingEvents.isEmpty()) {
            System.enqueueJob(new UpComingnterviewEmailReminderQueueable(upcomingEvents));
        }
    }
}