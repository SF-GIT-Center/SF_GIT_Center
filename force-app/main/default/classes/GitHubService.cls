public class GitHubService {
    
    // Method to get all repositories from a specific organization on GitHub
    @AuraEnabled(cacheable=true)
    public static List<GitHubRepository> getOrgRepositories() {
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('Access Token: '+ accessToken);
            
            // Prepare the GitHub API request
            String orgName = 'SF-GIT-Center'; 
            String endpoint = 'https://api.github.com/orgs/' + orgName + '/repos';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Accept', 'application/vnd.github.v3+json');
            
            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Check for successful response
            if (res.getStatusCode() == 200) {
                List<GitHubRepository> repos = new List<GitHubRepository>();
                System.debug('Response: '+ res.getBody());
                
                // Deserialize the response
                List<Object> responseList = (List<Object>) JSON.deserializeUntyped(res.getBody());
                
                // Extract the specific details: name, private, description
                for (Object obj : responseList) {
                    Map<String, Object> repoMap = (Map<String, Object>) obj;
                    GitHubRepository repo = new GitHubRepository();
                    repo.name = (String) repoMap.get('name');
                    repo.isPrivate = (Boolean) repoMap.get('private');
                    repo.description = (String) repoMap.get('description');
                    repos.add(repo);
                }
                System.debug('Repos: '+ repos);
                return repos; 
            } else {
                throw new CustomException('Failed to retrieve repositories. Status Code: ' + res.getStatusCode());
            }
        } catch (Exception ex) {
            throw new CustomException('Error occurred while retrieving repositories: ' + ex.getMessage());
        }
    }
    
    // Define a class to store GitHub repository details
    public class GitHubRepository {
        @AuraEnabled public String name;
        @AuraEnabled public Boolean isPrivate;
        @AuraEnabled public String description;
    }
    
    // Custom exception class
    public class CustomException extends Exception {}
}