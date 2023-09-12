import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.lantanagroup.link.auth.OAuth2Helper;
import com.lantanagroup.link.config.auth.LinkOAuthConfig;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpDelete;
import org.json.JSONObject;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;

public class ExpungeData implements RequestHandler<Void,String> {

    @Override
    public String handleRequest(Void unused, Context context) {
        LambdaLogger logger = context.getLogger();

        String returnValue = "";

        // TODO - secret name & region from ENV
        String secretName = System.getenv("SECRET_NAME"); // "expunge-data-testing";
        Region region = Region.of(System.getenv("AWS_REGION")); // "us-east-1"
        String expungeApiUrl = System.getenv("EXPUNGE_API_URL"); // "https://thsa1.sanerproject.org:10440/api/data/expunge";

        // Create a Secrets Manager client
        SecretsManagerClient client = SecretsManagerClient.builder()
                .region(region)
                .httpClient(ApacheHttpClient.create())
                .build();

        GetSecretValueRequest getSecretValueRequest = GetSecretValueRequest.builder()
                .secretId(secretName)
                .build();

        GetSecretValueResponse getSecretValueResponse;

        try {
            getSecretValueResponse = client.getSecretValue(getSecretValueRequest);
        } catch (Exception e) {
            // For a list of exceptions thrown, see
            // https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
            throw e;
        }

        String secret = getSecretValueResponse.secretString();

        JSONObject secretObject = new JSONObject(secret);

        // TODO - probably can find some better way to create this obj using the JSON from secrets manager
        LinkOAuthConfig authConfig = new LinkOAuthConfig();
        authConfig.setTokenUrl(secretObject.getString("token-url"));
        authConfig.setClientId(secretObject.getString("client-id"));
        authConfig.setClientSecret(secretObject.getString("client-secret"));
        authConfig.setUsername(secretObject.getString("username"));
        authConfig.setPassword(secretObject.getString("password"));
        authConfig.setScope(secretObject.getString("scope"));
        authConfig.setCredentialMode(secretObject.getString("credential-mode"));

        try {
            String token = OAuth2Helper.getToken(authConfig);
            if (token == null) {
                throw new Exception("Authorization failed");
            }
            HttpDelete request = new HttpDelete(expungeApiUrl);
            request.addHeader(HttpHeaders.AUTHORIZATION, String.format("Bearer %s", token));

            HttpResponse response = Utility.HttpExecuter(request, logger);
            logger.log(String.format("HTTP Response Code %s", response.getStatusLine().getStatusCode()));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        return returnValue;
    }
}
