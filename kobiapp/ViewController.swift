//
//  ViewController.swift
//  kobivadisi
//
//  Created by burak mestan on 13.02.2020.
//  Copyright © 2020 Kobi Vadisi. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var centerController: UIViewController!


    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeController()
    }
    
    func configureHomeController() {
           let homeController = HomeController()
          
           centerController = UINavigationController(rootViewController: homeController)
           
           view.addSubview(centerController.view)
           addChild(centerController)
           centerController.didMove(toParent: self)
       }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
       }
       


}
