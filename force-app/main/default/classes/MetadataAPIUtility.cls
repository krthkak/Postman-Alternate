public with sharing class MetadataAPIUtility{
    public static boolean createRemoteSiteSettings(string fullname,string urlString){
        boolean isSucessfull=false;
        Map<string,string> RemoteSiteMap = new Map<string,string>();
        //specify the remote site name and url in RemoteSiteMap
        RemoteSiteMap.put('FOR_REST_API_CALL',URL.getSalesforceBaseUrl().toExternalForm());
        //String PageURL1 = URL.getCurrentRequestUrl().toExternalForm();
        //RemoteSiteMap.put('FOR_REST_API_CALL',URL.getCurrentRequestUrl().toExternalForm());
        
        List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
        MetadataService.RemoteSiteSetting remoteSiteDetails = new MetadataService.RemoteSiteSetting();
        remoteSiteDetails.fullName = fullname;
        remoteSiteDetails.description = fullname+'-created through apex';
        remoteSiteDetails.disableProtocolSecurity  = false;
        remoteSiteDetails.isActive  = true;
        remoteSiteDetails.url=urlString;
        allMetadataList.add(remoteSiteDetails);
        if(allMetadataList.size()>0){
            system.debug('****RemoteSiteSettings allMetadataList:'+allMetadataList);
            MetadataService.MetadataPort service = createService();
            if(Test.isRunningTest()){
                return false;
            }
            List<MetadataService.UpsertResult> results = service.upsertMetadata(allMetadataList);
            for(MetadataService.UpsertResult result: results){
                    if(result.success){
                        system.debug('added remote site setting success='+result);
                        isSucessfull=true;
                    }else{
                        system.debug('****error while adding remote site settings:'+result.errors[0].message);
                    }

            }

        }
        return isSucessfull;
    }  
    
    private static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.endpoint_x ='callout:SalesforceAPITool/services/Soap/m/42.0';
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId ='{!$Credential.OAuthToken}';
        return service;     
    }

    public static boolean doesRemoteSiteSettingExist(string urlString) {
        try{
            HttpRequest req = new HttpRequest();
            // req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            // system.debug('Authorization '+ req.getHeader('Authorization'));
            string contentType = 'Content-Type';
            string application = 'application/json';
            string ownOrgToolingEndpoint = 'callout:SalesforceAPITool/services/data/v53.0/tooling/query/?q=Select+EndpointUrl,SiteName+from+RemoteProxy+where+EndpointUrl=\''+urlString+'\'';
            req.setHeader(contentType, application);
            String domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
            req.setEndpoint(ownOrgToolingEndpoint);// put it into a variable
            req.setMethod('GET');
            Http h = new Http();
            HttpResponse res = h.send(req);
            system.debug(res.getBody());
            Map<string,object> responseParse =(Map<string,object>)JSON.deserializeUntyped(res.getBody());
            if(responseParse.get('size')==1){
                return true;
            }else{
                return false;
            }
        }catch(exception e){
            throw e;
        }
                
    }

    public static void handlePrerequisitesForCallout(RestRequestController.RequestInformationWrapper requestWrapper){
        try {
            URL urlString = new URL(requestWrapper.url);
            string host = urlString.getProtocol()+'://'+urlString.getHost();
            string finalName = '';
            integer count=1;
            for(String s:urlString.getHost().split('[-$.]')){
                if(count==1)
                {
                    finalName = s;
                    count=count+1;
                }   
                else if(count==2){
                    finalName = finalName+'_'+s;
                    break;
                }  
            }
            if(!doesRemoteSiteSettingExist(host)){
                createRemoteSiteSettings(finalName,host);
            }
        } catch (Exception e) {
            throw e;
        }
        
    }
  }