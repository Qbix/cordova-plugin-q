var xcode = require('xcode');
var fs = require('fs');
var projectName = process.argv[2];
var fileToAdd = process.argv[3];
var projectPath = '../platforms/ios/'+projectName+'.xcodeproj/project.pbxproj';
var proj = new xcode.project(projectPath);

console.log(projectPath);
proj.parse(function (err) {
    proj.addResourceFile(fileToAdd);
    fs.writeFileSync(projectPath, proj.writeSync());
    console.log('new project written');
});