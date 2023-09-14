import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.lantanagroup.link.config.auth.LinkOAuthConfig;
import com.lantanagroup.link.tasks.ExpungeDataTask;
import com.lantanagroup.link.tasks.config.ExpungeDataConfig;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;


public class ExpungeData implements RequestHandler<Void,String> {

    private static final Logger logger = LoggerFactory.getLogger(ExpungeDataTask.class);
    @Override
    public String handleRequest(Void unused, Context context) {

        String returnValue = "";

        try {
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

            getSecretValueResponse = client.getSecretValue(getSecretValueRequest);

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


            ExpungeDataConfig config = new ExpungeDataConfig();
            config.setApiUrl(expungeApiUrl);
            config.setAuth(authConfig);

            ExpungeDataTask.RunExpungeDataTask(config);
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }

        return returnValue;
    }
}
