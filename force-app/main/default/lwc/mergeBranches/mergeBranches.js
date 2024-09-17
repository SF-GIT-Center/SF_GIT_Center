import { LightningElement, track } from 'lwc';
import getRepoBranches from '@salesforce/apex/GitHubService.getRepoBranches';
import mergeBranchesApex from '@salesforce/apex/GitHubService.mergeBranches';

export default class MergeBranches extends LightningElement {
    @track repoName = '';
    @track baseBranch = '';
    @track headBranch = '';
    @track commitMessage = '';
    @track branchOptions = [];
    @track successMessage = '';
    @track errorMessage = '';

    handleRepoNameChange(event) {
        this.repoName = event.target.value;
        this.fetchBranches();
    }

    handleBaseBranchChange(event) {
        this.baseBranch = event.target.value;
    }

    handleHeadBranchChange(event) {
        this.headBranch = event.target.value;
    }

    handleCommitMessageChange(event) {
        this.commitMessage = event.target.value;
    }

    async fetchBranches() {
        try {
            const branches = await getRepoBranches({ repoName: this.repoName });
            this.branchOptions = branches.map(branch => {
                return { label: branch.name, value: branch.name };
            });
        } catch (error) {
            this.errorMessage = 'Error fetching branches: ' + error.body.message;
        }
    }

    async mergeBranches() {
        if (!this.repoName || !this.baseBranch || !this.headBranch || !this.commitMessage) {
            this.errorMessage = 'All fields are required';
            return;
        }

        try {
            const result = await mergeBranchesApex({
                repoName: this.repoName,
                base: this.baseBranch,
                head: this.headBranch,
                commitMessage: this.commitMessage
            });
            this.successMessage = result;
            this.errorMessage = '';
        } catch (error) {
            this.errorMessage = 'Error merging branches: ' + error.body.message;
            this.successMessage = '';
        }
    }
}
