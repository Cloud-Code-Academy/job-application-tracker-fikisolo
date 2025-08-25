@IsTest
private class JoobleJobSearchCalloutTest {

    // Mock HTTP callout
    private class JoobleJobMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            // Sample JSON response (totalCount = 2)
            String sampleJson = '{"totalCount":2,"jobs":[{"title":"Salesforce Developer","location":"Charlotte, NC","snippet":"&nbsp;...Description & Requirements \\r\\n We are seeking a <b>Salesforce Developer </b>with experience in Health Cloud...","salary":"","source":"equest.com","type":"Full-time","link":"https://jooble.org/desc/4816699509191374999","company":"Maximus","updated":"2025-08-21T05:05:29.0770000","id":4816699509191374999},{"title":"Salesforce Developer","location":"Charlotte, NC","snippet":"&nbsp;...the technical delivery of custom development, integrations, and data migration elements of a <b>salesforce.</b>com implementation...","salary":"","source":"appcast.io","type":"","link":"https://jooble.org/away/6223570453500181087","company":"CapTech Consulting","updated":"2025-08-16T00:00:00.0000000","id":6223570453500181087}]}';
            
            res.setBody(sampleJson);
            return res;
        }
    }

    @IsTest
    static void testGetJobApplicationsCallout() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new JoobleJobMock());

        Test.startTest();
        JoobleJobSearchCallout.getJobApplicationsCallout();
        Test.stopTest();

        // Verify records inserted
        List<Job_Application__c> insertedJobs = [SELECT Name, Job_Title__c, Company_Name__c, Location__c, Description__c, URL__c, Jooble_Job_Id__c FROM Job_Application__c];

        System.assertEquals(2, insertedJobs.size(), 'Two job application records should have been inserted');
        // Assert a field value
        System.assert(insertedJobs[0].Name.contains('Maximus'), 'First job should be for Maximus');
        System.assert(insertedJobs[1].Name.contains('CapTech Consulting'), 'Second job should be for CapTech Consulting');
    }

   @IsTest
    static void testCreateJobApplicationFromResp() {
        // Sample JSON response
        String sampleJson = '{"totalCount":2,"jobs":[{"title":"Salesforce Developer","location":"Charlotte, NC","snippet":"&nbsp;...Description & Requirements \\r\\n We are seeking a <b>Salesforce Developer </b>with experience in Health Cloud to develop and maintain Salesforce solutions that optimize healthcare processes. The ideal candidate will be responsible for customizing Health Cloud features, developing...&nbsp;","salary":"","source":"equest.com","type":"Full-time","link":"https://jooble.org/desc/4816699509191374999","company":"Maximus","updated":"2025-08-21T05:05:29.0770000","id":4816699509191374999},{"title":"Salesforce Developer","location":"Charlotte, NC","snippet":"&nbsp;...the technical delivery of custom development, integrations, and data migration elements of a <b>salesforce.</b>com implementation\\n\\nProvide hands-on expert level assistance to <b>developers </b>for technical issues\\n\\nDemonstrate technical thought leadership\\n\\nLearning and Professional...&nbsp;","salary":"","source":"appcast.io","type":"","link":"https://jooble.org/away/6223570453500181087","company":"CapTech Consulting","updated":"2025-08-16T00:00:00.0000000","id":6223570453500181087}]}';

        // Parse JSON and create Job_Application__c objects
        List<Job_Application__c> jobApps = JoobleJobSearchCallout.createJobApplicationFromResp(sampleJson);

        System.assertEquals(2, jobApps.size(), 'Should parse two jobs');

        // Assert first job fields
        Job_Application__c job1 = jobApps[0];
        System.assertEquals('Salesforce Developer at Maximus', job1.Name);
        System.assertEquals('Salesforce Developer', job1.Job_Title__c);
        System.assertEquals('Maximus', job1.Company_Name__c);
        System.assertEquals('Charlotte, NC', job1.Location__c);
        System.assertEquals('4816699509191374999', job1.Jooble_Job_Id__c);

        // Assert second job fields
        Job_Application__c job2 = jobApps[1];
        System.assertEquals('Salesforce Developer at CapTech Consulting', job2.Name);
        System.assertEquals('Salesforce Developer', job2.Job_Title__c);
        System.assertEquals('CapTech Consulting', job2.Company_Name__c);
        System.assertEquals('Charlotte, NC', job2.Location__c);
        System.assertEquals('6223570453500181087', job2.Jooble_Job_Id__c);
    }
}
