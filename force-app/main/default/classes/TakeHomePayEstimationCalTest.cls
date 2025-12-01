@IsTest
private class TakeHomePayEstimationCalTest {

    @IsTest
    static void testSalaryCalculation() {
        // Create a Job Application record with a salary
        Job_Application__c job = new Job_Application__c(
            Name = 'Job App 1',
            Salary__c = 120000,
            Company_Name__c = 'ABC',
            Job_Title__c = 'Salesforce Developer'
        );
        insert job;
   
        Job_Application__c updatedJob = [SELECT Fed_Income_Tax__c, Social_Security_Tax__c, 
                                         Medicare_Withholding__c, AnnualTakeHome__c, Monthly_Income__c 
                                         FROM Job_Application__c 
                                         WHERE Id = :job.Id];

        Decimal expectedFedTax = job.Salary__c * TakeHomePayEstimationCal.FED_INCOME_TAX_RATE;
        Decimal expectedSS = job.Salary__c * TakeHomePayEstimationCal.SOCIAL_SECURITY_TAX_RATE;
        Decimal expectedMedicare = job.Salary__c * TakeHomePayEstimationCal.MEDICARE_WITHHOLDING_RATE;
        Decimal expectedAnnualTakeHome = job.Salary__c - (expectedFedTax + expectedSS + expectedMedicare);
        Decimal expectedMonthly = expectedAnnualTakeHome / TakeHomePayEstimationCal.NUMBER_OF_MONTHS_IN_YEAR;

        System.assertEquals(expectedFedTax, updatedJob.Fed_Income_Tax__c, 'Federal tax calculated incorrectly');
        System.assertEquals(expectedSS, updatedJob.Social_Security_Tax__c, 'Social Security tax calculated incorrectly');
        System.assertEquals(expectedMedicare, updatedJob.Medicare_Withholding__c, 'Medicare calculated incorrectly');
        System.assertEquals(expectedAnnualTakeHome, updatedJob.AnnualTakeHome__c, 'Annual take home calculated incorrectly');
        System.assertEquals(expectedMonthly, updatedJob.Monthly_Income__c, 'Monthly income calculated incorrectly');
    }
    @IsTest
    static void testSalarySetToNullResetsFields() {
        // Start with a valid salary so fields get populated first
        Job_Application__c job = new Job_Application__c(
            Name = 'Job App Null',
            Salary__c = 80000,
            Company_Name__c = 'ABC',
            Job_Title__c = 'Developer'
        );
        insert job;

        // Update salary to null
        job.Salary__c = null;
        update job;

        Job_Application__c updatedJob = [
            SELECT Salary__c, Fed_Income_Tax__c, Social_Security_Tax__c, 
                   Medicare_Withholding__c, AnnualTakeHome__c, Monthly_Income__c
            FROM Job_Application__c
            WHERE Id = :job.Id
        ];

        System.assertEquals(null, updatedJob.Salary__c, 'Salary should be null');
        System.assertEquals(null, updatedJob.Fed_Income_Tax__c, 'Fed tax should be cleared when salary is null');
        System.assertEquals(null, updatedJob.Social_Security_Tax__c, 'SS tax should be cleared when salary is null');
        System.assertEquals(null, updatedJob.Medicare_Withholding__c, 'Medicare should be cleared when salary is null');
        System.assertEquals(null, updatedJob.AnnualTakeHome__c, 'Annual take-home should be cleared when salary is null');
        System.assertEquals(null, updatedJob.Monthly_Income__c, 'Monthly income should be cleared when salary is null');
    }

    @IsTest
    static void testSalarySetToZeroResetsFields() {
        // Start with a valid salary so fields get populated first
        Job_Application__c job = new Job_Application__c(
            Name = 'Job App Zero',
            Salary__c = 90000,
            Company_Name__c = 'ABC',
            Job_Title__c = 'Developer'
        );
        insert job;

        // Update salary to zero
        job.Salary__c = 0;
        update job;

        Job_Application__c updatedJob = [
            SELECT Salary__c, Fed_Income_Tax__c, Social_Security_Tax__c, 
                   Medicare_Withholding__c, AnnualTakeHome__c, Monthly_Income__c
            FROM Job_Application__c
            WHERE Id = :job.Id
        ];

        System.assertEquals(0, updatedJob.Salary__c, 'Salary should be zero');
        System.assertEquals(null, updatedJob.Fed_Income_Tax__c, 'Fed tax should be cleared when salary is zero');
        System.assertEquals(null, updatedJob.Social_Security_Tax__c, 'SS tax should be cleared when salary is zero');
        System.assertEquals(null, updatedJob.Medicare_Withholding__c, 'Medicare should be cleared when salary is zero');
        System.assertEquals(null, updatedJob.AnnualTakeHome__c, 'Annual take-home should be cleared when salary is zero');
        System.assertEquals(null, updatedJob.Monthly_Income__c, 'Monthly income should be cleared when salary is zero');
    }
}
