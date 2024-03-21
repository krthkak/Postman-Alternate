public class CalloutBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
 
    public static string query;
    public CalloutBatch(){
    }
 
    public Database.QueryLocator start(Database.BatchableContext BC){
        query = 'select Query_Paramters__c,Header_Information__c,Request_Name__c,Request_Payload__c,Method_Type__c,URL__c,Name,id from Saved_Request__c where Asynchronous_Run__c=true';
        system.debug('query '+query);
       return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<RestRequestController.RequestResponseWrapper> RequestResponseWrapperList = new List<RestRequestController.RequestResponseWrapper>();
        for(sobject obj : scope){
            RestRequestController.RequestResponseWrapper reqResWrapper = makeCallout(obj);
            RequestResponseWrapperList.add(reqResWrapper);
        }

        //to log transaction
        RestRequestController.logBulkAPITransactions(RequestResponseWrapperList);
    }
 
    public void finish(Database.BatchableContext BC){
    }

    public RestRequestController.RequestResponseWrapper makeCallout(sObject obj){
        Saved_Request__c SR = (Saved_Request__c)obj;

        //preparing request wrapper
        RestRequestController.RequestInformationWrapper reqInfoWrapper = new RestRequestController.RequestInformationWrapper();
        reqInfoWrapper.headerInformationList = (List<object>)JSON.deserializeUntyped(SR.Header_Information__c);
        reqInfoWrapper.queryParameters = (List<object>)JSON.deserializeUntyped(SR.Query_Paramters__c);
        reqInfoWrapper.requestString = SR.Request_Payload__c;
        reqInfoWrapper.url = SR.URL__c;
        reqInfoWrapper.methodType = SR.Method_Type__c;

        //parent information for logging
        RestRequestController.SavedRequestWrapper saReqWrapper = new RestRequestController.SavedRequestWrapper();
        saReqWrapper.requestName = SR.Request_Name__c;
        saReqWrapper.requestId = SR.id;
        saReqWrapper.transactionOrigin = 'Scheduled - Asynchronous';

        //making callout
        RestRequestController.ResponseWrapper resWrapper = RestRequestController.makeRestRequest(reqInfoWrapper);

        return new RestRequestController.RequestResponseWrapper(reqInfoWrapper,resWrapper,saReqWrapper);
        
    }
 }