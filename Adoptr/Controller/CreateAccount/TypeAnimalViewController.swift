//
//  TypeAnimalViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 15/04/2022.
//

import UIKit

class TypeAnimalViewController: UIViewController {
    @IBOutlet weak var tableTypesView: UITableView!
    
//    let animals = ["Dog": "dog.png",
//                                     "Cat": "cat.png",
//                                     "Parrot": "parrot.png",
//                                     "Bird": "bird.png",
//                                     "Fish": "fish.png",
//                                     "Turtle": "turtle.png",
//                                     "Rabbit": "rabbit.png",
//                                     "Hamster": "hamster.png",
//                                     "Rodent": "chinchilla.png",
//                                     "Reptile": "chameleon.png"
//    ]
    
    let animals = ["Dog", "Cat", "Parrot", "Bird", "Fish", "Turtle", "Rabbit", "Rodent", "Reptile", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableTypesView.delegate = self
        tableTypesView.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    @IBAction func skipButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: K.skipSegue, sender: self)
    }
    
}

extension TypeAnimalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableTypesView.dequeueReusableCell(withIdentifier: "typeAnimalCell") as! TypeAnimalCell
        //let animal = Array(animals)[indexPath.row]
        let animal = animals[indexPath.row]
        cell.typeLabel.text = animal
        cell.animalImage.image = UIImage(named: animal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example

        guard let currentCell = tableView.cellForRow(at: indexPath) as! TypeAnimalCell? else {
            return
        }
        let textLabel = currentCell.typeLabel.text!
        print("////////////")
        print("Text label from table: \(String(describing: textLabel))")
        UserDefaults.standard.setValue(textLabel, forKey: "animalType")
    }
    
}
