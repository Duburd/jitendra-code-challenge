//
//  MapAppTests.swift
//  MapAppTests
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import XCTest
@testable import MapApp

class MapAppTests: XCTestCase {
    
    func testLocationPermissionKey(){
        //Bundle.showPerrmissionError()
        var isAlwaysLocationRequest:Bool = false
        var isWhenInUseLocationRequest:Bool = false
        let iOSVersion = floor(NSFoundationVersionNumber)
               let isiOS7To10 = (iOSVersion >= NSFoundationVersionNumber_iOS_7_1 && Int32(iOSVersion) <= NSFoundationVersionNumber10_11_Max)
               if !isiOS7To10 {
                  isAlwaysLocationRequest =  Bundle.main.infoDictionary?["NSLocationAlwaysAndWhenInUseUsageDescription"] != nil
               }else{
                  isWhenInUseLocationRequest =  Bundle.main.infoDictionary?["NSLocationAlwaysUsageDescription"] != nil
               }
        
        
        if isiOS7To10 {
            // At least one of the keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription
            // MUST be present in the Info.plist file to use location services on iOS 8+.
            XCTAssert(isAlwaysLocationRequest || isWhenInUseLocationRequest, "To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.")
            
        } else {
            // Key NSLocationAlwaysAndWhenInUseUsageDescription MUST be present in the Info.plist file
            // to use location services on iOS 11+.
            XCTAssert(isWhenInUseLocationRequest, "To use location services in iOS 11+, your Info.plist must provide a value for NSLocationAlwaysAndWhenInUseUsageDescription.")
        }
       
        
    }
    func testSocketURL(){
        let isHasSocketURL = JKSocket.shared.socketURL != nil
        XCTAssert(isHasSocketURL, "Please Add Endpoint before Register Socket")
    }
    func testGraphQLURL(){
        let isHasGraphQLURL = !JKApollo.ServerType.dev.rawValue.isEmpty
        XCTAssert(isHasGraphQLURL, "Please Add Endpoint before Using Apollo Service in JKApollo.ServerType.dev.url")
    }
}
