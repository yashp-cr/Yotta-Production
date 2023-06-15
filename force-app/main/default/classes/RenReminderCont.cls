global without sharing class RenReminderCont {
    global String conId{get;set;}
    //global date endDate45{get;set;}
    public date endDate45{
        get{
            
            
            // System.debug('quoteId' + quoteId);
            Contract getCont = conId != null ? [Select id,EndDate from Contract where id = :conId] : new Contract();
            endDate45 = getCont.EndDate.adddays(-5);
            if(getCont.EndDate.month() != 12){
                if(endDate45.month()== 12){
                    endDate45= endDate45.addYears(-1) ;
                }
            }
            
            return endDate45; 
        }set;
    }
}