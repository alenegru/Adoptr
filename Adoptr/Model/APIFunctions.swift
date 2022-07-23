//
//  APIFunctions.swift
//  Adoptr
//
//  Created by Alexandra Negru on 01/08/2021.
//

import Foundation
import Alamofire

//protocol DataDelegate {
//    func updateUsersArray(newArray: String)
//}

class APIFunctions {
//    var delegate: DataDelegate?
    
//    func fetchData() {
//        Alamofire.request("http://192.168.0.55:8081/fetch").response { response in
//            print(response.data)
//
//            let data = String(data: response.data!, encoding: .utf8)
//
//            self.delegate?.updateUsersArray(newArray: data)
//
//        }
//    }
    
    func addUser(firebaseID: String, firstName: String, lastName : String, email: String, phoneNumber: String, birthday: String, profile: Profile, location: Location) {
        Alamofire.request("http://192.168.0.55:8081/create", method: .post, encoding: URLEncoding.httpBody, headers: ["firebaseID": firebaseID, "firstName": firstName, "lastName": lastName, "email": email, "phoneNumber": phoneNumber, "birthday": birthday, "typeProfile": profile.typeProfile, "name": profile.name, "description": profile.description, "latitude": String(location.latitude), "longitude": String(location.longitude)]).responseJSON { (response) in
            print(response)
        }
    }
}
