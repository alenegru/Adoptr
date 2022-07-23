//
//  MyPetsViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 28/05/2022.
//

import UIKit

class MyPetsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var ownerPets: [PetProfile] = []
    var currentUserSafeEmail: String = ""
    
    private var model: PetProfile?

    
    private let noPetsLabel: UILabel = {
        let label = UILabel()
        label.text = "No pets added yet"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noPetsLabel)
        //tableView.isHidden = true
        
        tableView.register(UINib(nibName: K.petProfilePreviewCellNibname, bundle: nil), forCellReuseIdentifier: K.petProfilePreviewCell)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPetsLabel.frame = CGRect(x: 10,
                                            y: (view.bounds.height-100)/2,
                                            width: view.bounds.width-20,
                                            height: 100)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == K.showPetProfileSegue) {
            let petProfileViewController = segue.destination as! PetProfileViewController
            guard let petProfile = self.model else {
                return
            }
            petProfileViewController.model = petProfile
        }
    }
    
    @IBAction func addNewProfile(_ sender: UIButton) {
        let typeAnimalViewController = self.storyboard?.instantiateViewController(withIdentifier: "TypeAnimalViewController") as! TypeAnimalViewController
        typeAnimalViewController.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.pushViewController(typeAnimalViewController, animated: true)
    }
    
}

extension MyPetsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = ownerPets[indexPath.row]
        print(ownerPets.count)
        let cell = tableView.dequeueReusableCell(withIdentifier: K.petProfilePreviewCell, for: indexPath) as! PetProfilePreviewCell
        cell.petName.text = model.name
        cell.petGenderAgeLabel.text = "\(model.gender), \(model.age)"
        cell.petTypePicture.image = UIImage(named: model.typeProfile)
        if let downloadURLs = model.photosDownloadURLs{
            let firstPhotoURL = URL(string: downloadURLs[0].first?.value as! String)
            cell.petPicture.sd_setImage(with: firstPhotoURL, completed: nil)
        }
        
        print(model.photosDownloadURLs)
        
//        let path = "images/\(currentUserSafeEmail)/\(model.uuid)/first_picture.png"
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
        return ownerPets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        model = ownerPets[indexPath.row]
        self.performSegue(withIdentifier: K.showPetProfileSegue, sender: self)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 150
//    }
    
    
}
