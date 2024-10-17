//
//  ServiceProviderPolicyViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/9/17.
//

import UIKit

class ServiceProviderPolicyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func agreeTapped(_ sender: UIButton) {
        // Perform the segue to navigate to the Service Provider Sign Up View Controller
        performSegue(withIdentifier: "goToServiceProviderSignUp", sender: self)
    }
    
    @IBAction func disagreeTapped(_ sender: UIButton) {
        // Go back to the previous view controller
        if self.presentingViewController != nil {
            // If presented modally
            self.dismiss(animated: true, completion: nil)
        } else if self.navigationController != nil {
            // If pushed onto a navigation stack
            self.navigationController?.popViewController(animated: true)
        }
    }
}
