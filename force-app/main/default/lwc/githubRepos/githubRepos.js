import { LightningElement, wire, track } from 'lwc';
import getOrgRepositories from '@salesforce/apex/GitHubService.getOrgRepositories';

export default class GithubRepos extends LightningElement {
    @track repositories = []; // Track repositories to detect changes
    @track error; // Track errors

    // Wire the Apex method to fetch repositories
    @wire(getOrgRepositories)
    wiredRepositories({ error, data }) {
        if (data) {
            this.processRepositories(data); // Process repository data
            this.error = undefined;
        } else if (error) {
            this.handleError(error); // Handle the error
        }
    }

    // Process the repository data to handle missing descriptions and private status
    processRepositories(data) {
        this.repositories = data.map(repo => {
            return {
                ...repo,
                description: repo.description ? repo.description : 'No description available',
                privateLabel: repo.isPrivate ? 'Yes' : 'No' // Prepare label for private status
            };
        });
    }

    // Handle errors from the server or network
    handleError(error) {
        this.error = error;
        this.repositories = [];
        console.error('Error fetching repositories:', error);
    }

    // Getter to determine if repositories are available
    get hasRepositories() {
        return this.repositories.length > 0;
    }

    // Getter to show loading state when no repositories and no errors
    get isLoading() {
        return !this.hasRepositories && !this.error;
    }
}
