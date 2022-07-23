//
//  FavoritesViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 01/06/2022.
//

import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var favoritesTableView: UITableView!
    
    private let noFavoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites added yet"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    var favorites: [PetProfile] = []
    
    private var model: PetProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noFavoritesLabel)
        favoritesTableView.isHidden = true

        favoritesTableView.register(UINib(nibName: K.petProfilePreviewCellNibname, bundle: nil), forCellReuseIdentifier: K.petProfilePreviewCell)
        
        favoritesTableView.dataSource = self
        favoritesTableView.delegate = self
        favoritesTableView.tableFooterView = UIView()
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let currentUserSafeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(loadFavoritesList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        DatabaseManager.shared.getAllFavorites(for: currentUserSafeEmail, completion: { result in
            switch result {
            case .success(let favorites):
                guard !favorites.isEmpty else {
                    print("no favorites")
                    self.favoritesTableView.isHidden = true
                    self.noFavoritesLabel.isHidden = false
                    return
                }
                print("got conversation")
                self.noFavoritesLabel.isHidden = true
                self.favoritesTableView.isHidden = false
                self.favorites = favorites
                DispatchQueue.main.async {
                    print("reload data")
                    self.favoritesTableView.reloadData()
                }
                
            case .failure(let error):
                self.favoritesTableView.isHidden = true
                self.noFavoritesLabel.isHidden = false
                print("Error getting favorites: \(error)")
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noFavoritesLabel.frame = CGRect(x: 10,
                                            y: (view.bounds.height-100)/2,
                                            width: view.bounds.width-20,
                                            height: 100)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == K.showPetProfileSegue) {
            let petProfileViewController = segue.destination as! PetProfileViewController
            petProfileViewController.model = self.model
        }
    }

}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = favorites[indexPath.row]
        print(favorites.count)
        let cell = tableView.dequeueReusableCell(withIdentifier: K.petProfilePreviewCell, for: indexPath) as! PetProfilePreviewCell
        cell.petName.text = model.name
        cell.petGenderAgeLabel.text = "\(model.gender), \(model.age)"
        cell.petTypePicture.image = UIImage(named: model.typeProfile)
        if let downloadURLs = model.photosDownloadURLs{
            let firstPhotoURL = URL(string: downloadURLs[0].first?.value as! String)
            cell.petPicture.sd_setImage(with: firstPhotoURL, completed: nil)
        }
//        let path = "images/\(String(describing: model.owner!["email"]!))/\(model.uuid)/first_picture.png"
//        print(path)
//        StorageManager.shared.downloadURL(for: path, completion: { result in
//            switch result {
//            case .success(let url):
//                DispatchQueue.main.async {
//                    cell.petPicture.sd_setImage(with: url, completed: nil)
//                }
//            case .failure(let error):
//                print("Failed to get download url: \(error)")
//            }
//        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        model = favorites[indexPath.row]
        self.performSegue(withIdentifier: K.showPetProfileSegue, sender: self)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 160
//    }
    
    
}

