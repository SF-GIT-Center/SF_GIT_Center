import { LightningElement, track } from 'lwc';
import getRepoBranches from '@salesforce/apex/GitHubService.getRepoBranches';

export default class BranchDetails extends LightningElement {
    @track repoName = '';
    @track branches;
    @track error = false;
    @track errorMessage = '';

    handleInputChange(event) {
        this.repoName = event.target.value;
    }

    clearRecords() {
        this.repoName = '';
        this.branches = null;
    }

    async fetchBranches() {
        if (!this.repoName) {
            this.error = true;
            this.errorMessage = 'Repository name is required';
            return;
        }

        this.error = false;
        this.errorMessage = '';
        this.branches = null;

        try {
            const result = await getRepoBranches({ repoName: this.repoName });
            this.branches = result;
        } catch (error) {
            this.error = true;
            this.errorMessage = 'Error fetching branches: ' + error.body.message;
        }
    }
}
