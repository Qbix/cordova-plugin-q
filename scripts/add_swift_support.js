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

    var fastlaneFolderInPlugins = path.join(projectRoot,"plugins","com.q.cordova","src","ios","fastlane");
    var fastlaneFolderInProject = path.join(iosPlatformPath,"QFastlaneUITests");

    copyFolderRecursiveSync(fastlaneFolderInPlugins, fastlaneFolderInProject);
    run();

    function insertInString(source, index, string) {
      if (index > 0)
        return source.substring(0, index) + string + source.substring(index, source.length);
      else
        return string + source;
    };

    function addDependency(content, importString) {
        if(content.indexOf(importString) == -1) {
            newRowIndex = 0;
            var lastIndexOf = content.lastIndexOf("#import")
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

    function setupReferenceToQClasses(projectname) {
        // AppDelegate.h
        var appDelegateHPath = path.join(iosPlatformPath,projectname,"Classes","AppDelegate.h");
        appDelegateHContent = fs.readFileSync(appDelegateHPath, 'utf-8');
        
        appDelegateHContent = addDependency(appDelegateHContent, "#import \"Q.h\"");
        fs.writeFileSync(appDelegateHPath, appDelegateHContent);

        // AppDelegate.m
        var appDelegateMPath = path.join(iosPlatformPath,projectname,"Classes","AppDelegate.m");
        appDelegateMContent = fs.readFileSync(appDelegateMPath, 'utf-8');


        appDelegateMContent = addDependency(appDelegateMContent, "#import \"QDelegate.h\"");
        appDelegateMContent = addDependency(appDelegateMContent, "#import \""+projectname.replace(" ", "_")+"-Swift.h\"");

        var index = appDelegateMContent.indexOf("@implementation AppDelegate");
        if(index > -1) {
            appDelegateMContent = appDelegateMContent.replace(
                "@implementation AppDelegate", 
                "@implementation AppDelegate\n DarwinNotificationCenterBeeper *beeper;");
        }
        index = appDelegateMContent.indexOf("self.viewController = [[MainViewController alloc] init];");
        if(index > -1) {
            appDelegateMContent = appDelegateMContent.replace(
                "self.viewController = [[MainViewController alloc] init];", 
                "[QDelegate handleLaunchMode:self];\n beeper = [[DarwinNotificationCenterBeeper alloc] initWithPrefix:[BeeperConstants prefix]];\n [beeper registerWithIdentifier:[BeeperConstants reload] handler:^{[QDelegate resetApp];}];\n // In case of using app group\n  // [[[QbixAppGroupManager alloc] initWithAppBundleID:[[NSBundle mainBundle] bundleIdentifier]] initApp];");
        }
        fs.writeFileSync(appDelegateMPath, appDelegateMContent);

        // MyApp-Prefix.pch:
        var prefixPCHPath = path.join(iosPlatformPath,projectname,projectname+"-Prefix.pch");
        prefixPCHContent = fs.readFileSync(prefixPCHPath, 'utf-8');

        if(prefixPCHContent.indexOf("#import \"QConfig.h\"") == -1) {
            prefixPCHContent = insertInString(prefixPCHContent, prefixPCHContent.length, "#import \"QConfig.h\"\n")
            fs.writeFileSync(prefixPCHPath, prefixPCHContent);
        }
    }

    function copyFileSync( source, target ) {
        var targetFile = target;

        //if target is a directory a new file with the same name will be created
        if ( fs.existsSync( target ) ) {
            if ( fs.lstatSync( target ).isDirectory() ) {
                targetFile = path.join( target, path.basename( source ) );
            }
        }

        fs.writeFileSync(targetFile, fs.readFileSync(source));
    }

    function copyFolderRecursiveSync( source, target ) {
        var files = [];

        //check if folder needs to be created or integrated
        var targetFolder = path.join( target );
        if ( !fs.existsSync( targetFolder ) ) {
            fs.mkdirSync( targetFolder );
        }

        //copy
        if ( fs.lstatSync( source ).isDirectory() ) {
            files = fs.readdirSync( source );
            files.forEach( function ( file ) {
                var curSource = path.join( source, file );
                if ( fs.lstatSync( curSource ).isDirectory() ) {
                    copyFolderRecursiveSync( curSource, targetFolder );
                } else {
                    copyFileSync( curSource, targetFolder );
                }
            } );
        }
    }

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


        setupReferenceToQClasses(projectName);

        IOS_DEPLOYMENT_TARGET = cfg.getPreference('deployment-target', 'ios')+"" || '8.0'


        if(CORDOVA_VERSION < 7.0) {
            platform_ios = CORDOVA_VERSION < 5.0 
              ? context.requireCordovaModule('cordova-lib/src/plugman/platforms')['ios']
              : context.requireCordovaModule('cordova-lib/src/plugman/platforms/ios')

            projectFile = platform_ios.parseProjectFile(iosPlatformPath);
        } else {
            var project_files = context.requireCordovaModule('glob').sync(path.join(iosPlatformPath, '*.xcodeproj', 'project.pbxproj'));
            if (project_files.length === 0) {
                throw new Error('Can\'t found xcode project file');
            }

            var pbxPath = project_files[0];
            var xcodeproj = context.requireCordovaModule('xcode').project(pbxPath);
            xcodeproj.parseSync();

            projectFile = {
                'xcode': xcodeproj,
                write: function () {
                    var fs = context.requireCordovaModule('fs');

                    var frameworks_file = path.join(iosPlatformPath, 'frameworks.json');
                    var frameworks = {};
                    try {
                        frameworks = context.requireCordovaModule(frameworks_file);
                        console.log(JSON.stringify(frameworks));
                    } catch(e) {}

                    fs.writeFileSync(pbxPath, xcodeproj.writeSync());
                    fs.writeFileSync(frameworks_file, JSON.stringify(this.frameworks, null, 4));
                }
            };
        }
        xcodeProject = projectFile.xcode;

        if (fs.existsSync(xcconfigPath)) {
            xcconfigContent = fs.readFileSync(xcconfigPath, 'utf-8');
        }

        bridgingHeaderPath = getBridgingHeader(projectName, xcconfigContent, xcodeProject);
        if(bridgingHeaderPath) {
            bridgingHeaderPath = path.join(iosPlatformPath, bridgingHeaderPath);
        } else {
            bridgingHeaderPath = createBridgingHeader(xcodeProject, projectName, iosProjectFilesPath);
        }

        getExistingBridgingHeaders(iosProjectFilesPath, function (headers) {
            importBridgingHeaders(bridgingHeaderPath, headers);
            var configurations = nonComments(xcodeProject.pbxXCBuildConfigurationSection()),
                config, buildSettings;

            for (config in configurations) {
                buildSettings = configurations[config].buildSettings;
                buildSettings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET;
                buildSettings['SWIFT_VERSION'] = SWIFT_VERSION;
                buildSettings['EMBEDDED_CONTENT_CONTAINS_SWIFT'] = "YES";
                buildSettings['LD_RUNPATH_SEARCH_PATHS'] = '"@executable_path/Frameworks"';
            }
            console.log('IOS project now has deployment target set as:[' + IOS_DEPLOYMENT_TARGET + '] ...');
            console.log('IOS project option EMBEDDED_CONTENT_CONTAINS_SWIFT set as:[YES] ...');
            console.log('IOS project swift_objc Bridging-Header set to:[' + bridgingHeaderPath + '] ...');
            console.log('IOS project Runpath Search Paths set to: @executable_path/Frameworks ...');

            projectFile.write();

            // put valid swift2objc bridge
            //### put-here-<ProjectName>-Swift.h ###
            setSwift2ObjcHeader(iosProjectFilesPath, projectName);
        });

        

        // put valid swift2objc bridge
        //### put-here-<ProjectName>-Swift.h ###
    }

    function setSwift2ObjcHeader(iosProjectFilesPath, projectName) {
        getSourceFiles(iosProjectFilesPath, function (headers) {

        
        var templateString = "### put-here-<ProjectName>-Swift.h ###";        

        headers.forEach(function (header) {
            fs.lstat(header, (err, stats) => {
                if(err)
                    return console.log(err); //Handle error

                if((stats.isFile() || stats.isSymbolicLink()) && !stats.isDirectory()) {
                    var content = fs.readFileSync(header, 'utf-8');
            
                    if (content.indexOf(header) < 0) {
                        if(content.includes(templateString)) {
                            content = content.replace(templateString, "#import \""+projectName.replace(" ", "_")+"-Swift.h\"");
                        }
                    }

                    fs.writeFileSync(header, content, 'utf-8');
                }
            });
            
        });
        

            // importBridgingHeaders(bridgingHeaderPath, headers);
            // var configurations = nonComments(xcodeProject.pbxXCBuildConfigurationSection()),
            //     config, buildSettings;

            // for (config in configurations) {
            //     buildSettings = configurations[config].buildSettings;
            //     buildSettings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET;
            //     buildSettings['SWIFT_VERSION'] = SWIFT_VERSION;
            //     buildSettings['EMBEDDED_CONTENT_CONTAINS_SWIFT'] = "YES";
            //     buildSettings['LD_RUNPATH_SEARCH_PATHS'] = '"@executable_path/Frameworks"';
            // }
            // console.log('IOS project now has deployment target set as:[' + IOS_DEPLOYMENT_TARGET + '] ...');
            // console.log('IOS project option EMBEDDED_CONTENT_CONTAINS_SWIFT set as:[YES] ...');
            // console.log('IOS project swift_objc Bridging-Header set to:[' + bridgingHeaderPath + '] ...');
            // console.log('IOS project Runpath Search Paths set to: @executable_path/Frameworks ...');

            // projectFile.write();
        });
    }

    function getBridgingHeader(projectName, xcconfigContent, xcodeProject) {
        var configurations,
            config,
            buildSettings,
            bridgingHeader;

        if (xcconfigContent) {
            var regex = /^SWIFT_OBJC_BRIDGING_HEADER *=(.*)$/m,
                match = xcconfigContent.match(regex);

            if (match) {
                bridgingHeader = match[1];
                bridgingHeader = bridgingHeader
                  .replace("$(PROJECT_DIR)/", "")
                  .replace("$(PROJECT_NAME)", projectName)
                  .trim();

                return bridgingHeader;
            }
        }

        configurations = nonComments(xcodeProject.pbxXCBuildConfigurationSection());

        for (config in configurations) {
            buildSettings = configurations[config].buildSettings;
            bridgingHeader = buildSettings['SWIFT_OBJC_BRIDGING_HEADER'];
            if (bridgingHeader) {
                return unquote(bridgingHeader);
            }
        }
    }

    function createBridgingHeader(xcodeProject, projectName, xcodeProjectRootPath) {
        var newBHPath = path.join(xcodeProjectRootPath, "Plugins", "Bridging-Header.h"),
            content = ["//",
                       "//  Use this file to import your target's public headers that you would like to expose to Swift.",
                       "//",
                       "#import <Cordova/CDV.h>"]

        //fs.openSync(newBHPath, 'w');
        console.log('Creating new Bridging-Header.h at path: ', newBHPath);
        fs.writeFileSync(newBHPath, content.join("\n"), { encoding: 'utf-8', flag: 'w' });
        xcodeProject.addHeaderFile("Bridging-Header.h");
        setBridgingHeader(xcodeProject, path.join(projectName, "Plugins", "Bridging-Header.h"));
        return newBHPath;
    }

    function setBridgingHeader(xcodeProject, headerPath) {
        var configurations = nonComments(xcodeProject.pbxXCBuildConfigurationSection()),
            config, buildSettings, bridgingHeader;

        for (config in configurations) {
            buildSettings = configurations[config].buildSettings;
            console.log(buildSettings);
            buildSettings['SWIFT_OBJC_BRIDGING_HEADER'] = '"' + headerPath + '"';
        }
    }

    function getSourceFiles(xcodeProjectRootPath, callback) {
        var searchPath = path.join(xcodeProjectRootPath, 'Plugins');

        child_process.exec('find . -name "*.m"', { cwd: searchPath }, function (error, stdout, stderr) {
            var headers = stdout.toString().split('\n').map(function (filePath) {
                return path.join(searchPath, filePath); 
            });
            callback(headers);
        });
    }

    function getExistingBridgingHeaders(xcodeProjectRootPath, callback) {
        var searchPath = path.join(xcodeProjectRootPath, 'Plugins');

        child_process.exec('find . -name "*Bridging-Header*.h"', { cwd: searchPath }, function (error, stdout, stderr) {
            var headers = stdout.toString().split('\n').map(function (filePath) {
                return path.basename(filePath);
            });
            callback(headers);
        });
    }

    function importBridgingHeaders(mainBridgingHeader, headers) {
        var content = fs.readFileSync(mainBridgingHeader, 'utf-8'),
            mainHeaderName = path.basename(mainBridgingHeader);

        headers.forEach(function (header) {
            if(header !== mainHeaderName && content.indexOf(header) < 0) {
                if (content.charAt(content.length - 1) != '\n') {
                    content += "\n";
                }
                content += "#import \""+header+"\"\n"
                console.log('Importing ' + header + ' into main bridging-header at: ' + mainBridgingHeader);
            }
        });
        fs.writeFileSync(mainBridgingHeader, content, 'utf-8');
    }

    function nonComments(obj) {
        var keys = Object.keys(obj),
            newObj = {},
            i = 0;

        for (i; i < keys.length; i++) {
            if (!COMMENT_KEY.test(keys[i])) {
                newObj[keys[i]] = obj[keys[i]];
            }
        }

        return newObj;
    }

    function unquote(str) {
        if (str) return str.replace(/^"(.*)"$/, "$1");
    }
}