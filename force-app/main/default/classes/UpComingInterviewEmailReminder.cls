public with sharing class UpComingInterviewEmailReminder {

    public static void sendEmailReminder() {
        //get list of interviews scheduled for next day.
        Date tomorrow = Date.today().addDays(1);
        DateTime startTime = DateTime.newInstance(tomorrow, Time.newInstance(0,0,0,0));
        DateTime endTime = startTime.addDays(1);

        List<Event> upcomingEvents = [
            SELECT Id, OwnerId, WhoId, Who.Name, WhatId, What.Name, StartDateTime
            FROM Event 
            WHERE StartDateTime >= :startTime
            AND StartDateTime < :endTime
        ];

        if (upcomingEvents.isEmpty()) {
                return;
        }

        Set<Id> ownerIds = new Set<Id>();
        for (Event ev : upcomingEvents) {
            ownerIds.add(ev.OwnerId);
        }
        //get user infos associated with event owners
        List<User> usersInfo = [SELECT Id, Email, Name FROM User  WHERE Email != null AND Id IN :ownerIds];

        Map<Id, List<String>> userIdToUserInfoMap = new Map<Id, List<String>>();

        for (User u : usersInfo) {
            userIdToUserInfoMap.put(u.Id, new List<String>{u.Name, u.Email});
        }

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Event evt : upcomingEvents) {
            if (userIdToUserInfoMap.containsKey(evt.OwnerId)) {
                emailsToSend.add(prepareEmail(evt, userIdToUserInfoMap.get(evt.OwnerId)));
            }
        }
             // Send email at once
        if (!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);

            //check results
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                     System.debug('Email sent successfully.');
                } else {
                    System.debug('Email Failed: ' + results[i].getErrors()[0].getMessage());
                }
            }
        }
    }
    private static Messaging.SingleEmailMessage prepareEmail(Event evt, List<String> userInfo) {

            // Create the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String userName = userInfo[0];
            String userEmail = userInfo[1];

            email.setToAddresses(new String[] { userEmail });
            // Set subject and body
            email.setSubject('You have upcoming interview tomorrow');
            // set Email body
            email.setPlainTextBody('Hello ' + userName + ',\n\n'
                                    + 'You have upcoming interviews with ' + evt.Who.Name + ' for' + evt.What.Name + ' job application.\n\n'
                                    + 'Thank you!');
            return email;
        }
    }