public with sharing class AssignPrimaryContactBatchable implements Database.Batchable<SObject> {
    // Collect Records to Process 
    public Database.QueryLocator start(Database.BatchableContext bc) {
  
        // Query all Job Applications with no Primary Contact
        return Database.getQueryLocator( 'SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Primary_Contact__c = null');
    }

    // ===== EXECUTE: Logic to Run Per Scope =====
    public void execute(Database.BatchableContext bc, List<Job_Application__c> scope){

        // Call setPrimaryContact methods 
        if (!scope.isEmpty()) {
            AssignPrimaryContact.setPrimaryContact(scope);
        }
    }

    // ===== FINISH: Notification/Logging =====
    public void finish(Database.BatchableContext bc) {

        // Summary log
        System.debug(LoggingLevel.INFO, 'AssignPrimaryContactBatchable completed');

    }
}