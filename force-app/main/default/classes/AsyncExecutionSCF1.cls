public class AsyncExecutionSCF1 implements Queueable{
    
    public Id jobId ;
    public Integer sequenceNumber ;

    public AsyncExecutionSCF1( Id jobId, Integer sequenceNumber ) {
        this.sequenceNumber = sequenceNumber;
        this.jobId = jobId;
    }

    public void execute(QueueableContext context) {
        if( sequenceNumber == 2 ) {
            System.abortJob( jobId );
        } else {
            System.enqueueJob( new AsyncExecutionSCF1( jobId, ++sequenceNumber ) );
        }        
    }
}