import { LightningElement, track } from 'lwc';
import listPullRequestCommits from '@salesforce/apex/GitHubService.listPullRequestCommits';

export default class PullRequestCommits extends LightningElement {
    @track commits;      // Holds the commits data
    @track isLoading = false;
    @track error;

    repoName = '';       // Repository name entered by user
    pullNumber = '';     // Pull request number entered by user

    // Handle repository name change
    handleRepoNameChange(event) {
        this.repoName = event.target.value;
    }

    // Handle pull request number change
    handlePullNumberChange(event) {
        this.pullNumber = event.target.value;
    }

    // Fetch commits from the GitHub API
    fetchPullRequestCommits() {
        if (this.repoName === '' || this.pullNumber === '') {
            this.error = 'Please enter both repository name and pull request number.';
            return;
        }

        this.isLoading = true;
        this.error = null;
        this.commits = null;

        listPullRequestCommits({ repoName: this.repoName, pullNumber: parseInt(this.pullNumber) })
            .then(result => {
                this.commits = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.error = 'Error fetching commits: ' + error.body.message;
                this.isLoading = false;
            });
    }
}
