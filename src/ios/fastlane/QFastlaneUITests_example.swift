//
//  EditHTMLUITests.swift
//  EditHTMLUITests
//
//  Created by Igor on 11/13/18.
//

import XCTest

class QFastlaneUITests: XCTestCase {

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
        
        let url = getArg(app: app, key: "-init_url")!;
        
        let fullUrl = "\(url)?\(additionalParameters)"
        print(fullUrl);
        app.textFields["Please enter url or name of project"].tap()
        app.textFields["Please enter url or name of project"].typeText(fullUrl)
        app/*@START_MENU_TOKEN@*/.buttons["Go"]/*[[".keyboards.buttons[\"Go\"]",".buttons[\"Go\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(20)
        snapshot("\(Data(url.utf8).hashValue)_screenshot")
    }
}
