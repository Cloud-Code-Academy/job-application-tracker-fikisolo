// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

 //set primary contact
  List<Job_Application__c> jobs = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id = 'a01bm00001CF2nAAAT'];
 AssignPrimaryContact.setPrimaryContact(jobs);

 //check if interview reminder has been sent.
 UpComingInterviewEmailReminder.sendEmailReminder();
 List<EmailMessage> emailSent = [SELECT Id, Subject, ToAddress, CreatedDate FROM EmailMessage];
 System.debug(JSON.serializePretty(emailSent));

 // Run CleanStaleJobsApplications batch class
Database.executeBatch(new CleanStaleJobsApplications());

List<Job_Application__c> todaysJobs = [
    SELECT Id 
    FROM Job_Application__c 
    WHERE CreatedDate = TODAY
];

delete [SELECT count(Id) FROM Job_Application__c WHERE CreatedDate = TODAY];

//Get Jobs from Jooble API and insert into Salesforce

 JoobleJobSearchCallout.getJobApplicationsCallout();

  // Run AssignPrimaryContactBatchable batch class
Database.executeBatch(new AssignPrimaryContactBatchable());
//run UpComingInterviewEmailReminderScheduler immediately
UpComingInterviewEmailReminderScheduler emailScheduler = new UpComingInterviewEmailReminderScheduler();
emailScheduler.execute(null);
