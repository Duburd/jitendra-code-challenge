//
//  JKGoogleManager.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

typealias JKGooglePlacePickerHandler = (_ result:Result<GMSPlace,Error>)->Void
class JKGoogleManager: NSObject {
    fileprivate var currentController:UIViewController!
    fileprivate var placePickerHandler:JKGooglePlacePickerHandler?
    private override init() {
        super.init()
    }
    class var shared:JKGoogleManager{
        struct Singlton{
            static let instance = JKGoogleManager()
        }
        return Singlton.instance
    }
    
    func GSSetup(){
        let kapiKey :String =  "AIzaSyBy5Z5u9IXDkFUgzFCvCq6mY0H0WZo2mEg"
        // Provide the Places API with your API key.
        GMSPlacesClient.provideAPIKey(kapiKey)
        // Provide the Maps API with your API key. We need to provide this as well because the Place
        // Picker displays a Google Map.
        GMSServices.provideAPIKey(kapiKey)
    }
    
    func showPlacePicker(from viewController:UIViewController,callback:@escaping JKGooglePlacePickerHandler){
        placePickerHandler = callback
        self.currentController = viewController
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Specify the place data types to return.
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
//            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue))!
//        autocompleteController.placeFields = fields
        // Specify a filter.
//        let filter = GMSAutocompleteFilter()
//        filter.type = .address
//        autocompleteController.autocompleteFilter = filter
        autocompleteController.modalPresentation()
        // Display the autocomplete view controller.
        self.currentController?.present(autocompleteController, animated: true, completion: nil)
    }
}
extension JKGoogleManager: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(String(describing: place.name))")
        print("Place ID: \(String(describing: place.placeID))")
        print("Place attributions: \(String(describing: place.attributions))")
        self.currentController?.dismiss(animated: true, completion: {
            async {
                self.placePickerHandler?(.success(place))
            }
        })
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
        self.placePickerHandler?(.failure(error))
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.currentController?.dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
extension GMSPlace{
    var placeLocation:CLLocation{
       return CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
    }
    var placeMarker:GMSMarker{
        return GMSMarker(position: self.coordinate)
    }
}
