package <packaged>;

import android.os.Bundle;
import androidx.test.InstrumentationRegistry;
import androidx.test.rule.ActivityTestRule;
import androidx.test.runner.AndroidJUnit4;
import android.util.DisplayMetrics;

import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import androidx.test.espresso.Espresso;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.UiAutomatorScreenshotStrategy;
import tools.fastlane.screengrab.locale.LocaleTestRule;
import tools.fastlane.screengrab.locale.LocaleUtil;

@RunWith(AndroidJUnit4.class)
public class MainActivityTest {

    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityTestRule<MainActivity> mActivityTestRule = new ActivityTestRule<MainActivity>(MainActivity.class) {
        @Override
        protected void beforeActivityLaunched() {
            MainActivity.setAndroidTestMode(true);
            super.beforeActivityLaunched();
        }
    };

    public boolean isTablet() {
        DisplayMetrics metrics = new DisplayMetrics();
        mActivityTestRule.getActivity().getWindowManager().getDefaultDisplay().getMetrics(metrics);

        float yInches= metrics.heightPixels/metrics.ydpi;
        float xInches= metrics.widthPixels/metrics.xdpi;
        double diagonalInches = Math.sqrt(xInches*xInches + yInches*yInches);
        return diagonalInches>=6.5;
    }

    @Test
    public void mainActivityTest() {
        Screengrab.setDefaultScreenshotStrategy(new UiAutomatorScreenshotStrategy());

        Bundle extras = InstrumentationRegistry.getArguments();
        String[] urls = new String[]{};
        if (extras.containsKey("urls")) {
            String value = extras.getString("urls").replace("\"","");
            urls = value.split(",");
        }

        for (String url: urls) {
            String language = LocaleUtil.getTestLocale().getDisplayName();
            pauseTesting(5);
            mActivityTestRule.getActivity().loadUrl(url+"?Q.language"+language+"&disableAutoLogin=1");
            pauseTesting(40);
            Espresso.closeSoftKeyboard();
            pauseTesting(5);
            Screengrab.screenshot((isTablet()? "tablet":"phone")+"_"+md5(url));
            pauseTesting(5);
        }


        pauseTesting(3);
    }

    private static void pauseTesting(int seconds) {
        try {
            Thread.sleep(seconds*1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public static final String md5(final String s) {
        final String MD5 = "MD5";
        try {
            // Create MD5 Hash
            MessageDigest digest = java.security.MessageDigest
                    .getInstance(MD5);
            digest.update(s.getBytes());
            byte messageDigest[] = digest.digest();

            // Create Hex String
            StringBuilder hexString = new StringBuilder();
            for (byte aMessageDigest : messageDigest) {
                String h = Integer.toHexString(0xFF & aMessageDigest);
                while (h.length() < 2)
                    h = "0" + h;
                hexString.append(h);
            }
            return hexString.toString();

        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return "";
    }
}

