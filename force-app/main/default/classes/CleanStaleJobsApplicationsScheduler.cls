public with sharing class CleanStaleJobsApplicationsScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Run CleanStaleJobsApplications batch class
        Database.executeBatch(new CleanStaleJobsApplications());
    }
}
