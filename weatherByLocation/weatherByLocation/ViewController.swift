//
//  ViewController.swift
//  weatherByLocation
//
//  Created by Angel Rose Eldhose on 2022-11-22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchText: UITextField!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displayImage()
    }
    
    private func displayImage(){
        
        let config=UIImage.SymbolConfiguration(paletteColors: [.systemTeal])
        
        weatherImage.preferredSymbolConfiguration=config
        weatherImage.image=UIImage(systemName: "cloud")
    }
    @IBAction func onLocation(_ sender: UIButton) {
        
    }
    
    
    @IBAction func onsearch(_ sender: UIButton) {
        loadWeather(search:searchText.text)
    }
    
    private func loadWeather(search:String?){
        guard let search=search else{
            return
        }
        guard let url=getURL(query: search) else{
            print("Could not get URL")
            return
        }
        
        let session=URLSession.shared
        let dataTask=session.dataTask(with: url) { data, response, error in
            print("Network call completed")
            
            guard error==nil else{
                print("Recived error")
                return
            }
            
            guard let data = data else{
                print("Data not found")
                return
            }
            
            if let weatherResponse=self.parseJson(data: data) {
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_f)
                
                
                DispatchQueue.main.async {
                    self.locationLabel.text=weatherResponse.location.name
                    self.tempLabel.text="\(weatherResponse.current.temp_f)f"
                }
                
            }
        }
            
            dataTask.resume()
       
    }
    
    private func getURL(query:String)->URL?{
        let baseURL="https://api.weatherapi.com/v1/"
        let currentEndPoint="current.json?"
        let apiKey="8b5447571c914feda63171817222211"
        guard let url="\(baseURL)\(currentEndPoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        print(url)
        
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        
        let decoder=JSONDecoder()
        
        var weather:WeatherResponse?
        do{
            weather=try decoder.decode(WeatherResponse.self,from: data)
        }catch{
            print("Error decoding")
        }
        return weather
    }
    
}


struct WeatherResponse: Decodable {
    let location:Location
    let current:Weather
}

struct Location: Decodable {
    let name:String
}

struct Weather: Decodable {
    let temp_f:Float
    let condition:WeatherCondition
}

struct WeatherCondition: Decodable {
    let text:String
    let code:Int
}
