//
//  MapView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/15.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController:UIViewController{
    var longitude:Double = 30
    var latitude:Double = 30
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let newPin = MKPointAnnotation()
        (latitude,longitude) = LocationTransform.wgs2gcj(wgsLat: latitude, wgsLng: longitude)
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        newPin.coordinate = location.coordinate
        newPin.title = "气象站"
        mapView.addAnnotation(newPin)
    }
}
