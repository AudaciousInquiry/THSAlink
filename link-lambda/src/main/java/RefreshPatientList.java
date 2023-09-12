import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class RefreshPatientList implements RequestHandler<Void,String> {
    @Override
    public String handleRequest(Void unused, Context context) {
        return "";
    }
}
