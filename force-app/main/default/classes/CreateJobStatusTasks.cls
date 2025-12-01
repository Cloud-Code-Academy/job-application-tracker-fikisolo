public with sharing class CreateJobStatusTasks {
    /* Auto generate tasks for each step in the application process.
       Generic method "createTasksForCurrentUser" used to create tasks for the current user.
    */
    public static void createTasks(List<Job_Application__c> jobApp, Map<Id,Job_Application__c> oldJobApp) {
        //add null check for input parameters 
        if (jobApp == null || jobApp.isEmpty()){
            return;
        }

        for (Job_Application__c job : jobApp) {
            Job_Application__c oldJob = (oldJobApp != null) ? oldJobApp.get(job.Id) : null;

            if (oldJobApp == null || (oldJobApp != null && job.Status__c != null && job.Status__c != oldJob.Status__c)) {
                switch on job.Status__c {
                    when 'Saved' {
                        createSavedTasks(job.Id);
                    }
                    when 'Applying' {
                        createApplyingTasks(job.Id);
                    }
                    when 'Applied' {
                        createAppliedTasks(job.Id);
                    }
                    when 'Interviewing' {
                        createInterviewingTasks(job.Id);
                    }
                    when 'Negotiating' {
                        createNegotiatingTasks(job.Id);
                    }
                    when 'Accepted' {
                        createAcceptedTasks(job.Id);
                    }
                    when 'Closed' {
                        createClosedTasks(job.Id);
                    }
                    when else {
                       job.addError('Invalid status value provided');
                    }
                }
            }
        }
    }
    /*
      Generic method to insert tasks for the current user.
    */
    private static void createTasksForCurrentUser(List<String> subjects, Integer dueInDays, Id jobId) {
        List<Task> tasks = new List<Task>();

        for (String subj : subjects) {
            tasks.add(new Task(
                Subject = subj,
                ActivityDate = Date.today().addDays(dueInDays),
                Priority = 'Normal',
                WhatId = jobId,
                OwnerId = UserInfo.getUserId(),
                Status = 'Not Started'
            ));
        }

        if (!tasks.isEmpty()) {
            try {
                    insert tasks;
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR,
                        '❗ Task insert failed — ' + e.getMessage()
                    );
                }
        }
    }
    // SAVED
    @TestVisible
    private static void createSavedTasks(Id jobId) {
        createTasksForCurrentUser(new List<String>{
            'Check if the job description aligns with your interests and values',
            'Review the highlighted skills to see if the role is a good fit',
            'Research the company or role and mark your excitement level'
        }, 1, jobId);
    }

    // APPLYING
    @TestVisible
    private static void createApplyingTasks(Id jobId) {
        createTasksForCurrentUser(new List<String>{
            'Find and research someone who works at the company and add them as a contact',
            'Set up an informational interview to learn more about the role/company',
            'Identify potential referrals to help get your application on the top of the pile',
            'Customize your work achievements using the job description keywords',
            'Submit your application on the company website if possible'
        }, 2, jobId);
    }

    // APPLIED
    @TestVisible
    private static void createAppliedTasks(Id jobId) {
        createTasksForCurrentUser(new List<String>{
            'Reach out to the hiring manager or recruiter',
            'Follow up on your application via email weekly',
            'Continue identifying and saving similar job opportunities',
            'Set up weekly networking calls to explore similar companies/roles'
        }, 2, jobId);
    }

    // INTERVIEWING
    @TestVisible
    private static void createInterviewingTasks(Id jobId) {
        createTasksForCurrentUser(new List<String>{
            'Prepare your blurb or “tell me about yourself” response',
            'Practice answering behavioral interview questions',
            'Research the company and your interviewers',
            'Set up your virtual interview space and test your tech',
            'Send thank you emails within 24 hours'
        }, 2, jobId);
    }

    // NEGOTIATING
    @TestVisible
    private static void createNegotiatingTasks(Id jobId) {
        createTasksForCurrentUser(new List<String>{
            'Research your market value and know your numbers',
            'Prepare your negotiation scripts',
            'Evaluate your offer and decline or accept'
        }, 2, jobId);
    }

    // ACCEPTED
    @TestVisible
    private static void createAcceptedTasks(Id jobId) {
        createTasksForCurrentUser(new List<String>{
            'Plan your resignation if applicable',
            'Take some time to relax and recharge',
            'Prepare for your first day of onboarding'
        }, 3, jobId);
    }

    // CLOSED
    @TestVisible
    private static void createClosedTasks(Id jobId) {
        createTasksForCurrentUser(new List<String>{
            'Send a follow-up email thanking the interviewer and asking for feedback',
            'Review your notes and reflect on areas of improvement'
        }, 1, jobId);
    }

}
