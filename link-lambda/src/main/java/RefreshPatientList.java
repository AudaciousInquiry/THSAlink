import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class RefreshPatientList implements RequestHandler<Void,String> {
    @Override
    public String handleRequest(Void unused, Context context) {
        String returnValue = "";

        try {

            // Read API Auth from Secrets

            // Read EPIC Query information from Secrets

            // Read RefreshPatientList configuration from Secrets

        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }

        return returnValue;
    }
}
