public with sharing class JoobleJobSearchCallout {
	/*
	Retrieve Salesforce-related jobs using the Jooble API
	and create them as ‘Saved’ job applications. 
	*/
    @future(callout=true)
    public static void getJobApplicationsCallout() {

        String apiKey = '49176da3-7e23-4275-b1f4-d97b9c763ace'; // Your API key
		String endpoint = 'https://jooble.org/api/' + apiKey;

		// Create HTTP request to send.
		HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');

        // Build JSON payload using a Map
        Map<String, Object> payload = new Map<String, Object>();

        Date yesterday = Date.today().addDays(-1);
		String yesterdayStr = String.valueOf(yesterday);
		//search for salesforce related jobs in charlotte, NC area jobs posted yesterday.
        payload.put('keywords', 'Salesforce developer');
        payload.put('location', 'Charlotte, North Carolina');
        payload.put('datecreatedfrom', yesterdayStr);

        // Convert to JSON string
        req.setBody(JSON.serialize(payload));

		HttpResponse resp;
		
		try {
			resp = new Http().send(req);
		} catch (CalloutException calloutEx) {
        	System.debug('Callout error: ' + calloutEx.getMessage());
    	} catch (Exception ex) {
        	System.debug('Unexpected error: ' + ex.getMessage());
    	}
		// If the HTTP response code is successful, parse the JSON response and upsert records to Job_Application__c 
		List<Job_Application__c> jopAppList;
		if(resp.getStatusCode() == 200){
			try {
				//System.debug(resp.getBody());
				jopAppList = createJobApplicationFromResp(resp.getBody());
				//System.debug(JSON.serializePretty(jopAppList));
			} catch (Exception parseEx) {
           		System.debug('Error parsing JSON: ' + parseEx.getMessage());
        	}
		}
		upsert jopAppList Jooble_Job_Id__c; ///insert/update from the JSON response using the external id 
		
	}
    //Transforms a JSON response from Jooble API into a Salesforce Job_Application__c object.
    @TestVisible
	private static List<Job_Application__c> createJobApplicationFromResp(String jsonResponse) {
		// Deserialize the JSON string into map of primitive data types.
		Map<String,Object> obj = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
		List<Object> jobList = (List<Object>)obj.get('jobs');

		List<Job_Application__c> jobApplicationList = new List<Job_Application__c>();

		for (Object job : jobList) {

			Map<String,Object> objJob = (Map<String,Object>)job;

			// Skip record if company name or job title is missing
			String company = (String)objJob.get('company');
			String jobTitle = (String)objJob.get('title');

			if (String.isBlank(company) || String.isBlank(jobTitle)) {
				System.debug('Skipping job because Company name or job tilte is missing: ' + objJob);
				continue;
			}

			String jobName = (String)objJob.get('title') + ' at ' + (String)objJob.get('company');

			// Limit job name to 80 characters
			if (jobName.length() > 80) {
				jobName = jobName.substring(0, 80);
			}
		
			Job_Application__c jobApp = new Job_Application__c(
				Name = jobName,
				Job_Title__c = (String)objJob.get('title'), 
				Company_Name__c = (String)objJob.get('company'),
				Location__c = (String)objJob.get('location'),
				Status__c = 'Saved',
				Description__c = stripHtmlTag((String)objJob.get('snippet')),
				Salary__c = String.isNotBlank((String)objJob.get('salary'))? Decimal.valueOf((String)objJob.get('salary')) : null,
			 	URL__c = (String)objJob.get('link'),
				Jooble_Job_Id__c = String.valueOf(Math.abs((Long) objJob.get('id')))
			);
			jobApplicationList.add(jobApp);
		}
		return jobApplicationList;
	}

	// Remove HTML tags
    private static String stripHtmlTag(String input) {
        if (String.isBlank(input)) {
            return input;
        }

        // Step 1: Decode HTML entities (&nbsp;, &amp;, etc.)
        String decoded = input.unescapeHtml4();

        // Step 2: Remove all HTML tags like <b>, <div>, etc.
        decoded = decoded.replaceAll('<[^>]*>', '');

        // Step 3: Remove literal "..." sequences
        decoded = decoded.replaceAll('\\.{3,}', ''); // 3 or more dots

        // Step 4: Remove literal \n (backslash + n) and actual newlines
        decoded = decoded.replaceAll('\\\\n', ' '); // literal \n
        decoded = decoded.replaceAll('\\r\\n', ' '); // CRLF
        decoded = decoded.replaceAll('\\n', ' ');   // LF

        // Step 5: Normalize spaces (collapse multiple spaces)
        decoded = decoded.replaceAll('[ \\t]+', ' ').trim();

        return decoded;
    }

}