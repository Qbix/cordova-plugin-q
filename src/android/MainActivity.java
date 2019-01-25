package <packaged>;
import com.q.cordova.plugin.QActivity;


public class MainActivity extends QActivity
{
    @Override
    public boolean isTestMode() {
        return BuildConfig.DEBUG;;
    }
}