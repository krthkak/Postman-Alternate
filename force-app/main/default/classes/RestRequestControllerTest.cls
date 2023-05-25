@istest()
public class RestRequestControllerTest {
    
    Public with sharing class ManagedException extends Exception{}
    
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"id":"0015j00000YUEutAAH","success":true,"errors":[]}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @istest()
    public static void testPost(){
        
        //setting up mock
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        //setting up requestWrapper
        RestRequestController.RequestInformationWrapper rIW = new RestRequestController.RequestInformationWrapper();
        rIW.methodType = 'POST';
        rIW.url = 'https://resourceful-raccoon-cbu6w8-dev-ed.my.salesforce.com/services/data/v42.0/sObject/Account';
        rIW.requestString = '{ "name": "Test Name" }';
        rIW.headerInformationList = (List<object>)JSON.deserializeUntyped('[{"id":0,"type":"headerInformation","key":"Authorization","value":"Bearer 00D5j000005Kq43!ARIAQOwWZmEqPgLvnKyyXWCIDt9.gi78bqghhAn41DSZCmriwstTreV1KMlEAjE_OyvR2IiDePNfkAD.m3OidZ2Ig9RmNfas","shouldInclude":true},{"id":1,"type":"headerInformation","key":"Content-Type","value":"application/json;charset=UTF-8","shouldInclude":true}]');
        rIW.queryParameters = (List<object>)JSON.deserializeUntyped('[{"id":0,"type":"queryParameter","key":"","value":"","shouldInclude":false}]');                                 

        RestRequestController.SavedRequestWrapper saReqWrapper = new RestRequestController.SavedRequestWrapper();
        saReqWrapper.requestName = 'Test Request';
        saReqWrapper.requestId = null;
        saReqWrapper.transactionOrigin = 'UI - Synchronous	';
        
        Test.startTest();
        RestRequestController.ResponseWrapper responseWrap=RestRequestController.makeRestRequest(rIW);
        RestRequestController.logAPITransaction(responseWrap,rIW,saReqWrapper);
        Test.stopTest();
		        
    }
    
    @istest()
    public static void testGet(){
        
        //setting up mock
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        //setting up requestWrapper
        RestRequestController.RequestInformationWrapper rIW = new RestRequestController.RequestInformationWrapper();
        rIW.methodType = 'GET';
        rIW.url = 'https://resourceful-raccoon-cbu6w8-dev-ed.my.salesforce.com/services/data/v42.0/sObject/Account';
        rIW.requestString = '{ "name": "Test Name" }';
        rIW.headerInformationList = (List<object>)JSON.deserializeUntyped('[{"id":0,"type":"headerInformation","key":"Authorization","value":"Bearer 00D5j000005Kq43!ARIAQOwWZmEqPgLvnKyyXWCIDt9.gi78bqghhAn41DSZCmriwstTreV1KMlEAjE_OyvR2IiDePNfkAD.m3OidZ2Ig9RmNfas","shouldInclude":true},{"id":1,"type":"headerInformation","key":"Content-Type","value":"application/json;charset=UTF-8","shouldInclude":true}]');
        rIW.queryParameters = (List<object>)JSON.deserializeUntyped('[{"id":0,"type":"queryParameter","key":"name","value":"Test Name","shouldInclude":true},{"id":0,"type":"queryParameter","key":"age","value":"25","shouldInclude":true}]');                                 
        
        RestRequestController.SavedRequestWrapper saReqWrapper = new RestRequestController.SavedRequestWrapper();
        saReqWrapper.requestName = 'Test Request';
        saReqWrapper.requestId = null;
        saReqWrapper.transactionOrigin = 'UI - Synchronous	';
        
        Test.startTest();
        RestRequestController.ResponseWrapper responseWrap=RestRequestController.makeRestRequest(rIW);
        RestRequestController.logAPITransaction(responseWrap,rIW,saReqWrapper);
        Test.stopTest();
		        
    }
    
    @istest()
    public static void testErrorScenario(){
        ManagedException e = new ManagedException('Error Occured');
        RestRequestController.startTime = DateTime.now().getTime();
        Test.startTest();
        RestRequestController.apexError(e);
        TEst.stopTest();		        
    }
    
    @istest()
    public static void testSavedRequest(){
        Saved_Request__c sr = new Saved_Request__c();
        sr.Header_Information__c = '[{"id":0,"type":"headerInformation","key":"Authorization","value":"Bearer 00D5j000005Kq43!ARIAQOwWZmEqPgLvnKyyXWCIDt9.gi78bqghhAn41DSZCmriwstTreV1KMlEAjE_OyvR2IiDePNfkAD.m3OidZ2Ig9RmNfas","shouldInclude":true},{"id":1,"type":"headerInformation","key":"Content-Type","value":"application/json;charset=UTF-8","shouldInclude":true}]';
        sr.Query_Paramters__c = '[{"id":0,"type":"queryParameter","key":"name","value":"Test Name","shouldInclude":true},{"id":0,"type":"queryParameter","key":"age","value":"25","shouldInclude":true}]';
        sr.Method_Type__c = 'GET';
        sr.Request_Name__c = 'Sample';
        sr.URL__c = 'https://resourceful-raccoon-cbu6w8-dev-ed.my.salesforce.com/services/data/v42.0/sObject/Account';
        insert sr;
        
        Test.startTest();
        List<Saved_Request__c> savedRequests = SavedRequestsController.getSavedRequests('S');
        system.assertEquals(1, savedRequests.size());
        Test.stopTest();
    }
    
}