import { LightningElement, track } from 'lwc';
import listPullRequests from '@salesforce/apex/GitHubService.listPullRequests';

export default class PullRequestList extends LightningElement {
    @track pullRequests;
    @track isLoading = false;
    @track error;
    repoName = ''; // Dynamically updated based on user input

    // Handler for input change
    handleRepoNameChange(event) {
        this.repoName = event.target.value;
    }

    // Fetch pull requests
    fetchPullRequests() {
        if (this.repoName === '') {
            this.error = 'Please enter a repository name';
            return;
        }

        this.isLoading = true;
        this.error = null;
        this.pullRequests = null;

        listPullRequests({ repoName: this.repoName })
            .then(result => {
                this.pullRequests = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.error = 'Error fetching pull requests: ' + error.body.message;
                this.isLoading = false;
            });
    }
}
