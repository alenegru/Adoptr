//
//  User.swift
//  Adoptr
//
//  Created by Alexandra Negru on 01/08/2021.
//

import Foundation

//set classes decodable when fetching :) 

//struct User {
//    var firebaseID: String
//    var _id: String
//    var firstName: String
//    var lastName : String
//    var email: String
//    var phoneNumber: String
//    var birthday: String
//    var profile: Profile
//    var location: Location
//}

struct User {
    var name: String
    var email: String
    var description: String?
    var location: Location?
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String {
        //ale-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
