@IsTest
private class CreateJobStatusTasksTest {
    
    // Utility method to create a test Job Application
    private static Job_Application__c createJobApplication(String status) {
        Job_Application__c job = new Job_Application__c(
            Name = 'Test Job Application ' + status,
            Status__c = status,
            Company_Name__c = 'ABC',
            Job_Title__c = 'Salesforce Developer'
        );
        return job;
    }
    
    @IsTest
    static void testCreateSavedTasks() {
        Job_Application__c job = createJobApplication('Saved');
        Test.startTest();
        CreateJobStatusTasks.createSavedTasks(job.Id);
        Test.stopTest();
        
        List<Task> tasks = [SELECT Subject, WhatId, OwnerId, Status FROM Task WHERE WhatId = :job.Id];
        System.assertEquals(3, tasks.size(), 'Expected 3 tasks for Saved status');
        for (Task t : tasks) {
            System.assertEquals(job.Id, t.WhatId, 'Task should be linked to Job Application');
            System.assertEquals(UserInfo.getUserId(), t.OwnerId, 'Owner should be current user');
            System.assertEquals('Not Started', t.Status);
        }
    }
    
    @IsTest
    static void testCreateApplyingTasks() {
        Job_Application__c job = createJobApplication('Applying');
        Test.startTest();
        CreateJobStatusTasks.createApplyingTasks(job.Id);
        Test.stopTest();
        System.assertEquals(5, [SELECT COUNT() FROM Task WHERE WhatId = :job.Id]);
    }
    
    @IsTest
    static void testCreateAppliedTasks() {
        Job_Application__c job = createJobApplication('Applied');
        Test.startTest();
        CreateJobStatusTasks.createAppliedTasks(job.Id);
        Test.stopTest();
        System.assertEquals(4, [SELECT COUNT() FROM Task WHERE WhatId = :job.Id]);
    }
    
    @IsTest
    static void testCreateInterviewingTasks() {
        Job_Application__c job = createJobApplication('Interviewing');
        Test.startTest();
        CreateJobStatusTasks.createInterviewingTasks(job.Id);
        Test.stopTest();
        System.assertEquals(5, [SELECT COUNT() FROM Task WHERE WhatId = :job.Id]);
    }
    
    @IsTest
    static void testCreateNegotiatingTasks() {
        Job_Application__c job = createJobApplication('Negotiating');
        Test.startTest();
        CreateJobStatusTasks.createNegotiatingTasks(job.Id);
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM Task WHERE WhatId = :job.Id]);
    }
    
    @IsTest
    static void testCreateAcceptedTasks() {
        Job_Application__c job = createJobApplication('Accepted');
        Test.startTest();
        CreateJobStatusTasks.createAcceptedTasks(job.Id);
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM Task WHERE WhatId = :job.Id]);
    }
    
    @IsTest
    static void testCreateClosedTasks() {
        Job_Application__c job = createJobApplication('Closed');
        Test.startTest();
        CreateJobStatusTasks.createClosedTasks(job.Id);
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :job.Id]);
    }
}
