//
//  WalkiePokieApp.swift
//  WalkiePokie
//
//  Created by Vatsal Vipulkumar Patel on 7/21/23.
//

import SwiftUI
import ArcGIS

@main
struct WalkiePokieApp: App {
    init() {
//        ArcGISEnvironment.apiKey = APIKey("AAPKf8d6ba903f7c4d7f8476110eca5295fdsmcdZiKXyBOs8IUxz5hkPATYDI8ql0X5fDMoMK0GI6oJ0FoBK94T9E07KYAHrjFV")
        ArcGISEnvironment.apiKey = APIKey("AAPK952cfc45d84148fc9424e47cc893bb241Yi_-7sshjErQzetrfsJSQTVjztTsU8_HbhOv5-nIIdZMiP1iH7X8coF8dGuvhc0")
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}
