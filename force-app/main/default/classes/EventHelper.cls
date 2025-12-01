public with sharing class EventHelper {
 /*EventHelper class that hold logic related to Events*/
 
    // Helper: return the next weekday on/after the given date
    public static Date nextWeekday(Date d) {
        Date givenDate = d;

        // toStartOfWeek() returns the Sunday of that week
        // daysBetween() gives the date difference/offset between two dates in integer

        while (givenDate.toStartOfWeek().daysBetween(givenDate) == 0  // Sunday
                || givenDate.toStartOfWeek().daysBetween(givenDate) == 6) // Saturday
                {
                    givenDate = givenDate.addDays(1);
                }
        return givenDate;
    }
    // Helper: get  minutes since epoch for a given datetime
    public static Long convertDTimeToMinSinceEpoch(DateTime dtTime) {

        Datetime epoch = Datetime.newInstanceGMT(1970, 1, 1, 0, 0, 0);
        // Convert DateTime to minutes since epoch
        return (dtTime.getTime() - epoch.getTime()) / 60000;
    }
}