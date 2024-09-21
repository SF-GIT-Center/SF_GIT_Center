import { LightningElement, track } from 'lwc';
import getLastCommitSHA from '@salesforce/apex/GitHubService.getLastCommitSHA';
import createBlob from '@salesforce/apex/GitHubService.createBlob';
import createTree from '@salesforce/apex/GitHubService.createTree';
import createCommit from '@salesforce/apex/GitHubService.createCommit';
import updateBranchReference from '@salesforce/apex/GitHubService.updateBranchReference';

export default class CreateCommit extends LightningElement {
    @track step = 1;
    @track repo = '';
    @track branchName = '';
    @track commitMessage = '';
    @track fileContent = '';
    @track resultMessage = '';

    repository = '';
    last_commit_sha = '';
    base64_blob_sha = '';
    tree_sha = '';
    new_commit_sha = '';

    // Step getters for conditional rendering in HTML
    get isStep1() {
        return this.step === 1;
    }

    get isStep2() {
        return this.step === 2;
    }

    get isStep3() {
        return this.step === 3;
    }

    get isStep4() {
        return this.step === 4;
    }

    get isStep5() {
        return this.step === 5;
    }

    get isStep6() {
        return this.step === 6;
    }

    handleRepoChange(event) {
        this.repo = event.target.value;
    }

    handleBranchChange(event) {
        this.branchName = event.target.value;
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        const reader = new FileReader();
        reader.onload = () => {
            this.fileContent = reader.result.split(',')[1]; 
        };
        reader.readAsDataURL(file);
    }

    handleCommitMessageChange(event) {
        this.commitMessage = event.target.value;
    }

    handleNext() {
        if (this.step === 1) {
            getLastCommitSHA({ repo: this.repo, branchName: this.branchName })
                .then(result => {
                    this.last_commit_sha = result;
                    this.repository = this.repo;
                    this.step = 2;
                })
                .catch(error => {
                    this.resultMessage = 'Error fetching last commit: ' + error.body.message;
                });
        } else if (this.step === 2) {
            createBlob({ repo: this.repository, content: this.fileContent })
                .then(result => {
                    this.base64_blob_sha = result;
                    this.step = 3;
                })
                .catch(error => {
                    this.resultMessage = 'Error creating blob: ' + error.body.message;
                });
        } else if (this.step === 3) {
            const tree = [
                {
                    path: 'Logos/SF.jpg',
                    mode: '100644',
                    type: 'blob',
                    sha: this.base64_blob_sha
                }
            ];
            createTree({ repo: this.repository, baseTreeSha: this.last_commit_sha, tree: tree })
                .then(result => {
                    this.tree_sha = result;
                    this.step = 4;
                })
                .catch(error => {
                    this.resultMessage = 'Error creating tree: ' + error.body.message;
                });
        } else if (this.step === 4) {
            createCommit({
                repo: this.repository,
                message: this.commitMessage,
                parentSha: this.last_commit_sha,
                treeSha: this.tree_sha
            })
                .then(result => {
                    this.new_commit_sha = result;
                    this.step = 5;
                })
                .catch(error => {
                    this.resultMessage = 'Error creating commit: ' + error.body.message;
                });
        } else if (this.step === 5) {
            updateBranchReference({
                repo: this.repository,
                branch: 'main',
                commitSha: this.new_commit_sha
            })
                .then(result => {
                    this.resultMessage = 'Success: ' + result;
                    this.step = 6;
                })
                .catch(error => {
                    this.resultMessage = 'Error updating branch reference: ' + error.body.message;
                });
        }
    }
}
