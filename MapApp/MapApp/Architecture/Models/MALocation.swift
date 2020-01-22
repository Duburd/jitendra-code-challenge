//
//  MALocation.swift
//  MapApp
//
//  Created by Jitendra Kumar on 22/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
import CoreLocation
struct MALocation:Mappable {
    var latitude:Double?
    var longitude:Double?
    enum CodingKeys:String,CodingKey {
        case latitude = "lat",longitude = "lang"
    }
    init(_ location:CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    init(_ coordinate:CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    init(_ latitude:CLLocationDegrees, _ longitude:CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
    }
    
    
    
}
extension MALocation:Equatable{
    var coordinate:CLLocationCoordinate2D?{
        return location?.coordinate
    }
    var location:CLLocation?{
        guard let lat = self.latitude, let long = self.longitude else { return nil}
        return CLLocation(latitude: lat, longitude: long)
    }
    static func == (lhs:MALocation, rhs:MALocation)->Bool{
        return lhs.latitude == rhs.longitude && lhs.longitude == rhs.longitude
    }
}
