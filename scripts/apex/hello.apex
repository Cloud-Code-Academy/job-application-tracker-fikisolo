// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

//Get Jobs from Jooble API and insert into Salesforce

 JoobleJobSearchCallout.getJobApplicationsCallout();

 //set primary contact
  List<Job_Application__c> jobs = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id = 'a01bm0000187iyUAAQ'];
 AssignPrimaryContact.setPrimaryContact(jobs);
