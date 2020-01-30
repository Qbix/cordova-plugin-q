var child_process = require('child_process'),
    fs = require('fs'),
    path = require('path');

module.exports = function(context) {
    var IOS_DEPLOYMENT_TARGET = '8.3',
        SWIFT_VERSION = '3.0',
        COMMENT_KEY = /_comment$/,
        CORDOVA_VERSION = process.env.CORDOVA_VERSION;

    var cordova_util = context.requireCordovaModule('cordova-lib/src/cordova/util');
    var ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
    var projectRoot = cordova_util.isCordova()
    var xml = cordova_util.projectConfig(projectRoot)
    var cfg = new ConfigParser(xml)
    var projectName = cfg.name()
    var iosPlatformPath = path.join(projectRoot, 'platforms', 'ios')
    var packageName = cfg.packageName()

    run();

    function addPod(content, importString) {
        if(content.indexOf(importString) == -1) {
            newRowIndex = 0;
            var lastIndexOf = content.indexOf("pod")
            if(lastIndexOf > -1) {
                for(var i=lastIndexOf; i < content.length; i++) {
                    var char_value = content[i];
                    if(char_value == '\n') {
                        newRowIndex = i++;
                        break;
                    }
                }    
            }
            content = insertInString(content, newRowIndex, "\n"+importString+"\n")
        }
        return content
    }

    function insertInString(source, index, string) {
        if (index > 0)
          return source.substring(0, index) + string + source.substring(index, source.length);
        else
          return string + source;
      };

    function run() {
        var cordova_util = context.requireCordovaModule('cordova-lib/src/cordova/util'),
            ConfigParser = CORDOVA_VERSION >= 6.0
              ? context.requireCordovaModule('cordova-common').ConfigParser
              : context.requireCordovaModule('cordova-lib/src/configparser/ConfigParser'),
            projectRoot = cordova_util.isCordova(),
            platform_ios,
            xml = cordova_util.projectConfig(projectRoot),
            cfg = new ConfigParser(xml),
            projectName = cfg.name(),
            iosPlatformPath = path.join(projectRoot, 'platforms', 'ios'),
            iosProjectFilesPath = path.join(iosPlatformPath, projectName),
            xcconfigPath = path.join(iosPlatformPath, 'cordova', 'build.xcconfig'),
            xcconfigContent,
            projectFile,
            xcodeProject,
            bridgingHeaderPath;

        IOS_DEPLOYMENT_TARGET = cfg.getPreference('deployment-target', 'ios')+"" || '8.0'

        
        // Add deployment version to podfile
        var podFilePath = path.join(iosPlatformPath,"Podfile");
        podFileContent = fs.readFileSync(podFilePath, 'utf-8');
        podFileContent = podFileContent.replace("platform :ios, '8.0'", "platform :ios, '"+IOS_DEPLOYMENT_TARGET+"'")
        
        // Add SwiftyRSA
        var swiftyRSAItem = "pod 'SwiftyRSA', '1.5.0'";
        if(podFileContent.indexOf(swiftyRSAItem) == -1) {
             podFileContent = addPod(podFileContent, swiftyRSAItem);
        }
        
    
        fs.writeFileSync(podFilePath, podFileContent);
    }
}