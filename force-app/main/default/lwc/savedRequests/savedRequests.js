import { LightningElement, track, wire } from 'lwc';
import getSavedRequests from '@salesforce/apex/SavedRequestsController.getSavedRequests';
export default class SavedRequests extends LightningElement {

    searchKey = '';
    @track requestList = [];
    showSpinner = true;

    @wire(getSavedRequests, { searchKey: '$searchKey' })
    getRequests({error,data}){
        if(data!=null){
            this.requestList = data;
            console.log(data);
            this.showSpinner=false;
        }else{
            console.log(error);
            this.showSpinner=false;
        }
    };

    handleKeyChange(event) {
        console.log('handleKeyChange')
        this.searchKey = event.target.value;
    }

    //firing an event to pass the selected requests info
    sendSelectedSavedRequestInformation(event){
        var selectedRequest;
        var uniqueIdentifier = event.currentTarget.dataset.id;
        var selectedSavedRequestObject = {};
        console.log(uniqueIdentifier);
        for (const record of this.requestList) {
            console.log('record '+record)
            if(record.Id==uniqueIdentifier){
                console.log('inside if')
                selectedSavedRequestObject = record;
                break;
            }
        }
        console.log(selectedSavedRequestObject['Method_Type__c']);
        const sendSelectedSavedRequestEvent = new CustomEvent('selectedsavedrequestinformation',{detail:JSON.stringify(selectedSavedRequestObject)});
        this.dispatchEvent(sendSelectedSavedRequestEvent);
    }

    //firing an event to let the parent component know that the visibility of modal is not necessary
    closeSavedRequestModal(event){
        this.dispatchEvent(new CustomEvent('closesavedrequestmodal'));
    }

}