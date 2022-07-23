//
//  HomeViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 03/05/2022.
//

import UIKit
import VerticalCardSwiper
import SDWebImage
import CoreLocation
import FirebaseAuth
import FBSDKLoginKit
import GeoFire

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cardSwiper: VerticalCardSwiper!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var addToFavorites: UIButton!
    @IBOutlet weak var clearFiltersButton: UIButton!
    
    var geoFireRef: DatabaseReference? = Database.database(url: "https://adoptr-cdbe1-default-rtdb.europe-west1.firebasedatabase.app").reference().child("Geolocs")
    var geoFire: GeoFire?
    var myQuery: GFQuery?
    
    var currentUser: User = User(name: "", email: "", description: "")
    var currentIndex: Int = 0
    var locationManager: CLLocationManager = CLLocationManager()
    
    var petProfilesFiltered: [PetProfile] = []
    var allPetProfiles: [PetProfile] = []
    var ownerPetProfiles: [PetProfile] = []
    
    var petProfilesWithoutOwn: [PetProfile] = []
    var favorites: [PetProfile] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearFiltersButton.isEnabled = false
        
        if let name = UserDefaults.standard.value(forKey: "name") as? String,
           let email = UserDefaults.standard.value(forKey: "email") as? String,
           let description = UserDefaults.standard.value(forKey: "description") as? String {
            self.currentUser.name = name
            self.currentUser.email = email
            self.currentUser.description = description
        }
        if FirebaseAuth.Auth.auth().currentUser == nil &&
            AccessToken.current == nil {
            cardSwiper.isSideSwipingEnabled = false
        }
        
        print("Current user email")
        print(self.currentUser.safeEmail)
            
        DatabaseManager.shared.getOwnerProfiles(currentUserEmail: self.currentUser.safeEmail, completion: { result in
            switch (result) {
            case .success(let ownerProfiles):
                print("GOT OWNER PROFILES")
                print(ownerProfiles)
                let myPetsViewController = self.tabBarController?.viewControllers![0] as! MyPetsViewController
                myPetsViewController.ownerPets = ownerProfiles
                myPetsViewController.currentUserSafeEmail = self.currentUser.safeEmail
                self.ownerPetProfiles = ownerProfiles
                DatabaseManager.shared.getAllFavorites(for: self.currentUser.safeEmail, completion: { result in
                    switch result {
                    case .success(let favorites):
                        if !favorites.isEmpty {
                            self.favorites = favorites
                        }
                    case .failure(let error):
                        print("Error getting favorites: \(error)")
                    }
                    self.queryByLocation()
                })
            case .failure(let error):
                print(error)
            }
        })
        
        cardSwiper.datasource = self
        cardSwiper.delegate = self
        
        // register cardcell for storyboard use
        cardSwiper.register(nib: UINib(nibName: "ProfileCardCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCardCell")
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("Enabled location")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            print("not enabled")
        }
        
        geoFire = GeoFire(firebaseRef: geoFireRef!)
    }
    
    func formatDistance(for distanceFromPet: CLLocationDistance) -> String {
        let roundedDistanceFromPet = distanceFromPet.rounded()
        if roundedDistanceFromPet.isZero {
            return "Near you"
        } else if (0 < roundedDistanceFromPet && roundedDistanceFromPet < 1000) {
            switch distanceFromPet {
            case 0...99:
                return "Less than 100m away"
            case 100...199:
                return "Less than 200m away"
            case 200...299:
                return "Less than 300m away"
            case 300...399:
                return "Less than 400m away"
            case 400...499:
                return "Less than 500m away"
            case 500...599:
                return "Less than 600m away"
            case 600...699:
                return "Less than 700m away"
            case 700...799:
                return "Less than 800m away"
            case 800...899:
                return "Less than 900m away"
            case 900...999:
                return "Less than 1km away"
            default:
                break
            }
        }
        return "About \(Int(roundedDistanceFromPet/1000))km away"
    }
    
    func queryByLocation() {
        let latitude = UserDefaults.standard.value(forKey: "latitude") as! Double
        let longitude = UserDefaults.standard.value(forKey: "longitude") as! Double
                
        let userLocation:CLLocation = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                
        myQuery = geoFire?.query(at: userLocation, withRadius: 100)
        
        myQuery?.observe(.keyEntered, with: { (key, location) in
            if !self.ownerPetProfiles.contains(where: { (petProfile) in
                return petProfile.uuid == key
            })  {
                if !self.favorites.contains(where: { (petProfile) in
                    return petProfile.uuid == key
                }) {
                    print("pet-profiles/\(key)")
                    let distanceFromPet = userLocation.distance(from: location)
                    let distanceFromPetString = self.formatDistance(for: distanceFromPet)
                    DatabaseManager.shared.getDataForPetProfile(path: "pet-profiles/\(key)", completion: { result in
                        switch (result) {
                        case .success(var petProfile):
                            print("nu stiu")
                            print(petProfile)
                            petProfile.distanceFromUser = distanceFromPetString
                            
                            DispatchQueue.main.async {
                                if !self.petProfilesWithoutOwn.contains(where: { queriedPetProfile in
                                    queriedPetProfile.uuid == petProfile.uuid
                                }) {
                                    self.petProfilesWithoutOwn.append(petProfile)
                                    self.cardSwiper.reloadData()
                                }
                            }
                        case .failure(let error):
                            print("error getting data for profile \(error)")
                        }
                    })
                }
            }
        })
        
    }
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        if let currentIndex = cardSwiper.focussedCardIndex {
            print("FOCUSSED CARD INDEX")
            print(self.cardSwiper.focussedCardIndex!)
            self.currentIndex = currentIndex
            _ = cardSwiper.swipeCardAwayProgrammatically(at: currentIndex, to: .Left)
        }
    }
    
    @IBAction func addToFavoritesButtonPressed(_ sender: UIButton) {
        if let currentIndex = self.cardSwiper.focussedCardIndex {
            print("FOCUSSED CARD INDEX")
            print(self.cardSwiper.focussedCardIndex!)
            self.currentIndex = currentIndex
            _ = self.cardSwiper.swipeCardAwayProgrammatically(at: currentIndex, to: .Right)
        }
    }
    
    func addProfileToFavorites(_ currentlyShownPetProfile: PetProfile, completion: @escaping ((Bool) -> Void)) {
        print("Add profile to favorites")
        
        DatabaseManager.shared.addToFavorites(currentlyShownPetProfile, for: currentUser.safeEmail, completion: { success, addedPetProfile in
            if (success) {
                let favoritesViewController = self.tabBarController?.viewControllers![3] as! FavoritesViewController
                favoritesViewController.favorites.append(addedPetProfile)
                print("Added to favorites")
                completion(true)
            } else {
                print("failed to add to favorites")
                completion(false)
            }
        })
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
                return
            } else {
                UserDefaults.standard.setValue(Double(locationValue.latitude), forKey: "latitude")
                UserDefaults.standard.setValue(Double(locationValue.longitude), forKey: "longitude")
                //queryByLocation()
            }
        }
        
        UserDefaults.standard.setValue(Double(locationValue.latitude), forKey: "latitude")
        UserDefaults.standard.setValue(Double(locationValue.longitude), forKey: "longitude")
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == K.filterSegue) {
            let filtersViewController = segue.destination as! FiltersViewController
            filtersViewController.petProfiles = petProfilesWithoutOwn
            filtersViewController.filteredPetProfiles = petProfilesWithoutOwn
            self.allPetProfiles = petProfilesWithoutOwn
            filtersViewController.completion = { [weak self] result in
                self?.petProfilesWithoutOwn = result
                self?.clearFiltersButton.isEnabled = true
                self?.cardSwiper.reloadData()
            }
        } else if (segue.identifier == K.messageDirectlySegue) {
            
            let currentPetProfile = petProfilesWithoutOwn[self.currentIndex]
            let currentOwner = currentPetProfile.owner!
            let chatViewController = segue.destination as! ChatViewController
            
            chatViewController.title = currentOwner["name"] ?? ""
            chatViewController.otherUserEmail = currentOwner["email"] ?? ""
            chatViewController.otherUserName = currentOwner["name"] ?? ""

            if let otherUserEmail = currentOwner["email"] {
                DatabaseManager.shared.doesConversationExist(for: currentUser.safeEmail, with: otherUserEmail, completion: { result in
                    switch result {
                    case .success(let conversationId):
                        chatViewController.conversationId = conversationId
                    case .failure(let error):
                        print("does not exist")
                        print("error: \(error)")
                    }
                })
            }
        } else if (segue.identifier == K.showPetProfileSegue) {
            let petProfileViewController = segue.destination as! PetProfileViewController
            let currentlyShownPetProfile = petProfilesWithoutOwn[currentIndex]
            petProfileViewController.model = currentlyShownPetProfile
        }
    }
    
    func getAllProfiles(completion: @escaping ((Bool) -> Void)) {
        DatabaseManager.shared.getAllProfiles(currentUserEmail: self.currentUser.safeEmail, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let petProfiles):
                strongSelf.petProfilesFiltered = petProfiles
                strongSelf.allPetProfiles = petProfiles
                strongSelf.petProfilesWithoutOwn = petProfiles
                DispatchQueue.main.async {
                    self?.cardSwiper.reloadData()
                }
                
                UserDefaults.standard.setValue(strongSelf.petProfilesWithoutOwn[0].owner, forKey: "currentlyShownPetOwner")
                UserDefaults.standard.setValue(0, forKey: "currentlyShownPetProfileIndex")
                
                completion(true)
            case .failure(let error):
                completion(false)
                print("Failed to get profiles: \(error)")
            }
        })
    }
    
    
    @IBAction func clearFiltersButtonPressed(_ sender: UIButton) {
        petProfilesWithoutOwn = allPetProfiles
        clearFiltersButton.isEnabled = false
        cardSwiper.reloadData()
    }
    
}

extension HomeViewController: VerticalCardSwiperDatasource {
    
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        return petProfilesWithoutOwn.count
    }
    
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "ProfileCardCell", for: index) as? ProfileCardCell {
            let pet = petProfilesWithoutOwn[index]

            cardCell.setRandomBackgroundColor()
            cardCell.petNameAgeLabel.text = pet.name
            cardCell.petTypeLabel.text = "\(pet.gender), \(pet.age)"
            cardCell.petTypePicture.image = UIImage(named: pet.typeProfile)
            cardCell.distanceLabel.text = pet.distanceFromUser
            
            //Update variables for swiping
            cardCell.currentlyShownPetOwner = pet.owner!
            cardCell.currentlyShownPetProfile = pet
            if let downloadURLs = pet.photosDownloadURLs {
                let firstPhotoURL = URL(string: downloadURLs[0].first?.value as! String)
                cardCell.petPhoto.sd_setImage(with: firstPhotoURL, completed: nil)
            }
            
//            let path = "images/\(String(describing: pet.owner!["email"]!))/\(pet.uuid)/first_picture.png"
//            print("Path for pet photo: \(path)")
//            StorageManager.shared.downloadURL(for: path, completion: { result in
//                switch result {
//                case .success(let url):
//                    DispatchQueue.main.async {
//                        cardCell.petPhoto.sd_setImage(with: url, completed: nil)
//                    }
//                case .failure(let error):
//                    print("Failed to get download url: \(error)")
//                }
//            })
            return cardCell
        }
        return CardCell()
    }
    
    
}

extension HomeViewController: VerticalCardSwiperDelegate {
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        // called right before the card animates off the screen.
        
        print("will swipe card away")
        
        if swipeDirection == .Left {
            print("FOCUSSED CARD INDEX")
            print(self.cardSwiper.focussedCardIndex!)
            print("Message")
            
            self.currentIndex = self.cardSwiper.focussedCardIndex!
            self.performSegue(withIdentifier: K.messageDirectlySegue, sender: self)
        } else if swipeDirection == .Right {
            print("FOCUSSED CARD INDEX")
            print(self.cardSwiper.focussedCardIndex!)
            print("Add to favorites")
            let currentIndex = self.cardSwiper.focussedCardIndex!

            addProfileToFavorites(petProfilesWithoutOwn[currentIndex], completion: { success in
                if (success) {
                    print("Yes")
                } else {
                    print("No")
                }
            })
        }
        if index < petProfilesWithoutOwn.count {
            print("remove at index")
            petProfilesWithoutOwn.remove(at: index)
        }
    }

    func didSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {

    }
    
    func didDragCard(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        //currentIndex = index
    }
    
    func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int) {
        currentIndex = index
        self.performSegue(withIdentifier: K.showPetProfileSegue, sender: self)
    }
}

