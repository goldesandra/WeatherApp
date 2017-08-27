//
//  ViewController.swift
//  WeatherApp
//
//  Created by Александра Гольде on 03/02/2017.
//  Copyright © 2017 Александра Гольде. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        toggleActivityIndicator(on: true)
        fetchCurrentWeatherData()
    }
    
    func toggleActivityIndicator(on: Bool){
        refreshButton.isHidden = on
        if on {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    lazy var weatherManager = APIWeatherManager(apiKey: "972bc66291d88e9f6ef8d519c870d99f")
    let coordinates = Coordinates(latitude: 55.697915 , longitude: 37.578835)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        fetchCurrentWeatherData()
        
//        let icon = WeatherIconManager.rain.image
//        let currentWeather = CurrentWeather(temperature: 10.0, apparentTemperature: 5.0, pressure: 30, humidity: 750, icon: icon)
        
      
       // updateUIWith(currentWeather: currentWeather)
        
        // Wrong API getter
//        let urlString = "https://api.darksky.net/forecast/972bc66291d88e9f6ef8d519c870d99f/37.8267,-122.4233"
//        let baseURL = URL(string: "https://api.darksky.net/forecast/972bc66291d88e9f6ef8d519c870d99f/")
//        let fullURL = URL(string: "37.8267,-122.4233", relativeTo: baseURL)
//        
//        let sessionConfiguration = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfiguration)
//        
//        let request = URLRequest(url: fullURL!)
//        let dataTask = session.dataTask(with: fullURL!) { (data, response, error) in
//            
//        }
//        dataTask.resume()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last! as CLLocation
        print("My location latitude: \(userLocation.coordinate.latitude), longitude: \(userLocation.coordinate.longitude)")
    }
    
    func fetchCurrentWeatherData(){
        weatherManager.fetchCurrentWeather(coordinates: coordinates) { (result) in
            self.toggleActivityIndicator(on: false)
            switch result {
            case .Success(let currentWeather):
                self.updateUIWith(currentWeather: currentWeather)
            case .Failure(let error as NSError) :
                
                let alertController = UIAlertController(title: "Unable to get data", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            default: break
            }
        }
    }
    
    func updateUIWith(currentWeather: CurrentWeather){
        self.imageView.image = currentWeather.icon
        self.pressureLabel.text = currentWeather.pressureString
        self.temperatureLabel.text = currentWeather.temperatureString
        self.apparentTemperatureLabel.text = currentWeather.apparentTemperatureString
        self.humidityLabel.text = currentWeather.humidityString
    }
    
  //  func showError(title: String , massage: String , error: NSError)

}


