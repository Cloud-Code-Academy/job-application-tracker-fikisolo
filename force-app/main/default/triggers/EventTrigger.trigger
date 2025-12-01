trigger EventTrigger on Event (before insert, before update) {

    // Skip all trigger logic when bypass flag is set
    if (TriggerBypassControl.bypassJobApplicationTrigger) {
        return;
    }
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            PreventDoubleBooking.checkDoubleBooking(Trigger.new, null);
        }
        when BEFORE_UPDATE {
            PreventDoubleBooking.checkDoubleBooking(Trigger.new, Trigger.oldMap);
        }
    }
}