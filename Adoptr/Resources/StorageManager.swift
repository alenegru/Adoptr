//
//  StorageManager.swift
//  Adoptr
//
//  Created by Alexandra Negru on 26/04/2022.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/email-gmail-com_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadPhoto(with data: Data,
                            fileName: String,
                            petProfileId: String,
                            currentUserEmail: String,
                            completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(currentUserEmail)/\(petProfileId)/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(currentUserEmail)/\(petProfileId)/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    print("Failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            }
        })
        
    }
    
    ///Uploads profile picture to firebase storage
    public func uploadProfilePicture(with data: Data,
                            fileName: String,
                            currentUserEmail: String,
                            completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(currentUserEmail)/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(currentUserEmail)/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    print("Failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                UserDefaults.standard.setValue(urlString, forKey: "profilePictureURL")
                completion(.success(urlString))
            }
        })
        
    }
    
    func deletePhoto() {
        let imageRef = storage.child("profilePicture.png")

        //Removes image from storage
        imageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                // File deleted successfully
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)

        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }

            completion(.success(url))
        })
    }
}
