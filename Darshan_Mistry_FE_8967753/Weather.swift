//
//  Weather.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/8/24.
//
import UIKit
import CoreLocation
import CoreData

class Weather: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let locationManager = CLLocationManager()
    var myLocation: CLLocation?
    let myAPIKey = "361b513b71e94d466002bef29d26b8cd"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        myLocation = location
        setAPIURL()
    }
    
    func setAPIURL() {
        guard let latitude = myLocation?.coordinate.latitude, let longitude = myLocation?.coordinate.longitude else {
            print("Unable to get current location coordinates.")
            return
        }
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(myAPIKey)&units=metric"
        fetchData(from: urlString)
    }
    
    func fetchData(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let urlSession = URLSession(configuration: .default)
        let dataTask = urlSession.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let weatherData = try JSONDecoder().decode(Darshan.self, from: data)
                DispatchQueue.main.async {
                    self?.updateWeatherUI(with: weatherData)
                }
            } catch {
                print("Error decoding weather data: \(error)")
            }
        }
        dataTask.resume()
    }
    @IBAction func searchCity(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Enter City Name", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "City Name"
        }
        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            
            self?.locationManager.stopUpdatingLocation()
            guard let cityName = alert.textFields?.first?.text else { return }
            let escapedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let searchURLString = "https://api.openweathermap.org/data/2.5/weather?q=\(escapedCityName)&appid=\(self?.myAPIKey ?? "")&units=metric"
            self?.fetchData(from: searchURLString)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(searchAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func updateWeatherUI(with weatherData: Darshan) {
        cityName.text = weatherData.name
        weatherDescription.text = weatherData.weather.first?.description ?? "Unknown"
        temperatureLabel.text = "\(weatherData.main.temp)°C"
        humidity.text = "Humidity: \(weatherData.main.humidity) %"
        windSpeed.text = "Wind Speed: \(weatherData.wind.speed) km/h"
        self.weatherimage(iconName: weatherData.weather[0].icon)
        
        // Add weather data to history
        let weatherDataForHistory = WeatherData(cityName: weatherData.name, weatherDescription: weatherData.weather.first?.description ?? "Unknown", temperature: "\(weatherData.main.temp)°C", humidity: "Humidity: \(weatherData.main.humidity) %", windSpeed: "Wind Speed: \(weatherData.wind.speed) km/h")
        addWeatherToHistory(weatherData: weatherDataForHistory)
    }
    
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
    
    func addWeatherToHistory(weatherData: WeatherData) {
        let newHistory = Showhistory(context: context)
        newHistory.cityName = weatherData.cityName
        newHistory.temperature = weatherData.temperature
        newHistory.humidity = weatherData.humidity
        newHistory.windSpeed = weatherData.windSpeed
        newHistory.createdAt = Date()
        
        do {
            try context.save()
        } catch {
            print("Error adding weather to history: \(error)")
        }
    }
    
    // MARK: - Codable Structs
    struct Darshan: Codable {
        let name: String
        let weather: [Weather]
        let main: Main
        let wind: Wind
    }
    
    struct Weather: Codable {
        let description: String
        let icon: String
    }
    
    struct Main: Codable {
        let temp: Double
        let humidity: Int
    }
    
    struct Wind: Codable {
        let speed: Double
    }
    
    // Struct to hold weather data for history
    struct WeatherData {
        let cityName: String
        let weatherDescription: String
        let temperature: String
        let humidity: String
        let windSpeed: String
    }
}
