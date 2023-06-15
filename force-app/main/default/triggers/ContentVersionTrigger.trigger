/**
 * Created by Mantesh sharma on 27/06/22.
 */

trigger ContentVersionTrigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (trigger.isAfter){
        if(trigger.isInsert && !ContentVersionTriggerHandler.HandlerRecurrionVariable){
            ContentVersionTriggerHandler.onAfterInsert(trigger.new);
        }else if(trigger.isUpdate && !ContentVersionTriggerHandler.HandlerRecurrionVariable){
            ContentVersionTriggerHandler.onAfterUpdate(trigger.new, trigger.Oldmap); 
        }else if(trigger.isDelete && !ContentVersionTriggerHandler.HandlerRecurrionVariable){
            ContentVersionTriggerHandler.onAfterDelete(trigger.new, trigger.Oldmap);
        }
    }else if(trigger.isBefore){
        if(trigger.isInsert && !ContentVersionTriggerHandler.HandlerRecurrionVariable){
            ContentVersionTriggerHandler.onBeforeInsert(trigger.new);
        } else if(trigger.isUpdate && !ContentVersionTriggerHandler.HandlerRecurrionVariable){
            ContentVersionTriggerHandler.onBeforeUpdate(trigger.new, trigger.Oldmap);
        }else if( trigger.isDelete && !ContentVersionTriggerHandler.HandlerRecurrionVariable){
            ContentVersionTriggerHandler.onBeforeDelete(trigger.old, trigger.Oldmap);
        }
    }
}