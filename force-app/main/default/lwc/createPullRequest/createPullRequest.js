import { LightningElement, track } from 'lwc';
import getRepoBranches from '@salesforce/apex/GitHubService.getRepoBranches';
import createPullRequest from '@salesforce/apex/GitHubService.createPullRequest';

export default class CreatePullRequest extends LightningElement {
    @track repoName = '';
    @track title = '';
    @track body = '';
    @track headBranch = '';
    @track baseBranch = '';
    @track branchOptions = [];
    @track pullRequestUrl = ''; // Updated to track the PR URL
    @track errorMessage = '';

    handleRepoNameChange(event) {
        this.repoName = event.target.value;
        this.loadBranches();
    }

    handleTitleChange(event) {
        this.title = event.target.value;
    }

    handleBodyChange(event) {
        this.body = event.target.value;
    }

    handleHeadBranchChange(event) {
        this.headBranch = event.detail.value;
    }

    handleBaseBranchChange(event) {
        this.baseBranch = event.detail.value;
    }

    // Load branches for the selected repo
    loadBranches() {
        getRepoBranches({ repoName: this.repoName })
            .then((result) => {
                this.branchOptions = result.map(branch => {
                    return { label: branch.name, value: branch.name };
                });
            })
            .catch((error) => {
                this.errorMessage = 'Error fetching branches: ' + error.body.message;
            });
    }

    // Handle form submission to create Pull Request
    handleCreatePullRequest() {
        createPullRequest({
            repoName: this.repoName,
            title: this.title,
            body: this.body,
            head: this.headBranch,
            base: this.baseBranch
        })
            .then((result) => {
                this.pullRequestUrl = result; // Store the Pull Request URL
                this.errorMessage = '';
            })
            .catch((error) => {
                this.errorMessage = 'Error creating pull request: ' + error.body.message;
                this.pullRequestUrl = '';
            });
    }

    clearRecords() {
        this.repoName = '';
        this.title = '';
        this.body = '';
        this.headBranch = '';
        this.baseBranch = '';
        this.branchOptions = [];
        this.pullRequestUrl = ''; 
        this.errorMessage = '';
    }
}
