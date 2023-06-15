/*
 * Name        : TriggerHandler
 * Description : Trigger Handler Framework
 * Author      : Himanshu (Compro Technologies)
 * Created On  : 28 Feb 2020
 * Test Class  : TriggerHandlerTest
 * Change Log History
 *  |-------------------------------------------------------------------------|
 *  | Version | Modified By     | Date       | Comment                        |
 *  |-------------------------------------------------------------------------|
 *  | 0.1     | Himanshu        | 28/02/2020 | Initial Version of Class       |
 *  |-------------------------------------------------------------------------|
 */
public virtual class TriggerHandler {

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    public static Boolean hasExecuted = false;
    private static Boolean bypassAllTriggers = false;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }
    
    public static void bypassAllTriggers() {
        bypassAllTriggers = true;
    }

    public static void clearAllBypass() {
        bypassAllTriggers = false;
    }
    
    public static Boolean validateTrigger( String objectName ) {
        Boolean isActive = true;
        TriggerController__c tController = TriggerController__c.getInstance();
        if(tController != null && tController.DeactivateObjectTrigger__c!=null){
            isActive = !((String.valueOf(tController.DeactivateObjectTrigger__c)).contains(objectName));
        }
        if(tController != null && tController.IsActive__c!=null && tController.IsActive__c==false){
            isActive = false;
        }
        return isActive;
    }
    
    // constructor
    public TriggerHandler() {
        this.setTriggerContext();
    }

    /***************************************
     *      public instance methods        *
     ***************************************/

    // main method that will be called during execution
    public void run() {
        //System.debug('1.....' + TriggerHandler.loopCountMap.get(getHandlerName()).getCount());
        //System.debug('1.....' + TriggerHandler.loopCountMap.get(getHandlerName()).getMax());
        if (!validateRun()) return;

        //System.debug('2.....' + TriggerHandler.loopCountMap.get(getHandlerName()).getCount());
        //System.debug('2.....' + TriggerHandler.loopCountMap.get(getHandlerName()).getMax());

        addToLoopCount();

        //System.debug('3.....' + TriggerHandler.loopCountMap.get(getHandlerName()).getCount());
        //System.debug('3.....' + TriggerHandler.loopCountMap.get(getHandlerName()).getMax());
        //

        // dispatch to the correct handler method
        if (this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        } else if (this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        } else if (this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        } else if (this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        } else if (this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
        } else if (this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        } else if (this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }
        
        
        

        //System.debug('4.....' + TriggerHandler.loopCountMap.get(getHandlerName()).getCount());
        //System.debug('4.....' + TriggerHandler.loopCountMap.get(getHandlerName()).getMax());


    }

    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    /***************************************
     * public static methods
     ***************************************/

    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }

    /***************************************
     * private instancemethods
     ***************************************/

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    public void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                   (ctx != null && ctx == 'before update')) {
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                   (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                   (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                   (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                   (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                   (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            if (exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                //System.debug('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        Boolean isActive = true;
        //TriggerController__c tController = TriggerController__c.getValues(getHandlerName());
        //if(tController != null) isActive = tController.IsActive__c;
        TriggerController__c tController = TriggerController__c.getOrgDefaults();
        if (tController != null) isActive = tController.IsActive__c;

        if (!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        if (TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        } else if (!isActive) {
            return false;
        }
        return true;
    }

    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }


    /***************************************
     * context methods
     ***************************************/

    //Utility Method
    public static Boolean isChanged(Id rec_id, string fieldName) {
        if (trigger.newMap != null && trigger.oldMap != null) {
            if (!trigger.newMap.containsKey(rec_id)) return false;
            sObject rec = trigger.newMap.get(rec_id);
            sObject old_rec = trigger.oldMap.get(rec_id);
            if (rec.get(fieldName) != old_rec.get(fieldName)) return true;
        }
        return false;
    }
    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert() {}
    @TestVisible
    protected virtual void beforeUpdate() {}
    @TestVisible
    protected virtual void beforeDelete() {}
    @TestVisible
    protected virtual void afterInsert() {}
    @TestVisible
    protected virtual void afterUpdate() {}
    @TestVisible
    protected virtual void afterDelete() {}
    @TestVisible
    protected virtual void afterUndelete() {}

    /***************************************
     * inner classes
     ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            if (this.max < 0) return false;
            if (this.count > this.max) {
                return true;
            }
            return false;
        }

        public Integer getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }


    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

    // exception class
    public class TriggerHandlerException extends Exception {}

}