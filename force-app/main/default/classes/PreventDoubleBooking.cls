public with sharing class PreventDoubleBooking {
    /*Validations so that interview meetings cannot overlap, preventing double booking 
    and weekend booking.
    */
    public static void checkDoubleBooking(List<Event> events, Map<Id, Event> oldEvents) {
        // set of incoming events Owners Ids/Assigned To 
        Set<Id> ownerIds = new Set<Id>();
        for (Event e : events) {
            ownerIds.add(e.OwnerId);
        }

        //If ownerIds is empty, exit the method early
        if (ownerIds.isEmpty()) {
            return;
        }
        // Query existing events/interviews for these owners, excluding current records for updates
        List<Event> existingEvents = [
            SELECT Id, StartDateTime, EndDateTime, OwnerId
            FROM Event
            WHERE OwnerId IN :ownerIds
            AND (Id NOT IN : ((oldEvents != null) ? oldEvents.keySet() : new Set<Id>()))
        ];
        //check for weekend booking
        for (Event newEvent : events) {
            //Its a good practice to validate that the fields you are working with are not null before trying to compare values.
            //i.e. ensure newEvent.StartDateTime and newEvent.EndDateTime are not null
            if (newEvent.StartDateTime == null || newEvent.EndDateTime == null) {
                 newEvent.addError('Start and End time are required for an interview.');
            }

            //get integer value of the day of week
            Integer dayOfWeek = Integer.valueOf(newEvent.StartDateTime.format('u')); // 1 = Monday, 7 = Sunday
            if (dayOfWeek == 6 || dayOfWeek == 7) {
                    newEvent.addError('Interview cannot be scheduled on weekends.');
                    continue;
            }

           // Datetime epoch = Datetime.newInstanceGMT(1970, 1, 1, 0, 0, 0);
            // Convert StartDateTime and EndDateTime to minutes since epoch
            Long newStartMinutes = EventHelper.convertDTimeToMinSinceEpoch(newEvent.StartDateTime);
            Long newEndMinutes   = EventHelper.convertDTimeToMinSinceEpoch(newEvent.EndDateTime);

            //Check for overlapping events/interview date and time
            for (Event existing : existingEvents) {
                Long existStartMinutes = EventHelper.convertDTimeToMinSinceEpoch(existing.StartDateTime);
                Long existEndMinutes   = EventHelper.convertDTimeToMinSinceEpoch(existing.EndDateTime);


                /*If new event/interview starts any time before an existing event/interview                 
                  and doesn't end before start time of an existing event/interview
                  there is over lap*/
                if ((newStartMinutes < existEndMinutes) && (newEndMinutes > existStartMinutes)) {
                    newEvent.addError('You have interview scheduled that overlaps with this time.');
                    break;
                }
            }
        }
    }
}