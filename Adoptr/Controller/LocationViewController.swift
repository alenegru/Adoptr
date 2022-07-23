//
//  LocationViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 04/06/2022.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var allowLocationButton: StandardButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allowLocationButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)

        if let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
           let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
            
        } else {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            print("no location")
            return
        }
        print("locations = \(locationValue.latitude) \(locationValue.longitude)")
        
        if let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
           let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double {
            //check if the new values are equal to the already stored ones
            if CLLocationDegrees(latitude) == locationValue.latitude && CLLocationDegrees(longitude) == locationValue.longitude {
                self.performSegue(withIdentifier: K.typeProfileSegue, sender: self)
                self.locationManager.delegate = nil
                return
            }
        }
        
        UserDefaults.standard.setValue(Double(locationValue.latitude), forKey: "latitude")
        UserDefaults.standard.setValue(Double(locationValue.longitude), forKey: "longitude")
        
        self.performSegue(withIdentifier: K.typeProfileSegue, sender: self)
        self.locationManager.delegate = nil
    }
    
    
    @IBAction func allowLocationButtonPressed(_ sender: StandardButton) {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("Enabled location")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()

            switch locationManager.authorizationStatus {
            case .restricted, .denied:
                print("No access")
                showAlert()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            case .notDetermined:
                print("Not determined yet")
                @unknown default:
                    break
            }
            
        } else {
            print("not enabled")
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Allow location", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
             }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
