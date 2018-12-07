package <packaged>;

import android.os.Bundle;
import android.support.test.InstrumentationRegistry;
import android.support.test.rule.ActivityTestRule;
import android.support.test.runner.AndroidJUnit4;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.UiAutomatorScreenshotStrategy;

@RunWith(AndroidJUnit4.class)
public class MainActivityTest {

    @Rule
    public ActivityTestRule<MainActivity> mActivityTestRule = new ActivityTestRule<>(MainActivity.class);

    @Test
    public void mainActivityTest() {
        Screengrab.setDefaultScreenshotStrategy(new UiAutomatorScreenshotStrategy());

        Bundle extras = InstrumentationRegistry.getArguments();
        String[] urls = new String[]{};
        if (extras.containsKey("urls")) {
            urls = extras.getString("urls").split(",");
        }

        for (String url: urls) {
            pauseTesting(5);
            mActivityTestRule.getActivity().loadUrl(url);
            pauseTesting(10);
            Screengrab.screenshot("name_of_screenshot_here");
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
}
