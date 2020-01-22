//
//  MAMapController.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class MAMapController: UIViewController {
    //MARK:- Properties
    @IBOutlet fileprivate weak var addressTF:UITextField!
    @IBOutlet fileprivate weak var mapView:GMSMapView!
    fileprivate var viewModel = MAPlaceViewModel.shared
    fileprivate var zoomLevel: Float = 15.0
    fileprivate var placeMarker: GMSMarker!
    
    //MARK:- Lifecycle of UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.googleMapSetup()
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { (notif) in
            if JKLocationManager.shared.checkEnableLocation{
                self.fetchUserCurrentLocation()
            }
            
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notif) in
            self.viewModel.startUpdating(true)
            self.fetchUserCurrentLocation()
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchUserCurrentLocation()
        viewModel.getUpdateLocation()
    }
    //MARK:- googleMapSetup
    private func googleMapSetup(){
        mapView.isHidden = false
        // mapView.camera = GMSCameraPosition.camera(withLatitude: -33.869405, longitude: 151.199,zoom: self.zoomLevel)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
    }
    //MARK:- fetchUserCurrentLocation
    private func fetchUserCurrentLocation(){
        viewModel.getCurrentLocation { (success) in
            if success{
                if let location = self.viewModel.currentLocation{
                    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude,zoom: self.zoomLevel)
                    if self.mapView.isHidden {
                        self.mapView.isHidden = false
                        self.mapView.camera = camera
                    } else {
                        self.mapView.animate(to: camera)
                    }
                    
                }
                
            }
        }
        
    }
    //MARK:- setPlaceMarker
    fileprivate func setPlaceMarker(_ marker:GMSMarker) {
        if placeMarker == nil{
            placeMarker = GMSMarker(position: marker.position)
            placeMarker.map = self.mapView
        }
        placeMarker.appearAnimation = .pop
        placeMarker.icon = GMSMarker.markerImage(with: .systemRed)
        placeMarker.title = marker.title
        placeMarker.snippet = marker.snippet
        placeMarker.tracksViewChanges = true
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        placeMarker.position = marker.position
        CATransaction.commit()
        guard let userLocation = self.mapView.myLocation else { return }
        viewModel.selectPlaceIn100Mile(userLocation)
        
    }
    
    //MARK:- onSearchPlace
    @IBAction private func onSearchPlace(_ sender:Any){
        
        viewModel.getPlace { (success) in
            async {
                if success{
                    self.addressTF.text = self.viewModel.formattedAddress
                    if let marker  = self.viewModel.getPlaceMarker(){
                        let cameraUpdate  = GMSCameraUpdate.setTarget(marker.position)
                        self.mapView.moveCamera(cameraUpdate)
                        self.setPlaceMarker(marker)
                        
                    }
                }
            }
        }
        
    }
}

extension MAMapController:GMSMapViewDelegate{
   
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        UIView.animate(withDuration: 5.0, animations: { () -> Void in
            self.placeMarker?.icon = GMSMarker.markerImage(with: .systemBlue)
        }, completion: {(finished) in
            // Stop tracking view changes to allow CPU to idle.
            self.placeMarker?.tracksViewChanges = false
        })
        
    }
}

