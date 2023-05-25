import { LightningElement,track  } from 'lwc';
import makeRestRequest from '@salesforce/apex/RestRequestController.makeRestRequest';
import logAPITransaction from '@salesforce/apex/RestRequestController.logAPITransaction';
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SalesforceAPITool extends LightningElement {

    //saved request uinique identifiers - begin
    id='';
    requestName='';
    name = ''; // note : doesn not correspond to a name string, it holds a unique alphanumeric 
    //saved request uinique identifiers - end

    methodType = "GET";
    request = "";
    showRequestForPost = false;
    URL = "";
    response = '';
    statusInformation = '';
    showSpinner = false;

    @track queryParameterList = [{
            id: 0,type:"queryParameter",key:"",value:"",shouldInclude:false
        }];
    @track headerList = [{
            id: 0,type:"headerInformation",key:"",value:"",shouldInclude:false
        }]

    get options() {
        return [
            {'label': 'Get', 'value': 'GET'},
            {'label': 'Post', 'value': 'POST'}
        ];
    }

    @track openSavedRequestSelectionModalFlag = false;

    

    openSavedRequestSelectionModal(event){
        this.openSavedRequestSelectionModalFlag = true
    }

    refreshCurrentRequest(event){
        this.methodType = "GET";
        this.showRequestForPost = false;
        this.request = "";
        this.URL = "";
        this.response = '';
        this.statusInformation='';
        this.requestName='';
        this.id='';

        this.queryParameterList = [{
                id: 0,type:"queryParameter",key:"",value:"",shouldInclude:false
            }];
        this.headerList = [{
                id: 0,type:"headerInformation",key:"",value:"",shouldInclude:false
            }]
    }

    onRequestNameChange(event){
        this.requestName = event.target.value;
        console.log(this.requestName);
    }

    onMethodChange(event){
        console.log("on method change try 4")
        this.methodType = event.target.value;
        this.setShowRequestForPostAttribute(this.methodType);
    }

    onRequestInformationChange(event){
        switch(event.target.name){
            case "URL": this.URL = event.target.value;
                        this.parseURLQueryParameter(event);
            break;
            case "request":this.request = event.target.value;
            break;
            default: console.log("no match found");
        }
        console.log('request :'+this.request);
    }

    onFieldSetChange(event){
        var id = event.currentTarget.dataset.id;
        var keyName = event.target.name;
        var value = event.target.value
        if(event.target.name=="shouldInclude"){
            value = event.target.checked
        }
        if(event.currentTarget.dataset.name=='headerInformation'){
            this.updateFieldSet(id,this.headerList,keyName,value);
        }
        else{
            this.updateFieldSet(id,this.queryParameterList,keyName,value);
        }
            
    }

    addQueryParameterFieldSet(event){
		this.addFieldset("queryParameter");
	}
    
    addHeaderFieldSet (event) {
		this.addFieldset("headerInformation");
	}

    sendRequest(event){
        
        console.log('entering sendRequest')
        this.statusInformation = '';
        if(this.URL==''){
            this.URL = ''
            alert('Please enter URL')
            console.log('before preventDefault stopped')
            return ''
        }
        this.response = ''
        this.showSpinner = true;
        console.log(this.request)
        if(this.request != '' &&  this.request !=null && this.request !=undefined){
            this.request = JSON.stringify(JSON.parse(this.request),null,2);
        }
        console.log('line 122')
        var RequestInformationWrapper = {methodType:this.methodType,url:this.URL,
            queryParameters:this.queryParameterList,
            headerInformationList:this.headerList,
            requestString:this.request};
        console.log('RequestInformationWrapper '+JSON.stringify(RequestInformationWrapper));
        makeRestRequest({requestWrapper:RequestInformationWrapper}).then(result => { 

            this.handleCalloutResponse(result,'success',RequestInformationWrapper);

        }).catch(error => {

            this.handleCalloutResponse(error,'error',RequestInformationWrapper);
        });
        
    }

    //to save the current running request to the db for future use
    saveRequest(event){
        console.log('beginning saveRequest')
        var dmlType = 'insert';
        if(!this.isEmpty(this.id)){
           dmlType = 'update';
           if(this.isEmpty(this.requestName)){
               alert('Enter Request Name to proceed.');
               return;
           }
        }else{
            console.log('this.URL '+this.URL);
            if(this.isEmpty(this.requestName) || this.isEmpty(this.URL)){
                alert('Enter Request Name and URL to proceed.');
                return;
            }
        }
        console.log('saveRequest')
        this.createUpdateSavedRequest(dmlType);
    }

    //cross component event handlers

    //handler to get the custom event from saved requests[child] and close the modal screen
    closeSavedRequestModalHandler(){
        this.openSavedRequestSelectionModalFlag = false;
    }

    //handler to get the select savedrequest record - onclick of select in the savedrequestmodl window
    displaySelectedSavedRequestInformation(event){
        console.log('in displaySelectedSavedRequestInformation')
        this.closeSavedRequestModalHandler()
        var selectedRecord = JSON.parse(event.detail)
        console.log(selectedRecord)
        this.setRequestFieldsFromSelectedRequest(selectedRecord);
    }




    // helper method section //


    //Parse URL
    parseURLQueryParameter(event){
        console.log('parseURLQueryParameter');
        if(this.URL.indexOf('?')!=-1){
            for(let i of this.URL.slice(this.URL.indexOf('?')+1).split('&')){
                console.log('query pair '+i)
                let [key, value] = i.split('=');
                if(this.queryParameterList.length == 1 && !this.queryParameterList[0].key.trim() && !this.queryParameterList[0].value.trim()){
                    this.queryParameterList[0].key = key;
                    this.queryParameterList[0].value = value;
                    this.queryParameterList[0].shouldInclude = true;
                }else{
                    this.queryParameterList = this.queryParameterList.concat([
                        {
                            id:this.headerList.length,
                            type:"queryParameter",
                            'key':key,
                            'value':value,
                            shouldInclude:true
                        }
                    ])
                }
            }
            this.URL = this.URL.slice(0,this.URL.indexOf('?'))
            console.log('pareseURLQueryParameter '+this.URL);
        }        
    }

    //helper for handling post callout changes
    handleCalloutResponse(response,responseType,RequestInformationWrapper){
        var logObject = {};
        console.log(response)
        this.showSpinner=false;
        if(responseType=='error'){
            this.response = response.responseBody;
        }else{
            this.response = JSON.stringify(JSON.parse(response.responseBody),null,2);
        }

        this.updateResponseStatusOnUI(response);

        for(let i in response){
            console.log(i)
            logObject[i] = response[i];
        }

        let savedRequestwrapper = {
            requestName:this.requestName,
            requestId:this.id,
            transactionOrigin:'UI - Synchronous'
        };
        
        console.log(' logObject '+JSON.stringify(logObject));
        console.log(' savedRequestwrapper '+JSON.stringify(savedRequestwrapper));
        logAPITransaction({resWraper:logObject,requestWrapper:RequestInformationWrapper,savedReqwrapper:savedRequestwrapper});
    }




    // Insert/Update record.
    createUpdateSavedRequest(dmlType){
        // Creating mapping of fields of Account with values
        var fields = {'Request_Name__c' : this.requestName,
                'Header_Information__c' : JSON.stringify(this.headerList),
                'Query_Paramters__c':JSON.stringify(this.queryParameterList),
                'URL__c':this.URL,
                'Method_Type__c':this.methodType,
                'Request_Payload__c':this.request};
        // Record details to pass to create method with api name of Object.
        var objRecordInput = {'apiName' : 'Saved_Request__c', fields};
        // LDS method to create record.
        console.log('createUpdateSavedRequest');
        if(dmlType=='insert'){
            createRecord(objRecordInput).then(response => {
                this.id=response.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Request Inserted with id : '+response.id,
                        variant: 'success'
                    })
                );
            }).catch(error => {
                console.log('Error: ' +JSON.stringify(error));
            });
            
        }else{
            fields.Id=this.id;
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Request Updated',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.log(error);
            });
        }

        
    }


    setRequestFieldsFromSelectedRequest(selectedRecord){
        this.id = selectedRecord.Id;
        this.name = selectedRecord.Name;
        this.requestName = selectedRecord.Request_Name__c!=undefined?selectedRecord.Request_Name__c:'';
        this.URL = selectedRecord.URL__c;
        this.methodType = selectedRecord.Method_Type__c;
        this.setShowRequestForPostAttribute(this.methodType);   //to show the request payload box
        this.request = selectedRecord.Request_Payload__c;
        this.statusInformation = '';
        this.response='';
        if(selectedRecord.Header_Information__c!=undefined){
            this.headerList = JSON.parse(selectedRecord.Header_Information__c);
        }
        if(selectedRecord.Query_Paramters__c!=undefined){
            this.queryParameterList = JSON.parse(selectedRecord.Query_Paramters__c);
        }
        
    }

    setShowRequestForPostAttribute(methodType){
        if(methodType=="POST"){
            this.showRequestForPost=true;
        }else{
            this.showRequestForPost=false;
        }
    }

    addFieldset(type){
        if(type=="headerInformation"){
            this.headerList = this.headerList.concat([{id:this.headerList.length,type:"headerInformation",key:"",value:"",shouldInclude:false }])
        }else{
            this.queryParameterList = this.queryParameterList.concat([{id:this.headerList.length,type:"queryParameter",key:"",value:"",shouldInclude:false}])
        }
    }

    updateFieldSet(index,listToUpdate,key,value){
        listToUpdate.forEach(function(eachSet) {
            if (eachSet.id == index) {
                eachSet[key]=value;
            }
        });

        console.log("queryParameterList :"+JSON.stringify(this.queryParameterList));
        console.log("headerList :"+JSON.stringify(this.headerList));
    }

    //this method takes the response from the callout and dispalys
    //information such as {staus, status code}
    updateResponseStatusOnUI(result){
        this.statusInformation = 'Status : '+result.status+' | Status Code : '+result.statusCode+' | Time Elapsed : '+result.timeElapsed+'s';
    }

    //check truthy and falsy values
    isEmpty(e) {
        switch (e) {
          case "":
          case 0:
          case "0":
          case null:
          case false:
          case typeof(e) == "undefined":
            return true;
          default:
            return false;
        }
    }
}