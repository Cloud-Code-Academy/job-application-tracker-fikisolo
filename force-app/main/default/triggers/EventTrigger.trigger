trigger EventTrigger on Event (before insert, before update) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                PreventDoubleBooking.checkDoubleBooking(Trigger.new, null);
            }
            when BEFORE_UPDATE {
                PreventDoubleBooking.checkDoubleBooking(Trigger.new, Trigger.oldMap);
            }
    }
}