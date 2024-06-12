//
//  Main.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/9/24.
//

import UIKit
import CoreLocation
import MapKit


class Main: UIViewController , CLLocationManagerDelegate, MKMapViewDelegate{
    
    
    @IBOutlet weak var currentLocation: MKMapView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // Create a location manager instance
    let locationManager = CLLocationManager()
    var myLocation: CLLocation?
    let myAPIKey = "361b513b71e94d466002bef29d26b8cd"
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        currentLocation.delegate = self
        currentLocation.showsUserLocation = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Function called when the location manager updates the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        currentLocation.setRegion(region, animated: true)
        
        
        guard let location = locations.last else { return }
        myLocation = location
        setAPIURL()
        fetchData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
    
    // Function to construct the API URL using the user's location
    func setAPIURL() {
        guard let latitude = myLocation?.coordinate.latitude, let longitude = myLocation?.coordinate.longitude else {
            print("Unable to get current location coordinates.")
            return
        }
        urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(myAPIKey)&units=metric"
    }
    
    // Function to fetch weather data from the API
    func fetchData() {
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: urlString) {
            
            // Create a data task with the specified URL using the URLSession object
            let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                // Check if the response is an HTTPURLResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                // Check if data is available
                if let data = data
                {
                    // Convert data to a string
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Response data: \(dataString)")
                    }
                    else
                    {
                        print("Unable to convert data to string")
                    }
                    
                    // Create a JSONDecoder instance
                    let jsonDecoder = JSONDecoder()
                    do
                    {
                        // Serialize JSON data into object
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        if JSONSerialization.isValidJSONObject(jsonObject) {
                            print("JSON data is valid")
                        }
                        else
                        {
                            print("JSON data is invalid")
                        }
                        
                        // Decode JSON data
                        let weatherData = try jsonDecoder.decode(Darshan.self, from: data)
                        
                        DispatchQueue.main.async {
                            let cityName = weatherData.name
                            let description = weatherData.weather.first?.description ?? "Unknown"
                            let temperature = weatherData.main.temp
                            
                            self.cityName.text = "\(cityName)"
                            self.weatherDescription.text = "\(description)"
                            self.temperatureLabel.text = "\(temperature)°C"
                            
                            self.weatherimage(iconName: weatherData.weather[0].icon)
                        }
                        
                    }
                    catch
                    {
                        print("Data cannot be decoded.")
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    // Function to load the weather icon
    func weatherimage(iconName: String) {
        // Construct the icon URL string using the icon name
        let imageURLString = "https://openweathermap.org/img/w/\(iconName).png"
        if let imageURL = URL(string: imageURLString) {
            DispatchQueue.global().async {
                // Try to fetch the image data from the icon URL
                if let data = try? Data(contentsOf: imageURL) {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        // Update the weatherImage view on the main thread
                        self.weatherIcon.image = image
                    }
                }
            }
        }
    }
    
    struct Darshan: Codable {
        let coord: Coord
        let weather: [Weather]
        let base: String
        let main: Main
        let visibility: Int
        let wind: Wind
        let clouds: Clouds
        let dt: Int
        let sys: Sys
        let timezone, id: Int
        let name: String
        let cod: Int
    }
    
    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int
    }
    
    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double
    }
    
    // MARK: - Main
    struct Main: Codable {
        let temp, feelsLike, tempMin, tempMax: Double
        let pressure, humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
        }
    }
    
    // MARK: - Sys
    struct Sys: Codable {
        let type, id: Int
        let country: String
        let sunrise, sunset: Int
    }
    
    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main, description, icon: String
    }
    
    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    
    
}


