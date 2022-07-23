//
//  TabBarViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 20/03/2022.
//

import UIKit
import CoreLocation
import VerticalCardSwiper
import FBSDKLoginKit
import FirebaseAuth

class TabBarViewController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let arrayOfTabBarItems = self.tabBar.items as AnyObject as? NSArray,
           let myPetsBarItem = arrayOfTabBarItems[0] as? UITabBarItem,
           let messagesBarItem = arrayOfTabBarItems[1] as? UITabBarItem,
           let favoritesBarItem = arrayOfTabBarItems[3] as? UITabBarItem,
           let myProfileBarItem = arrayOfTabBarItems[4] as? UITabBarItem {
            if FirebaseAuth.Auth.auth().currentUser == nil &&
                AccessToken.current == nil {
                myPetsBarItem.isEnabled = false
                messagesBarItem.isEnabled = false
                favoritesBarItem.isEnabled = false
                myProfileBarItem.isEnabled = false
            }
        }
        
        selectedIndex = defaultIndex
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }    
    ///TODO - save current location for each user
}
