@IsTest
public class TakeHomePayEstimationCalTest {

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

        Decimal expectedFedTax = job.Salary__c * 0.21;
        Decimal expectedSS = job.Salary__c * 0.062;
        Decimal expectedMedicare = job.Salary__c * 0.0145;
        Decimal expectedAnnualTakeHome = job.Salary__c - (expectedFedTax + expectedSS + expectedMedicare);
        Decimal expectedMonthly = expectedAnnualTakeHome / 12;

        System.assertEquals(expectedFedTax, updatedJob.Fed_Income_Tax__c, 'Federal tax calculated incorrectly');
        System.assertEquals(expectedSS, updatedJob.Social_Security_Tax__c, 'Social Security tax calculated incorrectly');
        System.assertEquals(expectedMedicare, updatedJob.Medicare_Withholding__c, 'Medicare calculated incorrectly');
        System.assertEquals(expectedAnnualTakeHome, updatedJob.AnnualTakeHome__c, 'Annual take home calculated incorrectly');
        System.assertEquals(expectedMonthly, updatedJob.Monthly_Income__c, 'Monthly income calculated incorrectly');
    }
}
