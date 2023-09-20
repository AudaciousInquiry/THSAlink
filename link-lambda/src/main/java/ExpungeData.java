import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.lantanagroup.link.config.auth.LinkOAuthConfig;
import com.lantanagroup.link.tasks.ExpungeDataTask;
import com.lantanagroup.link.tasks.config.ExpungeDataConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.regions.Region;

public class ExpungeData implements RequestHandler<Void,String> {

    private static final Logger logger = LoggerFactory.getLogger(ExpungeDataTask.class);
    @Override
    public String handleRequest(Void unused, Context context) {

        String returnValue = "";

        try {
            String secretName = System.getenv("API_AUTH_SECRET");
            Region region = Region.of(System.getenv("AWS_REGION"));
            String expungeApiUrl = System.getenv("API_ENDPOINT");

            LinkOAuthConfig authConfig = Utility.GetLinkOAuthConfigFromAwsSecrets(region, secretName);

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
