global without sharing class RenReminder60Controller {
    global String conId{get;set;}
    //global date endDate45{get;set;}
    public date endDate65{
        get{
            
            
            // System.debug('quoteId' + quoteId);
            Contract getCont = conId != null ? [Select id,EndDate from Contract where id = :conId] : new Contract();
            endDate65 = getCont.EndDate.adddays(-7);
            if(getCont.EndDate.month() != 12){
                if(endDate65.month()== 12){
                    endDate65= endDate65.addYears(-1) ;
                }
            }
            
            return endDate65; 
        }set;
    }
}