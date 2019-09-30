//
//  ViewController.swift
//  WeatherApp
//
//  Created by Steven Sim on 23/08/19.
//  Copyright © 2019 Steven Sim. All rights reserved.
//

import UIKit
import CoreLocation //tap into GPS functionality of iPhone
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    
    //make sure App ID is correct, it will crash if it's invalid
    //prefer use optional binding
    let APP_ID = "26ba0c0176423c156724234639e38f53"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        //CoreLocation is not open-source, so the solution to use this CoreLocation code made by Apple we need to
        //set a delegate i.e class that will deal with the location once the locationManager finds it
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //ask permission location data
        locationManager.requestWhenInUseAuthorization()
        
        //looking for GPS coordinates
        //a asynchronous method, works in the background to grab the GPS location coordinates
        //if working on foreground or the main thread our app will freeze till it got its location and continue
        //after got its location, this will be activating the func locationManager didUpdateLocations below
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    //facilitate communication between our app and open weather server - Do HTTP request
    
    func getWeatherData(url : String, parameters : [String : String]) {
        //use Alamofire
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            //this is a closure - function within function - if there's "in" keyword, we are inside a closure
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                //formatting the data so that we can display to screen
                let weatherJSON : JSON = JSON(response.result.value!)
                
                print(weatherJSON)
                //must use self keyword inside a closure, to make sure it checks at the current class
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(response.result.error)")
                
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    //parses the responses from openweather api to something that we can show in our app
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON){
        
        //SwiftyJSON helps us
        //access the main -> temp
        if let tempResult = json["main"]["temp"].double {
            //weather is in Kelvin
            //tempResult is optional, so put !
            //weatherDataModel.temperature = Int(tempResult! - 273.15)
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"]["0"]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    //whats gonna be displayed in the label
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        //temperatureLabel.text = String(weatherDataModel.temperature)
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    //grab current location, tells latitude and longitude of our iPhone
    
    //Write the didUpdateLocations method here:
    //this method activated when locationManager found its location from the startUpdatingLocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //set into array of CLLocation
        //narrows down the location in array by adding it every time it get a new location
        //we get the last location in the array
        
        let location = locations[locations.count - 1]
        
        //check if it is valid
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("Longitude = \(location.coordinate.longitude), Latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            //a dictionary to store latitude and longitude
            let params : [String : String] = ["lat" : latitude,
                                              "lon" : longitude,
                                              "appid" : APP_ID]
            
            //do some networking after this, send request to openweathermap to get some weather data back
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    //handles one view controller to other view controller, how we can pass data back and forth
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        print(city)
        
        
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
    }
    
    
    
    
}


