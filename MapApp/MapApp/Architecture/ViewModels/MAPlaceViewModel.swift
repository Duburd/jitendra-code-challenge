//
//  MAPlaceViewModel.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//


import GooglePlaces
import GoogleMaps

class MAPlaceViewModel {
    
    static let shared  = MAPlaceViewModel()
    fileprivate var currentPlace:GMSPlace?
    var currentLocation:CLLocation?
    
    //MARK:- getCurrentLocation
    func getCurrentLocation(completion:@escaping(Bool)->Void){
        
        JKLocationManager.shared.updateLocations { (result) in
            async {
                switch result{
                case .success(let locations):
                    if let current = locations.last{
                        if self.currentLocation == nil{
                            self.currentLocation = current
                            //print("Location: \(current)")
                            if UIApplication.shared.applicationState == .active {
                                self.startUpdating()
                                completion(true)
                            }else{
                                //Call Api Service to share location while app is not active
                                self.sentLocation(current.coordinate)
                            }
                         
                        }else{
                            if  self.currentLocation!.isEqual(current) == false{
                                self.currentLocation = current
                              //  print("Location: \(current)")
                                if UIApplication.shared.applicationState == .active {
                                    self.startUpdating()
                                     completion(true)
                                }else{
                                    //Call Api Service to share location while app is not active
                                    self.sentLocation(current.coordinate)
                                }
                               
                            }else{
                                completion(false)
                            }
                        }
                    }else{
                        completion(false)
                    }
                    
                case .failure(let err):
                    print("location update failed =\(err.localizedDescription)")
                    self.startUpdating()
                    completion(false)
                }
            }
        }
        
        
    }
    func startUpdating(_ start:Bool = false){
        JKLocationManager.shared.startUpdating(start)

    }
    
    //MARK:- getPlace
    func getPlace(completion:@escaping(Bool)->Void){
        guard let controller = currentController else { return  }
        JKGoogleManager.shared.showPlacePicker(from: controller) { (result) in
            async {
                switch result{
                case .success(let place):
                    self.currentPlace = place
                    completion(true)
                case .failure(let err):
                    alertMessage = err.localizedDescription
                    completion(false)
                }
            }
        }
        
    }
    //MARK:- sentLocation
    func sentLocation(_ coordinate:CLLocationCoordinate2D){
        guard MAUtility.shared.isConnected else {return}
       let location  = MALocation(coordinate)
        JKSocket.shared.sendJSON(.trackUserLocation, data: location)
                      
    }
   
    
    //MARK:- getUpdateLocation
    func getUpdateLocation(){
        guard MAUtility.shared.isConnected else {return}
        let handler  = {( result:Result<MALocation, Error>) in
            switch result {
            case .success(let location):
                print(location.location?.description ?? "")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        JKSocket.shared.recieveJSON(.updateLocation, completion: handler)
    }
    
}
extension MAPlaceViewModel{
    
    var formattedAddress:String{
        return currentPlace?.formattedAddress ?? ""
    }
    var placePosition:CLLocationCoordinate2D?{
        return currentPlace?.coordinate
    }
    var placeID:String?{
        return currentPlace?.placeID
    }
    var placeName:String{
        return currentPlace?.name ?? ""
    }
    func getPlaceMarker()->GMSMarker?{
        guard let position = self.placePosition else { return nil }
        let marker = GMSMarker(position: position)
        marker.title = placeName
        marker.snippet = formattedAddress
        return marker
    }
    var placeLocation:CLLocation?{
        guard let position = self.placePosition else { return nil}
        return CLLocation(latitude: position.latitude, longitude: position.longitude)
    }
    func distanceBetween(location1:CLLocation, location2:CLLocation)->Double{
       let distanceInMeter = location1.distance(from: location2)
        //distance in meter so 1 miles = 1609 meter
        // 1 meter == 0.000621371192 Miles
        let distanceInMile = 0.000621371192*distanceInMeter
        return distanceInMile
    }
    func selectPlaceIn100Mile(_ userLocation:CLLocation){
        guard  let placelocation = self.placeLocation else { return }
        let distanceInMile = distanceBetween(location1: placelocation, location2: userLocation)
        if distanceInMile <= 100{
            alertMessage = "Searched your place in 100 miles"
        }
    }
}


