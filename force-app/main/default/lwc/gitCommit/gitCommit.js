import { LightningElement, track } from 'lwc';
import getLastCommitSHA from '@salesforce/apex/GitHubCommitController.getLastCommitSHA';
import createBlob from '@salesforce/apex/GitHubCommitController.createBlob';
import createTree from '@salesforce/apex/GitHubCommitController.createTree';
import createCommit from '@salesforce/apex/GitHubCommitController.createCommit';
import updateBranchReference from '@salesforce/apex/GitHubCommitController.updateBranchReference';

export default class GitCommit extends LightningElement {
    @track selectedFile;
    @track fileContentBase64;
    @track lastCommitSha;
    @track repoName = '';
    @track branchName = '';
    @track newBranchName = '';
    @track sha = '';
    
    handleFileChange(event) {
        const file = event.target.files[0];
        const reader = new FileReader();
        reader.onload = () => {
            this.fileContentBase64 = btoa(reader.result); // Convert to base64
        };
        reader.readAsBinaryString(file); // Read file as binary string
        this.selectedFile = file.name;
    }

    async createCommit() {
        try {
            const owner = 'SF-GIT-Center'; // Define your owner (organization or username)
            const repo = this.repoName;
            const branch = this.branchName;
            
            // Step 1: Get the last commit SHA
            this.lastCommitSha = await getLastCommitSHA({ owner, repo, branchName: branch });

            // Step 2: Create the blob with the file content
            const blobSha = await createBlob({ owner, repo, content: this.fileContentBase64, encoding: 'base64' });

            // Step 3: Create a tree
            const tree = [{
                path: `myfolder/${this.selectedFile}`,
                mode: '100644',
                type: 'blob',
                sha: blobSha
            }];
            const treeSha = await createTree({ owner, repo, baseTreeSha: this.lastCommitSha, tree });

            // Step 4: Create a commit
            const message = 'Add new files';
            const authorName = 'Your Name';
            const authorEmail = 'your.email@example.com';
            const newCommitSha = await createCommit({ 
                owner, repo, message, authorName, authorEmail, parentSha: this.lastCommitSha, treeSha
            });

            // Step 5: Update the branch reference
            const result = await updateBranchReference({ owner, repo, branch: this.newBranchName, commitSha: newCommitSha });
            console.log(result);
            alert('Commit created successfully!');

        } catch (error) {
            console.error(error);
            alert('Error creating commit: ' + error.message);
        }
    }
}
