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
    file = null;  // Ensure file is initialized as null to store the selected file

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

    // Handle repository input change
    handleRepoChange(event) {
        this.repo = event.target.value;
    }

    // Handle branch input change
    handleBranchChange(event) {
        this.branchName = event.target.value;
    }

    // Handle file selection
    handleFileChange(event) {
        this.file = event.target.files[0];  // Use this.file to store the selected file

        const reader = new FileReader();
        reader.onload = () => {
            this.fileContent = reader.result.split(',')[1];  // Base64 encoding of file content
        };

        if (this.file) {
            reader.readAsDataURL(this.file);  // Read file if available
        } else {
            this.resultMessage = 'No file selected.';
        }
    }

    // Handle commit message input change
    handleCommitMessageChange(event) {
        this.commitMessage = event.target.value;
    }

    // Handle next button click and step processing
    handleNext() {
        if (this.step === 1) {
            // Step 1: Get last commit SHA
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
            // Step 2: Create blob with file content
            createBlob({ repo: this.repository, content: this.fileContent })
                .then(result => {
                    this.base64_blob_sha = result;
                    this.step = 3;
                })
                .catch(error => {
                    this.resultMessage = 'Error creating blob: ' + error.body.message;
                });
        } else if (this.step === 3) {
            // Step 3: Create tree using the file name
            const fileName = this.file ? this.file.name : 'default_file.txt';  
            console.log('File Name:', fileName);  
            let path = `${fileName}`;
            console.log('path:', path);

            const tree = [
                {
                    path: path,  
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
            // Step 4: Create commit with the tree SHA
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
            // Step 5: Update branch reference
            updateBranchReference({
                repo: this.repository,
                branch: `${this.branchName}`,  
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
