/**
 * @description       : 
 * @author            : Karthik 
 * @group             : 
 * @last modified on  : 03-21-2024
 * @last modified by  : Karthik 
**/
public with sharing class RestRequestController {
    public static Long startTime;
    public static Long stoptTime;
    public static Decimal timeElapsedForApexError;

    
    @AuraEnabled()
    public static ResponseWrapper makeRestRequest(RestRequestController.RequestInformationWrapper requestWrapper){
        try {
            startTime = DateTime.now().getTime();
            System.debug('requestWrapper '+requestWrapper);
            if(Label.skipRemoteProxyCheckAndCreation != 'yes')    //skips the remote site check and creation if the custom label is set to yes
                MetadataAPIUtility.handlePrerequisitesForCallout(requestWrapper);
            Httpresponse response = OutBoundIntegration.handleOutboundCall(requestWrapper);
            System.debug('response code '+ response.getStatusCode());
            System.debug('Response '+response);

            return new ResponseWrapper(response);
        } catch (Exception e) {
            System.debug('makeRestRequest message'+e.getMessage());
            System.debug('exception line '+e.getLineNumber());
            return apexError(e);
        }
    }

    @AuraEnabled()
    public static void logAPITransaction(ResponseWrapper resWraper,RestRequestController.RequestInformationWrapper requestWrapper,RestRequestController.SavedRequestWrapper savedReqwrapper){
        try {
            system.debug('resWraper '+resWraper);
            system.debug('requestWrapper '+requestWrapper);
            Outbound_log__c rto= prepareOutboundLogObject(resWraper,requestWrapper,savedReqwrapper);
            insert rto;
        } catch (Exception e) {
            throw e;
        }
    }

    public static void logBulkAPITransactions(List<RestRequestController.RequestResponseWrapper> RequestResponseWrapperList)
    {
        try {
            List<Outbound_log__c> realTimeOutboundLogList = new List<Outbound_log__c>();
            for(RestRequestController.RequestResponseWrapper reqResWrapper :RequestResponseWrapperList){
                Outbound_log__c rto= prepareOutboundLogObject(reqResWrapper.resWrapper,reqResWrapper.reqInfoWrapper,reqResWrapper.saReqWrapper);
                realTimeOutboundLogList.add(rto);
            }
            if(!realTimeOutboundLogList.isEmpty()){
                insert realTimeOutboundLogList;
            }
        } catch (Exception e) {
            throw e;
        }
    }
    
    public static Outbound_log__c prepareOutboundLogObject(RestRequestController.ResponseWrapper resWraper,RestRequestController.RequestInformationWrapper requestWrapper,RestRequestController.SavedRequestWrapper savedReqwrapper) {
        try {
            Outbound_log__c rto = new Outbound_log__c();
            rto.URL__c	 = requestWrapper.url;
            rto.Header_Information__c = JSON.serialize(requestWrapper.headerInformationList);
            rto.Query_Paramters__c	 = JSON.serialize(requestWrapper.queryParameters);
            rto.Method_Type__c = requestWrapper.methodType;
            rto.Request__c = requestWrapper.requestString;
            rto.Response__c = resWraper.responseBody;
            rto.Response_status_code__c	 = resWraper.statusCode;
            rto.Time_Elapsed__c	= resWraper.timeElapsed;
            rto.Request_Name__c	= savedReqwrapper.requestName;
            system.debug('savedReqwrapper.requestId '+savedReqwrapper.requestId);
            if(String.isNotBlank(savedReqwrapper.requestId)){
                rto.Saved_Request__c = savedReqwrapper.requestId;
            }
            system.debug('savedReqwrapper.transactionOrigin '+savedReqwrapper.transactionOrigin);
            rto.Transaction_Origin__c = savedReqwrapper.transactionOrigin;
            return rto;
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug('Exception method : prepareOutboundLogObject');
            System.debug('exception line '+e.getLineNumber());
            throw e;
        }
        
    }



    public static ResponseWrapper apexError(Exception e){
        Map<string,string> errorResponseForApexError = new map<string,string>();
        errorResponseForApexError.put('Message',e.getMessage());
        stoptTime = DateTime.now().getTime();
        timeElapsedForApexError = (stoptTime-startTime)/1000;
        ResponseWrapper rw = new ResponseWrapper();
        rw.statusCode = 400;
        rw.responseBody =  JSON.serialize(errorResponseForApexError);
        rw.status =  'ERROR';
        rw.timeElapsed =  timeElapsedForApexError;
        return rw;
    }

    public class RequestInformationWrapper{
        @AuraEnabled 
        public String methodType {get; set;}
        @AuraEnabled 
        public String url {get; set;}
        @AuraEnabled 
        public String requestString {get; set;}
        @AuraEnabled 
        public List<object> queryParameters {get; set;}
        @AuraEnabled 
        public List<object> headerInformationList {get; set;}
    }

    public class ResponseWrapper{
        @AuraEnabled 
        public integer statusCode {get; set;}
        @AuraEnabled 
        public String responseBody {get; set;}
        @AuraEnabled 
        public String statusInformation {get; set;}
        @AuraEnabled 
        public String status {get; set;}
        @AuraEnabled 
        public Decimal timeElapsed {get; set;}

        public ResponseWrapper(Httpresponse response){
            this.statusCode = response.getStatusCode();
            this.responseBody = response.getbody();
            this.statusInformation = response.toString();
            this.status = response.getStatus();
            this.timeElapsed = OutBoundIntegration.timeElapsed;
        }

        public ResponseWrapper(){
        }
    }

    //Holds information about the saved request for logging
    public class SavedRequestWrapper{
        @AuraEnabled 
        public String requestName {get; set;}
        @AuraEnabled 
        public String requestId {get; set;}
        @AuraEnabled 
        public String transactionOrigin {get; set;}
    }


    public class RequestResponseWrapper{
          
        public RestRequestController.RequestInformationWrapper reqInfoWrapper {get; set;}
        
        public RestRequestController.ResponseWrapper resWrapper {get; set;}
        
        public RestRequestController.SavedRequestWrapper saReqWrapper {get; set;}
        
        public RequestResponseWrapper(RestRequestController.RequestInformationWrapper reqInfoWrapper
        ,RestRequestController.ResponseWrapper resWrapper
        ,RestRequestController.SavedRequestWrapper saReqWrapper){
            this.reqInfoWrapper = reqInfoWrapper;
            this.resWrapper = resWrapper;
            this.saReqWrapper = saReqWrapper;
        }
    }
    

}