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
}
