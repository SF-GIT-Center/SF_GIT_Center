public class GitOAuthHandler {
    
    // Method to refresh the GitHub access token
    public static String refreshAccessToken() {
        try {
            // Fetch custom setting values from the organization-wide defaults
            Git_Setup__c gitSetup = Git_Setup__c.getOrgDefaults();
            
            if (gitSetup == null || gitSetup.Client_Id__c == null || gitSetup.Client_Secret__c == null || gitSetup.Refresh_Token__c == null) {
                throw new CustomException('Missing required fields in Git_Setup__c custom setting.');
            }
            
            // Prepare the request URL
            String endpoint = 'https://github.com/login/oauth/access_token';
            
            // Set up the POST body with values from custom settings
            String clientId = gitSetup.Client_Id__c;
            String clientSecret = gitSetup.Client_Secret__c;
            String refreshToken = gitSetup.Refresh_Token__c;
            
            // Construct the POST body
            String requestBody = 'client_id=' + clientId + 
                '&client_secret=' + clientSecret + 
                '&grant_type=refresh_token' +
                '&refresh_token=' + refreshToken;
            
            // Create a new HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(requestBody);
            
            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Check for successful response
            if (res.getStatusCode() == 200) {
                // Parse the URL-encoded response body
                String responseBody = res.getBody();
                System.debug('Response: ' + responseBody);
                
                // Parse the response manually (URL-encoded response)
                Map<String, String> responseMap = parseUrlEncodedResponse(responseBody);
                
                // Get the access_token and refresh_token from the response
                String newAccessToken = responseMap.get('access_token');
                String newRefreshToken = responseMap.get('refresh_token');
                
                // Handle possible missing fields in response
                if (newAccessToken == null || newRefreshToken == null) {
                    throw new CustomException('Invalid response: Missing access_token or refresh_token in URL-encoded response.');
                }
                
                // Only update the custom setting if the refresh token has changed
                if (gitSetup.Refresh_Token__c != newRefreshToken) {
                    // Update the custom setting with the new refresh token
                    gitSetup.Refresh_Token__c = newRefreshToken;
                    upsert gitSetup; // Use upsert to update the custom setting once.
                }
                
                // Return the new access token
                return newAccessToken;
            } else {
                // Handle error response
                throw new CustomException('Failed to refresh access token. Status Code: ' + res.getStatusCode() + ' Response: ' + res.getBody());
            }
        } catch (Exception ex) {
            // Handle any exceptions
            System.debug('Exception: ' + ex.getMessage());
            throw new CustomException('Error occurred while refreshing access token: ' + ex.getMessage());
        }
    }

    // Custom exception class for error handling
    public class CustomException extends Exception {}

    // Helper method to parse URL-encoded response
    private static Map<String, String> parseUrlEncodedResponse(String responseBody) {
        Map<String, String> resultMap = new Map<String, String>();
        String[] keyValuePairs = responseBody.split('&');
        for (String keyValuePair : keyValuePairs) {
            String[] pair = keyValuePair.split('=');
            if (pair.size() == 2) {
                resultMap.put(pair[0], pair[1]);
            }
        }
        return resultMap;
    }
}
