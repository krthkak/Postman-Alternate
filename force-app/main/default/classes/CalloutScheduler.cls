/*Author : Karthik */
global class CalloutScheduler implements Schedulable {
    global void execute(SchedulableContext SC) { 
        CalloutBatch CB = new CalloutBatch();
        database.executeBatch(CB,30); 
    }
 }
