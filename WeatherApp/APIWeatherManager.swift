 //
//  APIWeatherManager.swift
//  WeatherApp
//
//  Created by Александра Гольде on 05/02/2017.
//  Copyright © 2017 Александра Гольде. All rights reserved.
//

import Foundation

 struct Coordinates {
    let latitude: Double
    let longitude: Double
 }
 
 enum ForecastType : FinalURLPoint {
    case Current(apiKey: String, coodinates: Coordinates)
    var baseURL: URL{
        return URL(string: "https://api.darksky.net")!
    }
    var path: String {
        switch self {
        case .Current(let apiKey, let coodinates):
            return "/forecast/\(apiKey)/\(coodinates.latitude),\(coodinates.longitude)"
        }
    }
    var request: URLRequest{
        let url = URL(string: path, relativeTo: baseURL)
        return URLRequest(url: url!)
    }
 }
 
 final class APIWeatherManager: APIManager {
    let sessionConfiguration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration)
    } ( )
    let apiKey: String
    init(sessionConfiguration: URLSessionConfiguration, apiKey: String){
    self.sessionConfiguration = sessionConfiguration
    self.apiKey = apiKey
    }
    convenience init(apiKey:String){
        self.init(sessionConfiguration: URLSessionConfiguration.default, apiKey: apiKey)
    }
    
    func fetchCurrentWeather(coordinates: Coordinates, completionHeandler: @escaping (APIResult<CurrentWeather>)->Void){
        let request = ForecastType.Current(apiKey: self.apiKey, coodinates: coordinates).request
        fetch(request: request, parse: { (json) -> CurrentWeather? in
            if let dictionary = json["currently"] as? [String: AnyObject]{
                return CurrentWeather(JSON: dictionary)
            } else {
                return nil
            }
        }, completionHeandler: completionHeandler)
    }
 }
 
