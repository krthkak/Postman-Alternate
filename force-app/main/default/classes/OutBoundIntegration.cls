public with sharing class OutBoundIntegration {

    public static Long startTime;
    public static Long stoptTime;
    public static Decimal timeElapsed;

    public static httpresponse handleOutboundCall(RestRequestController.RequestInformationWrapper requestWrapper) {
        
        try{
            httprequest request = new httprequest();
            httpresponse response = new httpresponse();
            request.setmethod(requestWrapper.methodType);
            request.setendpoint(requestWrapper.url);
            prepareQueryString(request,requestWrapper);
            setHeaderInformation(request,requestWrapper);
            if(!string.isblank(requestWrapper.requestString) && requestWrapper.methodType != 'GET'){
                request.setbody(requestWrapper.requestString);
            }
            System.debug('final url'+request.getendpoint());
            System.debug('request body :'+request.getbody());
            response = sendRequest(request);
            return response;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug('exception line '+e.getLineNumber());
            throw e;
        }

    }

    private static httpresponse sendRequest(httprequest request) {
        try {
            httpresponse response = new httpresponse();
            http http = new http();
            startTime = DateTime.now().getTime();
            response = http.send(request);
            stoptTime = DateTime.now().getTime();
            timeElapsed = (stoptTime-startTime)/1000;
            system.debug('timeElapsed '+timeElapsed);
            System.debug('response from external system '+response.getbody());
            return response;

        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug('exception line '+e.getLineNumber());
            throw e;
        }
        

    }

    public static void prepareQueryString(httprequest request,RestRequestController.RequestInformationWrapper requestWrapper) {
        try {
            string queryString = '';
            integer n = 0;
            for(object i:requestWrapper.queryParameters){
                Map<string,object> mapObj = (Map<String, Object>)JSON.deserializeuntyped(JSON.serialize(i));
                System.debug('mapObj '+mapObj);
                if(mapObj!=null && !mapObj.isempty() && mapObj.get('shouldInclude')==true){
                    if(n!=0){
                        queryString = queryString+'&';
                    }
                    queryString = queryString+mapObj.get('key')+'='+mapObj.get('value');
                    n=n+1;
                }
                system.debug('queryString '+queryString);
            }

            if(!string.isblank(queryString)){
                request.setendpoint(request.getendpoint()+'?'+queryString);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug('exception line '+e.getLineNumber());
            throw e;
        }
    }

    public static void setHeaderInformation(httprequest request,RestRequestController.RequestInformationWrapper requestWrapper) {
        
        try {
            for(object i:requestWrapper.headerInformationList){
                Map<string,object> mapObj = (Map<String, Object>)JSON.deserializeuntyped(JSON.serialize(i));
                System.debug('shouldInclude '+mapObj.get('shouldInclude'));
                if(mapObj!=null && !mapObj.isempty() && mapObj.get('shouldInclude')==true){
                    request.setheader((string)mapObj.get('key'),(string)mapObj.get('value'));
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug('exception line '+e.getLineNumber());
            throw e;
        }
    }
}