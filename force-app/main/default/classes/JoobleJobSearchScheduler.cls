public with sharing class JoobleJobSearchScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        try {
            // Call the method that performs the HTTP callout to get job application and upsert
            JoobleJobSearchCallout.getJobApplicationsCallout();
        } catch (Exception ex) {
            System.debug('Error in JoobleJobSearchScheduler: ' + ex.getMessage());
        }
    }
}
