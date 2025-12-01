public with sharing class AssignPrimaryContactScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        // Enqueue the batch job
        Database.executeBatch(new AssignPrimaryContactBatchable());
  
    }
}
