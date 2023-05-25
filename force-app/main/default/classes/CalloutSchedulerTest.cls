@istest
public class CalloutSchedulerTest {
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
        Saved_Request__c SR = new Saved_Request__c();
        SR.Method_Type__c = 'POST';
        SR.URL__c = 'https://resourceful-raccoon-cbu6w8-dev-ed.my.salesforce.com/services/data/v42.0/sObject/Account';
        SR.Request_Payload__c = '{ "name": "Test Name" }';
        SR.Header_Information__c = '[{"id":0,"type":"headerInformation","key":"Authorization","value":"Bearer 00D5j000005Kq43!ARIAQOwWZmEqPgLvnKyyXWCIDt9.gi78bqghhAn41DSZCmriwstTreV1KMlEAjE_OyvR2IiDePNfkAD.m3OidZ2Ig9RmNfas","shouldInclude":true},{"id":1,"type":"headerInformation","key":"Content-Type","value":"application/json;charset=UTF-8","shouldInclude":true}]';
        SR.Query_Paramters__c = '[{"id":0,"type":"queryParameter","key":"","value":"","shouldInclude":false}]';                                 
		SR.Request_Name__c = 'Test  Request';
        SR.Asynchronous_Run__c = true;
        
        insert SR;
        
        Test.startTest();
        CalloutScheduler CS = new CalloutScheduler();
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule to make api requests', sch,CS);
        Test.stopTest();
		        
    }
}