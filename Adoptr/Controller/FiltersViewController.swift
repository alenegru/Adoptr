//
//  FiltersViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 27/04/2022.
//

import UIKit

class FiltersViewController: UIViewController {
    @IBOutlet weak var petTypeTableView: UITableView!
    @IBOutlet weak var ageTableView: UITableView!
    @IBOutlet weak var genderTableView: UITableView!
    @IBOutlet weak var sizeTableView: UITableView!
    @IBOutlet weak var adoptionTypeTableView: UITableView!
    @IBOutlet weak var environmentTableView: UITableView!
    @IBOutlet weak var neuteredSwitch: UISwitch!
    @IBOutlet weak var trainedSwitch: UISwitch!
    @IBOutlet weak var kidFriendlySwitch: UISwitch!
    @IBOutlet weak var filterButton: StandardButton!
    
    var petProfiles: [PetProfile] = []
    var filteredPetProfiles: [PetProfile] = []
    
    var adoptionTypes: [String] = ["Adopt", "Foster"]
    var environments: [String] = ["Indoor", "Outdoor"]
    var genders: [String] = ["Male", "Female", "Multiple"]
    var sizes: [String] = ["Small", "Medium", "Large"]
    var ages: [String] = ["Baby", "Junior", "Adult", "Senior"]
    var petTypes: [String] = ["Dog", "Cat", "Parrot", "Bird", "Fish", "Turtle", "Rabbit", "Rodent", "Reptile"]
    
    var selectedIndexesAdoptionTypes: [Int] = []
    var selectedIndexesEnvironments: [Int] = []
    var selectedIndexesGenders: [Int] = []
    var selectedIndexesSizes: [Int] = []
    var selectedIndexesAges: [Int] = []
    var selectedIndexesPetTypes: [Int] = []
    
    public var completion: (([PetProfile]) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        petTypeTableView.delegate = self
        petTypeTableView.dataSource = self
        petTypeTableView.tag = 1

        ageTableView.delegate = self
        ageTableView.dataSource = self
        ageTableView.tag = 2

        genderTableView.delegate = self
        genderTableView.dataSource = self
        genderTableView.tag = 3

        sizeTableView.delegate = self
        sizeTableView.dataSource = self
        sizeTableView.tag = 4

        adoptionTypeTableView.delegate = self
        adoptionTypeTableView.dataSource = self
        adoptionTypeTableView.tag = 5

        environmentTableView.delegate = self
        environmentTableView.dataSource = self
        environmentTableView.tag = 6
        
        filterButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)
        
        DispatchQueue.main.asyncAfter(deadline: (.now() + .milliseconds(500))) {
                    self.petTypeTableView.flashScrollIndicators()
                }
        
    }
    
    @IBAction func filterButtonPressed(_ sender: StandardButton) {
        let navigationController = self.presentingViewController as! UINavigationController
        let tabBarController = navigationController.topViewController as! TabBarViewController
        let senderController = tabBarController.selectedViewController as! HomeViewController
        
        if !selectedIndexesAdoptionTypes.isEmpty {
            var wantedAdoptionTypes: [String] = []
            for index in selectedIndexesAdoptionTypes {
                wantedAdoptionTypes.append(adoptionTypes[index])
            }
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                for type in wantedAdoptionTypes {
                    if (petProfile.typeProfile == type) {
                        return true
                    }
                }
                return false
            }
        }
        
        if !selectedIndexesAges.isEmpty {
            var wantedAges: [String] = []
            for index in selectedIndexesAges {
                wantedAges.append(ages[index])
            }
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                for age in wantedAges {
                    if (petProfile.age == age) {
                        return true
                    }
                }
                return false
            }
        }
        
        if !selectedIndexesSizes.isEmpty {
            var wantedSizes: [String] = []
            for index in selectedIndexesSizes {
                wantedSizes.append(sizes[index])
            }
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                for size in wantedSizes {
                    if (petProfile.size == size) {
                        return true
                    }
                }
                return false
            }
        }
        
        if !selectedIndexesGenders.isEmpty {
            var wantedGenders: [String] = []
            for index in selectedIndexesGenders {
                wantedGenders.append(genders[index])
            }
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                for gender in wantedGenders {
                    if (petProfile.gender == gender) {
                        return true
                    }
                }
                return false
            }
        }
        
        if !selectedIndexesEnvironments.isEmpty {
            var wantedEnvironments: [String] = []
            for index in selectedIndexesEnvironments {
                wantedEnvironments.append(environments[index])
            }
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                for environment in wantedEnvironments {
                    if (petProfile.environment == environment) {
                        return true
                    }
                }
                return false
            }
        }
        
        if !selectedIndexesPetTypes.isEmpty {
            var wantedPetTypes: [String] = []
            for index in selectedIndexesPetTypes {
                wantedPetTypes.append(petTypes[index])
            }
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                for petType in wantedPetTypes {
                    if (petProfile.typeProfile == petType) {
                        return true
                    }
                }
                return false
            }
        }
        
        if (neuteredSwitch.isOn) {
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                return petProfile.neutered
            }
        }
            
        if (trainedSwitch.isOn) {
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                return petProfile.trained
            }
        }
            
        if (kidFriendlySwitch.isOn) {
            filteredPetProfiles = filteredPetProfiles.filter { petProfile in
                return petProfile.kidFriendly
            }
        }
        
        dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.completion?(strongSelf.filteredPetProfiles)
            //senderController.petProfilesWithoutOwn = self.filteredPetProfiles
        }
    }
    
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1:
            return petTypes.count
        case 2:
            return ages.count
        case 3:
            return genders.count
        case 4:
            return sizes.count
        case 5:
            return adoptionTypes.count
        case 6:
            return environments.count
        default:
            fatalError("Invalid table")
        }
    }
    
    func configure(cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if (selectedIndexesPetTypes.contains(indexPath.row)) {
            cell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            cell.imageView?.image = UIImage(systemName: "checkmark.circle")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch tableView.tag {
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "petTypeCell", for: indexPath)
            cell.textLabel?.text = petTypes[indexPath.row]
            configure(cell: cell, forRowAtIndexPath: indexPath)
        case 2:
             cell = tableView.dequeueReusableCell(withIdentifier: "ageCell", for: indexPath)
             cell.textLabel?.text = ages[indexPath.row]
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "genderCell", for: indexPath)
            cell.textLabel?.text = genders[indexPath.row]
        case 4:
             cell = tableView.dequeueReusableCell(withIdentifier: "sizeCell", for: indexPath)
             cell.textLabel?.text = sizes[indexPath.row]
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "adoptionTypeCell", for: indexPath)
            cell.textLabel?.text = adoptionTypes[indexPath.row]
        case 6:
             cell = tableView.dequeueReusableCell(withIdentifier: "environmentCell", for: indexPath)
             cell.textLabel?.text = environments[indexPath.row]
        default:
            fatalError("Invalid table")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentlySelectedCell = tableView.cellForRow(at: indexPath)!
        var currentlySelectedTableViewArray: [Int]
        
        switch tableView.tag {
        case 1:
            currentlySelectedTableViewArray = selectedIndexesPetTypes
        case 2:
            currentlySelectedTableViewArray = selectedIndexesAges
        case 3:
            currentlySelectedTableViewArray = selectedIndexesGenders
        case 4:
            currentlySelectedTableViewArray = selectedIndexesSizes
        case 5:
            currentlySelectedTableViewArray = selectedIndexesAdoptionTypes
        case 6:
            currentlySelectedTableViewArray = selectedIndexesEnvironments
        default:
            fatalError("Invalid table")
        }
        
        if (currentlySelectedTableViewArray.contains(indexPath.row)) {
            currentlySelectedTableViewArray.removeAll(where: {$0 == indexPath.row})
            if (tableView.tag != 1) {
                currentlySelectedCell.imageView?.image = UIImage(systemName: "checkmark.circle")
            }
        } else {
            currentlySelectedTableViewArray.append(indexPath.row)
            if (tableView.tag != 1) {
                currentlySelectedCell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
            }
        }
        
        switch tableView.tag {
        case 1:
            selectedIndexesPetTypes = currentlySelectedTableViewArray
            configure(cell: currentlySelectedCell, forRowAtIndexPath: indexPath)
        case 2:
            selectedIndexesAges = currentlySelectedTableViewArray
        case 3:
            selectedIndexesGenders = currentlySelectedTableViewArray
        case 4:
            selectedIndexesSizes = currentlySelectedTableViewArray
        case 5:
            selectedIndexesAdoptionTypes = currentlySelectedTableViewArray
        case 6:
            selectedIndexesEnvironments = currentlySelectedTableViewArray
        default:
            fatalError("Invalid table")
        }
        
        print("Pet types")
        print(selectedIndexesPetTypes)
    }
}
