public with sharing class TakeHomePayEstimationCal {

    final static Decimal FED_INCOME_TAX_RATE = 0.21;
    final static Decimal SOCIAL_SECURITY_TAX_RATE = 0.062;
    final static Decimal MEDICARE_WITHHOLDING_RATE = 0.0145;
    final static Integer NUMBER_OF_MONTHS_IN_YEAR = 12;

    public static void calculatorTakeHomePay(List<Job_Application__c> jobApp, Map<Id,Job_Application__c> oldJobApp) {


        for (Job_Application__c job : jobApp) {

             //if salary is missing or zero, reset fields and skip
            if (job.Salary__c == null || job.Salary__c == 0) {
                job.Fed_Income_Tax__c       = null;
                job.Social_Security_Tax__c  = null;
                job.Medicare_Withholding__c = null;
                job.AnnualTakeHome__c       = null;
                job.Monthly_Income__c       = null;
                continue;
            }

            Job_Application__c oldJob = (oldJobApp != null) ? oldJobApp.get(job.Id) : null;

            if (oldJobApp == null || (oldJobApp != null && job.Salary__c != oldJob.Salary__c)) {
                job.Fed_Income_Tax__c = calculatorFedIncomeTax(job.Salary__c);
                job.Social_Security_Tax__c = socialSecurityTax(job.Salary__c);
                job.Medicare_Withholding__c = medicareWithholding(job.Salary__c);
                job.AnnualTakeHome__c = job.Salary__c - (job.Fed_Income_Tax__c + job.Social_Security_Tax__c
                                                        + job.Medicare_Withholding__c);
                job.Monthly_Income__c = calculatorMonthlyIncome(job.AnnualTakeHome__c);
            }
        }
    }
    private static Decimal calculatorFedIncomeTax(Decimal annualSalary) {
        return annualSalary * FED_INCOME_TAX_RATE;
    }
    private static Decimal socialSecurityTax(Decimal annualSalary) {
        return annualSalary * SOCIAL_SECURITY_TAX_RATE;
    }
    private static Decimal medicareWithholding(Decimal annualSalary) {
        return annualSalary * MEDICARE_WITHHOLDING_RATE;
    }
    private static Decimal calculatorMonthlyIncome(Decimal annualTakeHome) {
        return annualTakeHome/NUMBER_OF_MONTHS_IN_YEAR;
    }
}