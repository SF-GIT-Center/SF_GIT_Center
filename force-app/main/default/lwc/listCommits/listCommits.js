import { LightningElement, track } from 'lwc';
import listCommitsApex from '@salesforce/apex/GitHubService.listCommits';

export default class ListCommits extends LightningElement {
    @track repoName = '';
    @track commits = [];
    @track errorMessage = '';

    handleRepoNameChange(event) {
        this.repoName = event.target.value;
    }

    async getCommits() {
        if (!this.repoName) {
            this.errorMessage = 'Please enter a repository name.';
            return;
        }

        try {
            const result = await listCommitsApex({ repoName: this.repoName });
            this.commits = result;
            this.errorMessage = '';
        } catch (error) {
            this.errorMessage = 'Error fetching commits: ' + error.body.message;
            this.commits = [];
        }
    }
}
