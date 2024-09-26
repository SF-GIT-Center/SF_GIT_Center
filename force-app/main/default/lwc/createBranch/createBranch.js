import { LightningElement, track } from 'lwc';
import createBranch from '@salesforce/apex/GitHubService.createBranch';

export default class CreateBranch extends LightningElement {
    @track repoName = '';
    @track newBranchName = '';
    @track sha = '';
    @track successMessage = '';
    @track errorMessage = '';

    handleRepoNameChange(event) {
        this.repoName = event.target.value;
    }

    handleBranchNameChange(event) {
        this.newBranchName = event.target.value;
    }

    handleShaChange(event) {
        this.sha = event.target.value;
    }

    createBranch() {
        if (this.repoName && this.newBranchName && this.sha) {
            createBranch({ repoName: this.repoName, newBranchName: this.newBranchName, sha: this.sha })
                .then(result => {
                    this.successMessage = result;
                    this.errorMessage = '';
                })
                .catch(error => {
                    this.errorMessage = 'Error creating branch: ' + error.body.message;
                    this.successMessage = '';
                });
        } else {
            this.errorMessage = 'Please fill in all fields.';
            this.successMessage = '';
        }
    }

    clearRecords() {
        this.repoName = '';
        this.newBranchName = '';
        this.sha = '';
        this.successMessage = '';
        this.errorMessage = '';
    }
}
