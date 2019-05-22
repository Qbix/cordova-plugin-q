//
//  EditHTMLUITests.swift
//  EditHTMLUITests
//
//  Created by Igor on 11/13/18.
//

import XCTest

class QFastlaneUITests: XCTestCase {
    let beeper = DarwinNotificationCenterBeeper();

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment = [ "Fastlane": "1" ]
        app.launch()
    }

    func getArg(app:XCUIApplication, key:String) -> String? {
        for (index, element) in app.launchArguments.enumerated() {
            if(element.elementsEqual(key)) {
                return app.launchArguments[index+1]
            }
        }
        
        return nil
    }
    
    func testExample() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchEnvironment["Fastlane"] = "1"
        print("Arguments: \(app.launchArguments)");
        var additionalParameters = "";
        
        var localization = getArg(app: app, key: "-AppleLocale");
        if(localization != nil) {
            localization = localization?.replacingOccurrences(of: "\"", with: "")
            additionalParameters += "Q.language=\(localization!)"
        }
        // Disable automatically do hadsoff feature which opens dialog to authentification.
        additionalParameters += "&disableHandsOff=1";
        
        let urls = getArg(app: app, key: "-init_url")!;
        
        let urlList = urls.components(separatedBy: "|");

        for currentUrl in urlList {
            let url = currentUrl.trimmingCharacters(in: .whitespaces);

            let fullUrl = "\(url)?\(additionalParameters)"
            print(fullUrl);
            app.textFields["Please enter url or name of project"].tap()
            app.textFields["Please enter url or name of project"].typeText(fullUrl)
            app.buttons["Open"].tap()
            sleep(20)
            let preName = md5String(string: url);//MD5(string: url).base64EncodedString()
            snapshot("\(preName!)_screenshot")
            sleep(2)
            beeper.beep(identifier: BeeperConstants.reload)
            sleep(2)

            
        }

    }

    func md5String(string: String) -> String? {
        guard let data = string.data(using: String.Encoding.utf8) else { return nil }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
