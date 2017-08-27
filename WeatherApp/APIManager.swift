//
//  APIManager.swift
//  WeatherApp
//
//  Created by Александра Гольде on 04/02/2017.
//  Copyright © 2017 Александра Гольде. All rights reserved.
//

import Foundation

typealias JSONTask = URLSessionDataTask
typealias JSONCompletionHeandler = ([String: AnyObject]?, HTTPURLResponse?, Error?) -> Void

protocol FinalURLPoint {
    var baseURL: URL {get}
    var path: String {get}
    var request: URLRequest {get}
}

protocol JSONDecodable {
    init?(JSON: [String: AnyObject])
}

enum APIResult<T> {
    case Success(T)
    case Failure(Error)
}

protocol APIManager {
    var sessionConfiguration : URLSessionConfiguration {get}
    var session : URLSession {get}
    
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONCompletionHeandler) -> JSONTask
    func fetch<T : JSONDecodable>(request: URLRequest, parse: @escaping ([String: AnyObject]) -> T?, completionHeandler: @escaping (APIResult<T>) -> Void)
    
}

extension APIManager {
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONCompletionHeandler) -> JSONTask{
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard let HTTPResponse = response as? HTTPURLResponse else {
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")
                ]
                let error = NSError(domain: SWINetworkingErrorDomain, code: 100, userInfo: userInfo)
                
                completionHandler(nil, nil, error)
                return
            }
            if data == nil {
                if let error = error {
                    completionHandler(nil, HTTPResponse, error)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        completionHandler(json, HTTPResponse, nil)
                    }  catch let error as NSError{
                        completionHandler(nil, HTTPResponse, error)
                    }
                default:
                    print("We've got response status \(HTTPResponse.statusCode)")
                }
            }
        }
        return dataTask
    }
    
    func fetch<T>(request: URLRequest, parse: @escaping ([String: AnyObject]) -> T?, completionHeandler: @escaping (APIResult<T>) -> Void) {
        
        let dataTask = JSONTaskWith(request: request) { (json, response, error) in
            DispatchQueue.main.async(execute: {
                guard let json = json else {
                    if let error = error {
                        completionHeandler(.Failure(error))
                    }
                    return
                }
                if let value = parse(json){
                    completionHeandler(.Success(value))
                } else {
                    let error = NSError(domain: SWINetworkingErrorDomain, code: 200, userInfo: nil)
                    completionHeandler(.Failure(error))
                }
            })
        }
        dataTask.resume()
    }
}
