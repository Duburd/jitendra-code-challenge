//
//  JKLocationManager.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import CoreLocation
typealias JKLocationHandler = (Result<[CLLocation], Error>)->Void
class JKLocationManager: NSObject {
    fileprivate var locationBlock: JKLocationHandler!
    lazy var locationManager: CLLocationManager = {
        return CLLocationManager()
    }()
    var distanceFilter:CLLocationDistance{
        set{
             locationManager.distanceFilter = newValue
        }
        get{
            return locationManager.distanceFilter
        }
    }
    var lastLocation:CLLocation?{
        return locationManager.location
    }
    class var shared:JKLocationManager {
        struct Singleton {
            static let instance = JKLocationManager()
        }
        return Singleton.instance
    }
    //MARK:- start/stop UpdatingLocation
    func startUpdating(_ start:Bool = false){
       if start {
            locationManager.startUpdatingLocation()
        }else{
            locationManager.stopUpdatingLocation()
        }
        
    }
    //MARK:- start/stop SignificantLocationChanges
    func startMySignificantLocationChanges(_ start:Bool = true){
        guard CLLocationManager.significantLocationChangeMonitoringAvailable() else {return}
        if start {
            locationManager.startMonitoringSignificantLocationChanges()
        }else{
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
   //MARK:- setuplocationManager
    func setuplocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
         self.startMySignificantLocationChanges(true)
        if(locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
            locationManager.requestWhenInUseAuthorization()
            self.startUpdating(true)
        }
        
        if(locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
            locationManager.requestAlwaysAuthorization()
            self.startUpdating(true)
            self.enableBackgroundLocationUpdate()
            
        }
              
    }
    //MARK:- updateLocations
    func updateLocations(onCompletion:@escaping JKLocationHandler){
        locationBlock = onCompletion
        
    }
    // MARK: - Background Updates -
       fileprivate func enableBackgroundLocationUpdate(){
              if status == .authorizedAlways {
                  if #available(iOSApplicationExtension 9.0, *) {
                      if CLLocationManager.hasBackgroundCapabilities {
                          self.backgroundLocationUpdates = true
                          self.showsBackgroundLocationIndicator = true
                        self.pausesLocationUpdatesAutomatically = true
                        
                          
                      }
                  }
              }
          }
       /// It is possible to force enable background location fetch even if your set any kind of Authorizations.
       public var backgroundLocationUpdates: Bool {
           set { self.locationManager.allowsBackgroundLocationUpdates = newValue }
           get { return self.locationManager.allowsBackgroundLocationUpdates }
       }
       
       /// Indicate whether the location manager object may pause location updates.
       /// See CLLocationManager's `pausesLocationUpdatesAutomatically` for a detailed explaination.
       public var pausesLocationUpdatesAutomatically: Bool {
           set { self.locationManager.pausesLocationUpdatesAutomatically = newValue }
           get { return self.locationManager.pausesLocationUpdatesAutomatically }
       }
       
       /// A Boolean indicating whether the status bar changes its appearance when location services are used in the background.
       /// This property affects only apps that received always authorization.
       /// When such an app moves to the background, the system uses this property to determine whether to
       /// change the status bar appearance to indicate that location services are in use.
       ///
       /// Displaying a modified status bar gives the user a quick way to return to your app. The default value of this property is false.
       /// For apps with when-in-use authorization, the system always changes the status bar appearance when the
       /// app uses location services in the background.
       @available(iOS 11, *)
       public var showsBackgroundLocationIndicator: Bool {
           set { self.locationManager.showsBackgroundLocationIndicator = newValue }
           get { return self.locationManager.showsBackgroundLocationIndicator }
       }
  
}
extension JKLocationManager:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationBlock?(.success(locations))
    }
    //MARK:- authorizationStatus
    var status:CLAuthorizationStatus{
        return CLLocationManager.authorizationStatus()
    }
    //MARK:- locationServicesEnabled
    var isLocationServicesEnabled:Bool{
        return CLLocationManager.locationServicesEnabled()
    }
    //MARK:- checkEnableLocation
    var checkEnableLocation:Bool{
        if isLocationServicesEnabled {
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                self.startUpdating(true)
                return true
             default:
                print("No access")
                self.loacationAlert(message: "unable get the user location might be user denied permission or restricted location service, Please check location service from Settings and Allow the location as per your Application requirement.")
                return false
            }
        } else {
            self.loacationAlert(message: "unable access the user location becuase location service disabled, Please allow the location from Settings")
            return true
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            if(locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
                locationManager.requestWhenInUseAuthorization()
                self.startUpdating(true)
            }
            
            if(locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
                locationManager.requestAlwaysAuthorization()
                self.startUpdating(true)
                self.enableBackgroundLocationUpdate()
                 
            }
            break
        case .authorizedWhenInUse:
            self.startUpdating(true)
        case .authorizedAlways:
             self.startUpdating(true)
            
        case .restricted:
            self.loacationAlert(message: "User restricted location services, but can grant access from Settings")
            break
        default:
            //denied
            self.loacationAlert(message: "User denied your app access to Location Services, but can grant access from Settings")
            break
            
        }
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationBlock?(.failure(error))
        
    }
    
    func loacationAlert(message:String){
        AppSettingAlert(title: kAppTitle, message: message)
    }
    
    
    
}
public extension CLLocationManager{
    /// Return `true` if host application has background location capabilities enabled
    static var hasBackgroundCapabilities: Bool {
        guard let capabilities = Bundle.backgroundCapabilities else {
            return false
        }
        return capabilities.contains("location")
    }
}
