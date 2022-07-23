//
//  PetProfile.swift
//  Adoptr
//
//  Created by Alexandra Negru on 04/05/2022.
//

import Foundation

struct PetProfile {
    var typeProfile: String
    // images: [{ data: Buffer, contentType: String }],
    var name: String
    var description: String
    var gender: String
    var age: String
    var adoptionType: String
    var size: String
    var neutered: Bool
    var trained: Bool
    var kidFriendly: Bool
    var environment: String
    var location: Location?
    var photosDownloadURLs: [[String: Any]]?
    var owner: [String:String]?
    var distanceFromUser: String?
    var uuid: String
    
    //var description: String
    // birthday: Date
}
