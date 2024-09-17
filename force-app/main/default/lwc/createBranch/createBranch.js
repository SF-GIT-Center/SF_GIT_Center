import { LightningElement, track } from 'lwc';
import createBranch from '@salesforce/apex/GitHubService.createBranch';

export default class CreateBranch extends LightningElement {
    @track repoName = '';
    @track newBranchName = '';
    @track sha = '';
    @track successMessage = '';
    @track errorMessage = '';

    // Handle repository name input
    handleRepoNameChange(event) {
        this.repoName = event.target.value;
    }

    // Handle branch name input
    handleBranchNameChange(event) {
        this.newBranchName = event.target.value;
    }

    // Handle SHA input
    handleShaChange(event) {
        this.sha = event.target.value;
    }

    // Method to create the branch
    createBranch() {
        if (this.repoName && this.newBranchName && this.sha) {
            // Call Apex method
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
}
