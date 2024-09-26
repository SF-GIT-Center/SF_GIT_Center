import { LightningElement, track } from 'lwc';
import createRepositoryApex from '@salesforce/apex/GitHubService.createRepository';

export default class CreateRepository extends LightningElement {
    @track repoName = '';
    @track description = '';
    @track isPrivate = false;
    @track isTemplate = false;
    @track visibility = 'public';

    @track showSuccessMessage = false;
    @track successMessage = '';
    @track error = false;
    @track errorMessage = '';

    visibilityOptions = [
        { label: 'Public', value: 'public' },
        { label: 'Private', value: 'private' }
    ];

    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'repoName') {
            this.repoName = event.target.value;
        } else if (field === 'description') {
            this.description = event.target.value;
        } else if (field === 'isPrivate') {
            this.isPrivate = event.target.checked;
        } else if (field === 'isTemplate') {
            this.isTemplate = event.target.checked;
        } else if (field === 'visibility') {
            this.visibility = event.target.value;
        }
    }

    clearRecords() {
        this.repoName = '';
        this.description = '';
        this.isPrivate = false;
        this.isTemplate = false;
        this.visibility = 'public';
    }

    async createRepository() {
        this.showSuccessMessage = false;
        this.error = false;
        
        if (!this.repoName) {
            this.error = true;
            this.errorMessage = 'Repository name is required';
            return;
        }

        try {
            const result = await createRepositoryApex({
                name: this.repoName,
                description: this.description,
                isPrivate: this.isPrivate,
                isTemplate: this.isTemplate,
                visibility: this.visibility
            });
            this.successMessage = result;
            this.showSuccessMessage = true;
        } catch (error) {
            this.error = true;
            this.errorMessage = 'Error occurred while creating repository: ' + error.body.message;
        }
    }
}
