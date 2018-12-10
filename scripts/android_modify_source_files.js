var child_process = require('child_process');
var fs = require("fs");
var path = require("path");

module.exports = function(context) {
	console.log("Hello world");
	var cordova_util = context.requireCordovaModule('cordova-lib/src/cordova/util');
	var ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
	var projectRoot = cordova_util.isCordova()
	var xml = cordova_util.projectConfig(projectRoot)
    var cfg = new ConfigParser(xml)

    var projectName = cfg.name()
    var androidPlatformPath = path.join(projectRoot, 'platforms', 'android')
    var packageName = cfg.packageName()

    changeSourceFiles(androidPlatformPath, packageName)
    // changeMainActivity(androidPlatformPath, packageName)
    copyFastlaneScreenshotTest(androidPlatformPath, packageName, projectRoot)

	function changeSourceFiles(androidPlatformPath, packageName) {
		var multiTestChooserActivityPath = path.join(androidPlatformPath, "src", "com","q","cordova", "plugin", "MultiTestChooserActivity.java")
		if (fs.existsSync(multiTestChooserActivityPath)) {
            multiTestChooserContent = fs.readFileSync(multiTestChooserActivityPath, 'utf-8');
          
            multiTestChooserContent = multiTestChooserContent.replace(/<packaged>/gi, packageName)

            fs.writeFileSync(multiTestChooserActivityPath, multiTestChooserContent, 'utf-8');
        } else {
        	console.log("Not exist")
        }
	}

    function changeMainActivity(androidPlatformPath,packageName) {
        var mainActivityFolder = packageName.split(".").join("/")
        var mainActivityPath = path.join(androidPlatformPath, "src", mainActivityFolder, "MainActivity.java")
        if (fs.existsSync(mainActivityPath)) {
            mainActivityContent = fs.readFileSync(mainActivityPath, 'utf-8');
          
            mainActivityContent = mainActivityContent.replace(/CordovaActivity/gi, "QActivity")

            fs.writeFileSync(mainActivityPath, mainActivityContent, 'utf-8');
        } else {
            console.log("Not exist")
        }
    }

    function copyFastlaneScreenshotTest(androidPlatformPath, packageName, projectRoot) {
        var packageAsFolder = packageName.split(".").join("/")
        var androidTestFile = path.join(androidPlatformPath, "androidTest", "java", packageAsFolder)
        mkdirRecursiveSync(androidTestFile);
        androidTestFile = path.join(androidTestFile, "MainActivityTest.java")
        var androidUITestPath = path.join(projectRoot, 'plugins', 'com.q.cordova','/src/android/fastlaneScreenshotTest','MainActivityTest.java')
        fs.writeFileSync(androidTestFile, fs.readFileSync(androidUITestPath));
        if (fs.existsSync(androidTestFile)) {
            mainActivityContent = fs.readFileSync(androidTestFile, 'utf-8');
          
            mainActivityContent = mainActivityContent.replace(/<packaged>/gi, packageName)

            fs.writeFileSync(androidTestFile, mainActivityContent, 'utf-8');
        } else {
            console.log("Not exist")
        }

        // Copy AndroidManifest.xml file
        var androidManifestPath = path.join(projectRoot, 'plugins', 'com.q.cordova','/src/android/fastlaneScreenshotTest','AndroidManifest.xml')
        var androidManifestTestFile = path.join(androidPlatformPath, "androidTest", "AndroidManifest.xml")
        fs.writeFileSync(androidManifestTestFile, fs.readFileSync(androidManifestPath));
        
    }

    function mkdirRecursiveSync(path) {
        let paths = path.split("/");
        let fullPath = '';
        paths.forEach((item) => {
            if (fullPath === '' && item !='') {
                fullPath = item;
            } else {
                fullPath = fullPath + '/' + item;
            }
            if (!fs.existsSync(fullPath)) {
                fs.mkdirSync(fullPath);
            }
        });
    };
}
