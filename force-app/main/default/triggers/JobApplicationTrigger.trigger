trigger JobApplicationTrigger on Job_Application__c (before insert, before update, after insert, after update) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            TakeHomePayEstimationCal.calculatorTakeHomePay(Trigger.new, null);
        }
        when BEFORE_UPDATE {
             TakeHomePayEstimationCal.calculatorTakeHomePay(Trigger.new, Trigger.oldMap);
        }
        when AFTER_INSERT {
            CreateJobStatusTasks.createTasks(Trigger.new, null);
        }
        when AFTER_UPDATE {
            CreateJobStatusTasks.createTasks(Trigger.new, Trigger.oldMap);
        }
    }
 
}