public class GitHubService {

    // Method to get all repositories from a specific organization on GitHub
    @AuraEnabled(cacheable=true)
    public static List<GitHubRepository> getOrgRepositories() {
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);

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

    @AuraEnabled
    public static String createRepository(String name, String description, Boolean isPrivate, Boolean isTemplate, String visibility) {
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);
            
            // Prepare the GitHub API endpoint for creating a new repository
            String orgName = 'SF-GIT-Center'; 
            String endpoint = 'https://api.github.com/orgs/' + orgName + '/repos';
            
            // Set up the POST request body
            Map<String, Object> requestBody = new Map<String, Object>{
                'name' => name,
                'description' => description,
                'private' => isPrivate,
                'is_template' => isTemplate,
                'visibility' => visibility
            };
            
            // Convert the request body to JSON
            String requestBodyJson = JSON.serialize(requestBody);
            
            // Set up the HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBodyJson);

            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Check for a successful response
            if (res.getStatusCode() == 201) {
                System.debug('Repository Created Successfully');
                return 'Repository Created Successfully';
            } else {
                throw new CustomException('Failed to create repository. Status Code: ' + res.getStatusCode() + ' Response: ' + res.getBody());
            }
        } catch (Exception ex) {
            throw new CustomException('Error occurred while creating repository: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<GitHubBranch> getRepoBranches(String repoName) {
        try {  
             // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);
                     
            // Prepare the GitHub API request
            String owner = 'SF-GIT-Center'; 
            String endpoint = 'https://api.github.com/repos/' + owner + '/' + repoName + '/branches';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Accept', 'application/vnd.github.v3+json');
            
            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Check for a successful response
            if (res.getStatusCode() == 200) {
                List<GitHubBranch> branches = new List<GitHubBranch>();
                System.debug('Response: ' + res.getBody());
                
                // Deserialize the response into a list of branches
                List<Object> responseList = (List<Object>) JSON.deserializeUntyped(res.getBody());
                
                // Iterate through the response and map the branch details
                for (Object obj : responseList) {
                    Map<String, Object> branchMap = (Map<String, Object>) obj;
                    GitHubBranch branch = new GitHubBranch();
                    branch.name = (String) branchMap.get('name');
                    
                    // Extract the commit details
                    Map<String, Object> commitMap = (Map<String, Object>) branchMap.get('commit');
                    branch.commitSha = (String) commitMap.get('sha');
                    branch.commitUrl = (String) commitMap.get('url');
                    
                    branch.isProtected = (Boolean) branchMap.get('protected');
                    branches.add(branch);
                }
                
                return branches; 
            } else {
                throw new CustomException('Failed to retrieve branches. Status Code: ' + res.getStatusCode());
            }
        } catch (Exception ex) {
            throw new CustomException('Error occurred while retrieving branches: ' + ex.getMessage());
        }
    }
    
    // Define a class to store GitHub branch details
    public class GitHubBranch {
        @AuraEnabled public String name;
        @AuraEnabled public String commitSha;
        @AuraEnabled public String commitUrl;
        @AuraEnabled public Boolean isProtected;
    }

    @AuraEnabled
    public static String mergeBranches(String repoName, String base, String head, String commitMessage) {
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);
            
            // Prepare the GitHub API request for merging branches
            String owner = 'SF-GIT-Center';
            String endpoint = 'https://api.github.com/repos/' + owner + '/' + repoName + '/merges';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Accept', 'application/vnd.github.v3+json');
            req.setHeader('Content-Type', 'application/json');
            
            // Create the request body
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('base', base);
            requestBody.put('head', head);
            requestBody.put('commit_message', commitMessage);
            
            String body = JSON.serialize(requestBody);
            req.setBody(body);
            
            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Check for a successful response
            if (res.getStatusCode() == 201) {
                System.debug('Merge successful: ' + res.getBody());
                return 'Merge successful!';
            } else {
                System.debug('Failed to merge branches: ' + res.getBody());
                throw new CustomException('Failed to merge branches. Status Code: ' + res.getStatusCode() + ' Response: ' + res.getBody());
            }
        } catch (Exception ex) {
            throw new CustomException('Error occurred while merging branches: ' + ex.getMessage());
        }
    }

    // listCommits use to list commits of the Repo
    @AuraEnabled
    public static List<Object> listCommits(String repoName) {
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);
            
            // Set up the request to GitHub API
            String owner = 'SF-GIT-Center';
            String endpoint = 'https://api.github.com/repos/' + owner + '/' + repoName + '/commits';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Accept', 'application/vnd.github.v3+json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                List<Object> commitsList = (List<Object>) JSON.deserializeUntyped(res.getBody());
                return commitsList;
            } else {
                throw new CustomException('Error fetching commits. Status Code: ' + res.getStatusCode() + ' Response: ' + res.getBody());
            }

        } catch (Exception ex) {
            throw new CustomException('Error: ' + ex.getMessage());
        }
    }

    // createPullRequest method create Pull Request 
    @AuraEnabled
    public static String createPullRequest(String repoName, String title, String body, String head, String base) {
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);
            
            // Set up the request URL and headers
            String endpoint = 'https://api.github.com/repos/SF-GIT-Center/' + repoName + '/pulls';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');
            
            // Prepare the request body
            Map<String, Object> bodyMap = new Map<String, Object>();
            bodyMap.put('title', title);
            bodyMap.put('body', body);
            bodyMap.put('head', head);
            bodyMap.put('base', base);
            
            // Convert request body to JSON
            req.setBody(JSON.serialize(bodyMap));
            
            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Check for successful response
            if (res.getStatusCode() == 201) {
                // Parse the response body to extract the Pull Request URL (html_url)
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String pullRequestUrl = (String) responseBody.get('html_url');
                return pullRequestUrl;
            } else {
                throw new CustomException('Failed to create pull request. Status Code: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception ex) {
            throw new CustomException('Error occurred while creating pull request: ' + ex.getMessage());
        }
    }
    
    // listPullRequests method use to List Pull Requests
    @AuraEnabled
    public static List<Map<String, Object>> listPullRequests(String repoName) {
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);
            
            // Set up the request URL and headers
            String endpoint = 'https://api.github.com/repos/SF-GIT-Center/' + repoName + '/pulls';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');
            
            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Deserialize the response into a List<Object>
                List<Object> rawPullRequests = (List<Object>) JSON.deserializeUntyped(res.getBody());
                
                // Convert the List<Object> to List<Map<String, Object>>
                List<Map<String, Object>> pullRequests = new List<Map<String, Object>>();
                
                for (Object obj : rawPullRequests) {
                    pullRequests.add((Map<String, Object>) obj);
                }
                System.debug('pullRequests: '+ pullRequests);
                return pullRequests;
            } else {
                throw new CustomException('Failed to retrieve pull requests. Status Code: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception ex) {
            throw new CustomException('Error occurred while fetching pull requests: ' + ex.getMessage());
        }
    }

    // Method to list commits in a specific pull request
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> listPullRequestCommits(String repoName, Integer pullNumber) {
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);
            System.debug('repoName: '+ repoName);
            System.debug('pullNumber: '+ pullNumber);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            // Prepare the GitHub API endpoint
            String endPoint = 'https://api.github.com/repos/SF-GIT-Center/' + repoName + '/pulls/' + pullNumber + '/commits';
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Type', 'application/json');

            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Parse the response body
                System.debug('Status code: '+ response.getStatusCode());
                List<Object> commits = (List<Object>) JSON.deserializeUntyped(response.getBody());
                List<Map<String, Object>> commitList = new List<Map<String, Object>>();
                
                for (Object commitObject : commits) {
                    Map<String, Object> commitMap = (Map<String, Object>) commitObject;
                    commitList.add(commitMap);
                }
                System.debug('Commit List: '+commitList);
                return commitList;
            } else {
                throw new AuraHandledException('Error occurred while fetching commits: ' + response.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching commits: ' + e.getMessage());
        }
    }

    // createBranch method use to create a branch on GitHub
    @AuraEnabled
    public static String createBranch(String repoName, String newBranchName, String sha) {
        
        try {
            // Get the access token from the refreshAccessToken method
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            String accessToken = gitSetup.Access_Token__c;
            System.debug('accessToken: '+accessToken);
            System.debug('repoName: '+repoName);
            System.debug('newBranchName: '+newBranchName);
            System.debug('sha: '+sha);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            // GitHub API endpoint for creating a branch
            String endPoint = 'https://api.github.com/repos/SF-GIT-Center/' + repoName + '/git/refs';
            request.setEndpoint(endPoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Type', 'application/json');
            
            // Create the request body
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('ref', 'refs/heads/' + newBranchName);
            requestBody.put('sha', sha); 
            String body = JSON.serialize(requestBody);
            request.setBody(body);

            HttpResponse response = http.send(request);
            
            System.debug('Response Code: '+ response.getStatusCode());
            // If successful, return success message
            if (response.getStatusCode() == 201) {
                System.debug('Response Code: '+ response.getStatusCode());
                return 'Branch created successfully!';
            } else {
                throw new AuraHandledException('Error occurred while creating branch: ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error creating branch: ' + e.getMessage());
        }
    }

    // Method to get last commit SHA from a branch
    @AuraEnabled
    public static String getLastCommitSHA(String repo, String branchName) {
        // Get the access token from the refreshAccessToken method
        Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
        String accessToken = gitSetup.Access_Token__c;
        System.debug('accessToken: '+accessToken);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPoint = 'https://api.github.com/repos/SF-GIT-Center/' + repo + '/branches/' + branchName;
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Response Body: '+ response.getBody());
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> commitWrapper = (Map<String, Object>) result.get('commit');
                String sha = (String) commitWrapper.get('sha');
                return sha;
            } else {
                throw new AuraHandledException('Error getting last commit SHA: ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error getting last commit SHA: ' + e.getMessage());
        }
    }

    // method to create blob
    @AuraEnabled
    public static String createBlob(String repo, String content, String encoding) {
        // Get the access token from the refreshAccessToken method
        Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
        String accessToken = gitSetup.Access_Token__c;
        System.debug('accessToken: '+accessToken);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPoint = 'https://api.github.com/repos/SF-GIT-Center/' + repo + '/git/blobs';
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> body = new Map<String, Object>();
        body.put('content', content);
        body.put('encoding', encoding);
        
        try {
            request.setBody(JSON.serialize(body));
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 201) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return (String) result.get('sha');
            } else {
                throw new AuraHandledException('Error creating blob: ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error creating blob: ' + e.getMessage());
        }
    }

    // createTree method create treee structure in GIT
    @AuraEnabled
    public static String createTree(String repo, String baseTreeSha, List<Map<String, Object>> tree) {
        // Get the access token from the refreshAccessToken method
        Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
        String accessToken = gitSetup.Access_Token__c;
        System.debug('accessToken: '+accessToken);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPoint = 'https://api.github.com/repos/SF-GIT-Center/' + repo + '/git/trees';
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> body = new Map<String, Object>();
        body.put('base_tree', baseTreeSha);
        body.put('tree', tree);
        
        try {
            request.setBody(JSON.serialize(body));
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 201) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return (String) result.get('sha');
            } else {
                throw new AuraHandledException('Error creating tree: ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error creating tree: ' + e.getMessage());
        }
    }

    // createCommit method create Commit object in GIT
    @AuraEnabled
    public static String createCommit(String repo, String message, String authorName, String authorEmail, String parentSha, String treeSha) {
        // Get the access token from the refreshAccessToken method
        Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
        String accessToken = gitSetup.Access_Token__c;
        System.debug('accessToken: '+accessToken);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPoint = 'https://api.github.com/repos/SF-GIT-Center/' + repo + '/git/commits';
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> body = new Map<String, Object>();
        body.put('message', message);
        Map<String, String> author = new Map<String, String>();
        author.put('name', authorName);
        author.put('email', authorEmail);
        body.put('author', author);
        body.put('parents', new List<String>{parentSha});
        body.put('tree', treeSha);
        
        try {
            request.setBody(JSON.serialize(body));
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 201) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return (String) result.get('sha');
            } else {
                throw new AuraHandledException('Error creating commit: ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error creating commit: ' + e.getMessage());
        }
    }
    
    // updateBranchReference method update the reference of the branch
    @AuraEnabled
    public static String updateBranchReference(String owner, String repo, String branch, String commitSha) {
        // Get the access token from the refreshAccessToken method
        Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
        String accessToken = gitSetup.Access_Token__c;
        System.debug('accessToken: '+accessToken);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endPoint = 'https://api.github.com/repos/SF-GIT-Center/' + repo + '/git/refs/heads/' + branch;
        request.setEndpoint(endPoint);
        request.setMethod('PATCH');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> body = new Map<String, Object>();
        body.put('sha', commitSha);
        
        try {
            request.setBody(JSON.serialize(body));
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return 'Branch reference updated successfully';
            } else {
                throw new AuraHandledException('Error updating branch reference: ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating branch reference: ' + e.getMessage());
        }
    }

    // Custom exception class
    public class CustomException extends Exception {}
}