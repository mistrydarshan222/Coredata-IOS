//
//  Map.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/8/24.
//

import UIKit
import MapKit
import CoreLocation

class Map: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var showhistory = [Showhistory]()
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zoomSlider: UISlider!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var busButton: UIButton!
    
    var startLocation: String?
    var endLocation: String?
    var geocoder = CLGeocoder()
    var transportType: MKDirectionsTransportType = .automobile
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureZoomSlider()
        drawLocationRoute()
        showAlertForLocations()
    }
    
    func addAnnotationPin(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
    }
    
    func centerMapOnLocations(_ startCoordinate: CLLocationCoordinate2D, _ endCoordinate: CLLocationCoordinate2D) {
        let centerLatitude = (startCoordinate.latitude + endCoordinate.latitude) / 2
        let centerLongitude = (startCoordinate.longitude + endCoordinate.longitude) / 2
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        let span = MKCoordinateSpan(latitudeDelta: abs(startCoordinate.latitude - endCoordinate.latitude) * 1.2, longitudeDelta: abs(startCoordinate.longitude - endCoordinate.longitude) * 1.2)
        
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func drawLocationRoute() {
        guard let startLocation = startLocation, let endLocation = endLocation else { return }
        
        geocodeLocation(locationName: startLocation) { [weak self] startCoordinate in
            guard let startCoordinate = startCoordinate else { return }
            self?.geocodeLocation(locationName: endLocation) { endCoordinate in
                guard let endCoordinate = endCoordinate else { return }
                
                let startPlacemark = MKPlacemark(coordinate: startCoordinate)
                let endPlacemark = MKPlacemark(coordinate: endCoordinate)
                
                let startMapItem = MKMapItem(placemark: startPlacemark)
                let endMapItem = MKMapItem(placemark: endPlacemark)
                
                let request = MKDirections.Request()
                request.source = startMapItem
                request.destination = endMapItem
                request.transportType = self?.transportType ?? .automobile
                
                let directions = MKDirections(request: request)
                directions.calculate { [weak self] response, error in
                    guard let route = response?.routes.first else {
                        print("Error calculating route:", error?.localizedDescription ?? "Unknown error")
                        return
                    }
                    
                    self?.mapView.addOverlay(route.polyline)
                    self?.addAnnotationPin(coordinate: startCoordinate, title: "Start Point", subtitle: nil)
                    self?.addAnnotationPin(coordinate: endCoordinate, title: "End Point", subtitle: nil)
                    self?.centerMapOnLocations(startCoordinate, endCoordinate)
                    let totalDistanceString = String(format: "%.2f", route.distance)
                    let transportTypeString = self?.transportType == .automobile ? "Car" : "Walking"
                    if let totalDistance = Double(totalDistanceString) {
                        let totalDistanceKm = totalDistance / 1000
                        let formattedDistance = String(format: "%.2f", totalDistanceKm)
                        self?.addMapToHistory(startingPoint: startLocation, endingPoint: endLocation, distanceInMeters: totalDistance, modeOfTravel: transportTypeString)
                    } else {
                        print("Invalid distance format")
                    }
                    
                }
            }
        }
    }
    
    
    
    @IBAction func zoomSliderValueChanged(_ sender: UISlider) {
        let region = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: Double(sender.value) * 10000, longitudinalMeters: Double(sender.value) * 10000)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func changeLocationButtonTapped(_ sender: Any) {
        showAlertForLocations()
    }
    
    @IBAction func walkButtonTapped(_ sender: UIButton) {
        transportType = .walking
        resetMap()
        drawLocationRoute()
    }
    
    @IBAction func busButtonTapped(_ sender: UIButton) {
        transportType = .automobile
        resetMap()
        drawLocationRoute()
    }
    
    
    @IBAction func bicycleTapped(_ sender: UIButton) {
        transportType = .automobile
        resetMap()
        drawLocationRoute()
    }
    
    func showAlertForLocations() {
        let alert = UIAlertController(title: "Enter Start and End Locations", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Start Location"
        }
        alert.addTextField { textField in
            textField.placeholder = "End Location"
        }
        alert.addAction(UIAlertAction(title: "Direction", style: .default, handler: { [weak self] _ in
            if let startLocation = alert.textFields?.first?.text,
               let endLocation = alert.textFields?.last?.text {
                self?.startLocation = startLocation
                self?.endLocation = endLocation
                self?.resetMap()
                self?.drawLocationRoute()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func geocodeLocation(locationName: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        geocoder.geocodeAddressString(locationName) { placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("Error geocoding location:", error?.localizedDescription ?? "error")
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }
    
    func configureZoomSlider() {
        zoomSlider.minimumValue = 0.01
        zoomSlider.maximumValue = 10.0
        zoomSlider.value = 1.0
        zoomSlider.addTarget(self, action: #selector(zoomSliderValueChanged(_:)), for: .valueChanged)
    }
    
    func resetMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.black
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // Update the addMapToHistory method to save map data to CoreData
    func addMapToHistory(startingPoint: String, endingPoint: String, distanceInMeters: Double, modeOfTravel: String) {
        let distanceInKilometers = distanceInMeters / 1000
        let formattedDistance = String(format: "%.2f", distanceInKilometers)
        
        let newHistory = Showhistory(context: context)
        newHistory.from = startingPoint
        newHistory.to = endingPoint
        newHistory.distance = formattedDistance
        newHistory.modeOfTravel = modeOfTravel
        newHistory.createdAt = Date()
        
        do {
            try context.save()
        } catch {
            print("Error adding map to history: \(error)")
        }
    }
    
    
}

