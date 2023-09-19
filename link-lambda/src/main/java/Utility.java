import com.amazonaws.services.lambda.runtime.LambdaLogger;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;
import software.amazon.awssdk.regions.Region;

// TODO - do we need this?

import java.io.IOException;

public class Utility {

    public static HttpResponse HttpExecuter(HttpUriRequest request, LambdaLogger logger) throws IOException {
        CloseableHttpClient httpClient = HttpClients.createDefault();
        return httpClient.execute(request, response -> {
            HttpEntity entity = response.getEntity();
            if (entity != null) {
                String body = EntityUtils.toString(entity);
                if (StringUtils.isNotEmpty(body)) {
                    logger.log(body);
                }
            }
            return response;
        });
    }

    public static JSONObject GetAwsSecretAsJson(Region region, String secretName) {

        GetSecretValueResponse getSecretValueResponse;
        try (SecretsManagerClient client = SecretsManagerClient.builder()
                .region(region)
                .httpClient(ApacheHttpClient.create())
                .build()) {

            GetSecretValueRequest getSecretValueRequest = GetSecretValueRequest.builder()
                    .secretId(secretName)
                    .build();

            getSecretValueResponse = client.getSecretValue(getSecretValueRequest);
        }

        String secret = getSecretValueResponse.secretString();

        return new JSONObject(secret);

    }
}
