public with sharing class SavedRequestsController {

    @AuraEnabled(cacheable=true)
    public static List<Saved_Request__c> getSavedRequests(string searchKey) {
        List<Saved_Request__c> requestList;
        try {
            String queryString = 'select Query_Paramters__c,Header_Information__c,Request_Name__c,Request_Payload__c,Method_Type__c,URL__c,Name,id from Saved_Request__c';
            if(String.isNotblank(searchKey)){
                string tempInput = '\'%' + searchKey + '%\'';
                queryString = queryString + ' where Request_Name__c Like '+tempInput;
            }
            queryString = queryString + ' order by lastmodifieddate desc limit 9';
            requestList= database.query(queryString);
            
        } catch (Exception e) {
            System.debug('line and error '+e.getLineNumber() +' '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return requestList;
    }
}