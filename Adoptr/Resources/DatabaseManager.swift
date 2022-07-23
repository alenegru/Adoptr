//
//  DatabaseManager.swift
//  Adoptr
//
//  Created by Alexandra Negru on 27/03/2022.
//

import Foundation
import FirebaseDatabase
import GeoFire

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database(url: "https://adoptr-cdbe1-default-rtdb.europe-west1.firebasedatabase.app").reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
}

public enum DatabaseError: Error {
    case failedToFetch

    public var localizedDescription: String {
        switch self {
        case .failedToFetch:
            return "This means blah failed"
        }
    }
}

//MARK:- Location

extension DatabaseManager {
    public func saveLocationForProfile(with petProfileId: String) {
        database.child("Geolocs").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print("Geolocs exists")
                self.geoFireRef = self.database.child("Geolocs")
                self.geoFire = GeoFire(firebaseRef: self.geoFireRef!)
                let latitude = UserDefaults.standard.value(forKey: "latitude") as! Double
                let longitude = UserDefaults.standard.value(forKey: "longitude") as! Double

                let location:CLLocation = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                self.geoFire?.setLocation(location, forKey: petProfileId)
            } else {
                print("Geolocs does not exist")
            }
        })
    }
}

extension DatabaseManager {
    public func userExists(with email: String,
                           completion: @escaping ((Bool, User?) -> Void)) {

        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            if let user = snapshot.value as? [String: Any] {
                let existingUser = User(name: user["name"]! as! String,
                                        email: email,
                                        description: user["description"]! as? String)
                print(user)
                completion(true, existingUser)
            } else {
                completion(false, nil)
            }
        })

    }
    
    ///Inserts new user to database
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
                "name": user.name,
            "description": user.description
            ], withCompletionBlock: { [weak self] error, _ in

                guard let strongSelf = self else {
                    return
                }

                guard error == nil else {
                    print("failed to write to database")
                    completion(false)
                    return
                }

                strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                    if var usersCollection = snapshot.value as? [[String: Optional<String>]] {
                        // append to user dictionary
                        let newElement = [
                            "name": user.name,
                            "email": user.email,
                            "description": user.description
                        ]
                        usersCollection.append(newElement)

                        strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }

                            completion(true)
                        })
                    }
                    else {
                        // create that array
                        let newCollection: [[String: Optional<String>]] = [
                            [
                                "name": user.name,
                                "email": user.email,
                                "description": user.description
                            ]
                        ]

                        strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }

                            completion(true)
                        })
                    }
                })
            })
    }

    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public func getDataForPetProfile(path: String, completion: @escaping (Result<PetProfile, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            guard let adoptionType = value["adoptionType"] as? String,
                  let age = value["age"] as? String,
                  let description = value["description"] as? String,
                  let gender = value["gender"] as? String,
                  let kidFriendly = value["kidFriendly"] as? Bool,
                  let environment = value["environment"] as? String,
                  let nameOfPet = value["nameOfPet"] as? String,
                  let neutered = value["neutered"] as? Bool,
                  let size = value["size"] as? String,
                  let trained = value["trained"] as? Bool,
                  let typeProfile = value["typeProfile"] as? String,
                  let owner = value["owner"] as? [String:Any],
                  let ownerName = owner["name"] as? String,
                  let ownerEmail = owner["email"] as? String,
                  let uuid = value["uuid"] as? String else {
                return
            }
                
            let ownerObject = [
                "name": ownerName,
                "email": ownerEmail
            ]
                
            guard let downloadURLs = value["photosDownloadURLs"] as? [[String:Any]] else {
                return
            }
                
            let petProfile = PetProfile(typeProfile: typeProfile,
                                  name: nameOfPet,
                                  description: description,
                                  gender: gender,
                                  age: age,
                                  adoptionType: adoptionType,
                                  size: size,
                                  neutered: neutered,
                                  trained: trained,
                                  kidFriendly: kidFriendly,
                                  environment: environment,
                                  photosDownloadURLs: downloadURLs,
                                  owner: ownerObject,
                                  uuid: uuid)
            
            completion(.success(petProfile))
        }
    }

}

//MARK: - Pet profile

extension DatabaseManager {
    public func getAllProfiles(currentUserEmail: String, completion: @escaping (Result<[PetProfile], Error>) -> Void) {
            database.child("pet-profiles").observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [[String: Any]] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                let petProfiles: [PetProfile] = value.compactMap ({ dictionary in
                    guard let adoptionType = dictionary["adoptionType"] as? String,
                          let age = dictionary["age"] as? String,
                          let description = dictionary["description"] as? String,
                          let gender = dictionary["gender"] as? String,
                          let kidFriendly = dictionary["kidFriendly"] as? Bool,
                          let environment = dictionary["environment"] as? String,
                          let nameOfPet = dictionary["nameOfPet"] as? String,
                          let neutered = dictionary["neutered"] as? Bool,
                          let size = dictionary["size"] as? String,
                          let trained = dictionary["trained"] as? Bool,
                          let typeProfile = dictionary["typeProfile"] as? String,
                          let owner = dictionary["owner"] as? [String:Any],
                          let ownerName = owner["name"] as? String,
                          let ownerEmail = owner["email"] as? String,
                          let uuid = dictionary["uuid"] as? String else {
                        return nil
                    }
                    
                    let ownerObject = [
                        "name": ownerName,
                        "email": ownerEmail
                    ]
                    
                    guard let downloadURLs = dictionary["photosDownloadURLs"] as? [[String:Any]] else {
                         return nil
                    }
                    
                    return PetProfile(typeProfile: typeProfile,
                                      name: nameOfPet,
                                      description: description,
                                      gender: gender,
                                      age: age,
                                      adoptionType: adoptionType,
                                      size: size,
                                      neutered: neutered,
                                      trained: trained,
                                      kidFriendly: kidFriendly,
                                      environment: environment,
                                      photosDownloadURLs: downloadURLs,
                                      owner: ownerObject,
                                      uuid: uuid)
                })
                
//                petProfiles.removeAll(where: {$0.owner == currentUserEmail})
                
                completion(.success(petProfiles))
            })
    }
    
    public func getOwnerProfiles(currentUserEmail: String, completion: @escaping (Result<[PetProfile], Error>) -> Void) {
            database.child("\(currentUserEmail)/pet-profiles").observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [String:[String: Any]] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                var petProfiles: [PetProfile] = []
                for (_, dictionary) in value {
                    guard let adoptionType = dictionary["adoptionType"] as? String,
                          let age = dictionary["age"] as? String,
                          let description = dictionary["description"] as? String,
                          let gender = dictionary["gender"] as? String,
                          let kidFriendly = dictionary["kidFriendly"] as? Bool,
                          let environment = dictionary["environment"] as? String,
                          let nameOfPet = dictionary["nameOfPet"] as? String,
                          let neutered = dictionary["neutered"] as? Bool,
                          let size = dictionary["size"] as? String,
                          let trained = dictionary["trained"] as? Bool,
                          let typeProfile = dictionary["typeProfile"] as? String,
                          let uuid = dictionary["uuid"] as? String else {
                        return
                    }
                    
                    
                    guard let downloadURLs = dictionary["photosDownloadURLs"] as? [[String:Any]] else {
                        print(dictionary["photosDownloadURLs"]!)
                        return
                    }

//                    var URLs: [String] = []
//                    for (index, downloadURL) in downloadURLs.enumerated() {
//                        if let url = downloadURL["picture\(index)"] {
//                            URLs.append(url)
//                        }
//                    }
                    
                    petProfiles.append(PetProfile(typeProfile: typeProfile,
                                      name: nameOfPet,
                                      description: description,
                                      gender: gender,
                                      age: age,
                                      adoptionType: adoptionType,
                                      size: size,
                                      neutered: neutered,
                                      trained: trained,
                                      kidFriendly: kidFriendly,
                                      environment: environment,
                                      photosDownloadURLs: downloadURLs,
                                      uuid: uuid))
                    
                }
                
//                let petProfiles: [PetProfile] = value.compactMap ({ dictionary in
//                    guard let adoptionType = dictionary["adoptionType"] as? String,
//                          let age = dictionary["age"] as? String,
//                          let description = dictionary["description"] as? String,
//                          let gender = dictionary["gender"] as? String,
//                          let kidFriendly = dictionary["kidFriendly"] as? Bool,
//                          let environment = dictionary["environment"] as? String,
//                          let nameOfPet = dictionary["nameOfPet"] as? String,
//                          let neutered = dictionary["neutered"] as? Bool,
//                          let size = dictionary["size"] as? String,
//                          let trained = dictionary["trained"] as? Bool,
//                          let typeProfile = dictionary["typeProfile"] as? String,
//                          let uuid = dictionary["uuid"] as? String else {
//                        return nil
//                    }
//
//                    guard let downloadURLs = dictionary["photosDownloadURLs"] as? [[String: String]] else {
//                         return nil
//                    }
//
//                    var URLs: [String] = []
//                    for (index, downloadURL) in downloadURLs.enumerated() {
//                        if let url = downloadURL["picture\(index)"] {
//                            URLs.append(url)
//                        }
//                    }
//
//                    return PetProfile(typeProfile: typeProfile,
//                                      name: nameOfPet,
//                                      description: description,
//                                      gender: gender,
//                                      age: age,
//                                      adoptionType: adoptionType,
//                                      size: size,
//                                      neutered: neutered,
//                                      trained: trained,
//                                      kidFriendly: kidFriendly,
//                                      environment: environment,
//                                      photosDownloadURLs: URLs,
//                                      uuid: uuid)
//                })
                
//                petProfiles.removeAll(where: {$0.owner == currentUserEmail})
                
                completion(.success(petProfiles))
            })
    }
    
    public func insertProfile(with profile: PetProfile, with user: User, completion: @escaping (Bool) -> Void) {
        let owner = [
            "name": profile.owner!["name"],
            "email": profile.owner!["email"]
        ]
//            let location = [
//                "latitude": ,
//                "longitude":
//            ]
        var newProfile = [
            "typeProfile": profile.typeProfile,
            "nameOfPet": profile.name,
            "description": profile.description,
            "gender": profile.gender,
            "age": profile.age,
            "adoptionType": profile.adoptionType,
            "size": profile.size,
            "neutered": profile.neutered,
            "trained": profile.trained,
            "kidFriendly": profile.kidFriendly,
            "environment": profile.environment,
            "uuid": profile.uuid
        ] as [String : Any]
        
//        var downloadURLCollection: [[String: Any]] = [[:]]
//
//        if let downloadURLs = profile.photosDownloadURLs {
//            for (index, downloadURL) in downloadURLs.enumerated() {
//                downloadURLCollection.append(["picture\(index)" : downloadURL])
//            }
//            newProfile["photosDownloadURLs"] = downloadURLs
//        }
        
        newProfile["photosDownloadURLs"] = profile.photosDownloadURLs
        
        database.child("\(user.safeEmail)/pet-profiles/\(profile.uuid)").setValue(newProfile, withCompletionBlock: { [weak self] error, _ in
            
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            newProfile["owner"] = owner
            
            strongSelf.database.child("pet-profiles/\(profile.uuid)").setValue(newProfile, withCompletionBlock: { error, _ in

                guard error == nil else {
                    print("failed to write to database")
                    completion(false)
                    return
                }
                
                completion(true)
            })
        })
            
//            self.database.child("pet-profiles").observeSingleEvent(of: .value, with: { snapshot in
//                    if var profilesCollection = snapshot.value as? [[String: Any]] {
//                        // append to profiles dictionary
//                        profilesCollection.append(newProfile)
//
//                        self.database.child("pet-profiles").setValue(profilesCollection, withCompletionBlock: { error, _ in
//                            guard error == nil else {
//                                completion(false)
//                                return
//                            }
//
//                            completion(true)
//                        })
//                    }
//                    else {
//                        // create that array
//                        let newCollection: [[String: Any]] = [newProfile]
//
//                        self.database.child("pet-profiles").setValue(newCollection, withCompletionBlock: { error, _ in
//                            guard error == nil else {
//                                completion(false)
//                                return
//                            }
//
//                            completion(true)
//                        })
//                    }
//                })
            
//            if var profilesCollection = snapshot.value as? [[String: Any]] {
//                newProfile.removeValue(forKey: "owner")
//                // append to profiles dictionary
//                profilesCollection.append(newProfile)
//
//                self.database.child("\(user.safeEmail)/pet-profiles").setValue(profilesCollection, withCompletionBlock: { error, _ in
//                    guard error == nil else {
//                        completion(false)
//                        return
//                    }
//                })
//            } else {
//                // create that array
//                let newCollection: [[String: Any]] = [newProfile]
//
//                self.database.child("\(user.safeEmail)/pet-profiles").setValue(newCollection, withCompletionBlock: { error, _ in
//                    guard error == nil else {
//                        completion(false)
//                        return
//                    }
//                })
//            }
//        })
    }
    
    public func addToFavorites(_ profile: PetProfile, for currentUserEmail: String, completion: @escaping (Bool, PetProfile) -> Void) {
        database.child("\(currentUserEmail)/favorites").observeSingleEvent(of: .value) { (snapshot) in
            let owner = [
                "name": profile.owner!["name"],
                "email": profile.owner!["email"]
            ]
            var newProfile = [
                "typeProfile": profile.typeProfile,
                "nameOfPet": profile.name,
                "description": profile.description,
                "gender": profile.gender,
                "age": profile.age,
                "adoptionType": profile.adoptionType,
                "size": profile.size,
                "neutered": profile.neutered,
                "trained": profile.trained,
                "kidFriendly": profile.kidFriendly,
                "environment": profile.environment,
                "owner": owner,
                "uuid": profile.uuid
            ] as [String : Any]
            
            if let downloadURLs = profile.photosDownloadURLs{
                newProfile["photosDownloadURLs"] = downloadURLs
            }
            
            if var favoritesCollection = snapshot.value as? [[String: Any]] {
                // append to profiles dictionary
                favoritesCollection.append(newProfile)

                self.database.child("\(currentUserEmail)/favorites").setValue(favoritesCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false, profile)
                        return
                    }
                    completion(true, profile)
                })
            } else {
                // create that array
                let newCollection: [[String: Any]] = [newProfile]
                
                self.database.child("\(currentUserEmail)/favorites").setValue(newCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false, profile)
                        return
                    }
                    completion(true, profile)
                })
            }
        }
    }
    
    public func getAllFavorites(for currentUserEmail: String, completion: @escaping (Result<[PetProfile], Error>) -> Void) {
            database.child("\(currentUserEmail)/favorites").observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [[String: Any]] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                let petProfiles: [PetProfile] = value.compactMap ({ dictionary in
                    guard let adoptionType = dictionary["adoptionType"] as? String,
                          let age = dictionary["age"] as? String,
                          let description = dictionary["description"] as? String,
                          let gender = dictionary["gender"] as? String,
                          let kidFriendly = dictionary["kidFriendly"] as? Bool,
                          let environment = dictionary["environment"] as? String,
                          let nameOfPet = dictionary["nameOfPet"] as? String,
                          let neutered = dictionary["neutered"] as? Bool,
                          let size = dictionary["size"] as? String,
                          let trained = dictionary["trained"] as? Bool,
                          let typeProfile = dictionary["typeProfile"] as? String,
                          let owner = dictionary["owner"] as? [String:Any],
                          let ownerName = owner["name"] as? String,
                          let ownerEmail = owner["email"] as? String,
                          let uuid = dictionary["uuid"] as? String else {
                        return nil
                    }
                    
                    let ownerObject = [
                        "name": ownerName,
                        "email": ownerEmail
                    ]
                    
                    guard let downloadURLs = dictionary["photosDownloadURLs"] as? [[String:Any]] else {
                         return nil
                    }
                    
                    return PetProfile(typeProfile: typeProfile,
                                      name: nameOfPet,
                                      description: description,
                                      gender: gender,
                                      age: age,
                                      adoptionType: adoptionType,
                                      size: size,
                                      neutered: neutered,
                                      trained: trained,
                                      kidFriendly: kidFriendly,
                                      environment: environment,
                                      photosDownloadURLs: downloadURLs,
                                      owner: ownerObject,
                                      uuid: uuid)
                })
                
                completion(.success(petProfiles))
            })
    }
}

//MARK: - Conversations

extension DatabaseManager {
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap ({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let otherUserName = dictionary["otherUserName"] as? String,
                      let otherUserEmail = dictionary["otherUserEmail"] as? String,
                      let latestMessage = dictionary["latestMessage"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["isRead"] as? Bool else {
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationId,
                                    otherUserName: otherUserName,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
        }
    }
    
    public func doesConversationExist(for currentUserEmail: String, with otherUserEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        database.child("\(currentUserEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            value.forEach({ conversation in
                guard let otherUserEmailDB = conversation["otherUserEmail"] as? String,
                      let conversationId = conversation["id"] as? String else {
                    return
                }
                if (otherUserEmailDB == otherUserEmail) {
                    completion(.success(conversationId))
                    return
                }
            })
            completion(.failure(DatabaseError.failedToFetch))
        }
    }
    
    private func finishCreatingConversation(otherUserName: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool, String) -> Void) {
    //        {
        
    //            "id": String,
    //            "type": text, photo, video,
    //            "content": String,
    //            "date": Date(),
    //            "sender_email": String,
    //            "isRead": true/false,
    //        }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)

            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_), .photo(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_), .custom(_):
                break
            }

            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String,
                  let myName = UserDefaults.standard.value(forKey: "name") else {
                completion(false, conversationID)
                return
            }

            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)

            let collectionMessage: [String: Any] = [
                "id": firstMessage.messageId,
                "type": firstMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "senderEmail": currentUserEmail,
                "senderName": myName,
                "isRead": false,
                "otherUserName": otherUserName
            ]

            let value: [String: Any] = [
                "messages": [
                    collectionMessage
                ]
            ]

            print("adding convo: \(conversationID)")

            database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false, conversationID)
                    return
                }
                completion(true, conversationID)
            })
        }
    
    public func createNewConversation(with otherUserEmail: String, otherUserName: String, firstMessage: Message, completion: @escaping (Bool, String) -> Void) {
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
                  let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                    print("no user")
                    return
            }
            let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)

            let ref = database.child("\(safeEmail)")

            ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard var userNode = snapshot.value as? [String: Any] else {
                    completion(false, "")
                    print("user not found")
                    return
                }

                let messageDate = firstMessage.sentDate
                let dateString = ChatViewController.dateFormatter.string(from: messageDate)

                var message = ""

                switch firstMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(_):
                    break
                case .video(_):
                    break
                case .location(_):
                    break
                case .emoji(_):
                    break
                case .audio(_):
                    break
                case .contact(_):
                    break
                case .custom(_):
                    break
                }

                let uuid = NSUUID().uuidString
                let conversationId = "conversation_\(uuid)"

                let newConversationData: [String: Any] = [
                    "id": conversationId,
                    "otherUserEmail": otherUserEmail,
                    "otherUserName": otherUserName,
                    "latestMessage": [
                        "date": dateString,
                        "message": message,
                        "isRead": false
                    ]
                ]

                let recipientNewConversationData: [String: Any] = [
                    "id": conversationId,
                    "otherUserEmail": safeEmail,
                    "otherUserName": currentName,
                    "latestMessage": [
                        "date": dateString,
                        "message": message,
                        "isRead": false
                    ]
                ]
                
                //Update recipient conversation entry
                let safeOtherUserEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
                // Update recipient conversation entry
                self?.database.child("\(safeOtherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    if var conversations = snapshot.value as? [[String: Any]] {
                        // append
                        conversations.append(recipientNewConversationData)
                        self?.database.child("\(safeOtherUserEmail)/conversations").setValue(conversations)
                    }
                    else {
                        // create
                        self?.database.child("\(safeOtherUserEmail)/conversations").setValue([recipientNewConversationData])
                    }
                })

                // Update current user conversation entry
                if var conversations = userNode["conversations"] as? [[String: Any]] {
                    // conversation array exists for current user
                    // you should append
                    conversations.append(newConversationData)
                    userNode["conversations"] = conversations
                    ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                        guard error == nil else {
                            completion(false, conversationId)
                            return
                        }
                        self?.finishCreatingConversation(otherUserName: otherUserName,
                                                         conversationID: "\(conversationId)",
                                                         firstMessage: firstMessage,
                                                         completion: completion)
                    })
                } else {
                    // conversation array does NOT exist
                    // create it
                    userNode["conversations"] = [
                        newConversationData
                    ]

                    ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                        guard error == nil else {
                            completion(false, conversationId)
                            return
                        }

                        self?.finishCreatingConversation(otherUserName: otherUserName,
                                                         conversationID: "\(conversationId)",
                                                         firstMessage: firstMessage,
                                                         completion: completion)
                    })
                }
            })
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap ({ dictionary in
                guard let senderName = dictionary["senderName"] as? String,
                      let otherUserName = dictionary["otherUserName"] as? String,
                      let isRead = dictionary["isRead"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["senderEmail"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                }
                
                let sender = Sender(senderId: senderEmail,
                                    displayName: senderName)
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: .text(content))
            })
            
            completion(.success(messages))
        }
    }
    
    public func sendMessage(to conversationId: String, otherUserEmail: String, otherUserName: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let myName = UserDefaults.standard.value(forKey: "name") else {
            completion(false)
            return
        }
        
        self.database.child("\(conversationId)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as?
                    [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_), .photo(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_), .custom(_):
                break
            }
            
            let currentUserSafeEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessage: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "senderEmail": currentUserSafeEmail,
                "isRead": false,
                "senderName": myName,
                "otherUserName": otherUserName
            ]
            
            currentMessages.append(newMessage)
            
            strongSelf.database.child("\(conversationId)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentUserSafeEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "isRead": false,
                        "message": message
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversationId {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    
                    targetConversation?["latestMessage"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConversation
                    strongSelf.database.child("\(currentUserSafeEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        //Update latest message for receiving recipient user
                        let safeOtherUserEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
                        strongSelf.database.child("\(safeOtherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "isRead": false,
                                "message": message
                            ]
                            
                            var targetConversation: [String: Any]?
                            
                            var position = 0
                            
                            for conversationDictionary in otherUserConversations {
                                if let currentId = conversationDictionary["id"] as? String, currentId == conversationId {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                            }
                            
                            targetConversation?["latestMessage"] = updatedValue
                            guard let finalConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConversation
                            strongSelf.database.child("\(safeOtherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                    })
                })
            }
        }
    }
}
