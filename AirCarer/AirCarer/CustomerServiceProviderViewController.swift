//
//  CustomerServiceProviderViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/9/17.
//

import UIKit

class CustomerServiceProviderViewController: UIViewController {
    
    // Outlets for the Customer and Service Provider container views
    @IBOutlet weak var customerContainerView: UIView!
    @IBOutlet weak var serviceProviderContainerView: UIView!
    
    // Outlet for the Confirm button
    @IBOutlet weak var confirmButton: UIButton!
    
    // Keep track of the selected role
    var selectedRole: UIView? = nil
    
    // Color constants for light grey and #6cacf5
    let lightGreyColor = UIColor.lightGray.cgColor
    let activeColor = UIColor(red: 0.424, green: 0.675, blue: 0.961, alpha: 1.0).cgColor // #6cacf5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup for Customer and Service Provider Views
        setupViewAppearance(containerView: customerContainerView)
        setupViewAppearance(containerView: serviceProviderContainerView)
        
        // Set up corner radius for the buttons
        setupButtonAppearance(button: confirmButton)
        
        // Add tap gestures to container views
        let customerTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCustomer))
        customerContainerView.addGestureRecognizer(customerTapGesture)
        
        let serviceProviderTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapServiceProvider))
        serviceProviderContainerView.addGestureRecognizer(serviceProviderTapGesture)
    }
    
    // Helper function to set the corner radius for buttons
    func setupButtonAppearance(button: UIButton) {
        button.layer.cornerRadius = 10  // Adjust the radius value to match your design
        button.layer.masksToBounds = true  // Ensure the button content respects the rounded corners
    }
    
    // Function to set up the appearance of the container views
    func setupViewAppearance(containerView: UIView) {
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = lightGreyColor
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
    }
    
    // Action for when the Customer View is tapped
    @objc func didTapCustomer() {
        toggleRoleSelection(for: customerContainerView)
    }
    
    // Action for when the Service Provider View is tapped
    @objc func didTapServiceProvider() {
        toggleRoleSelection(for: serviceProviderContainerView)
    }
    
    // Function to toggle the role selection, ensuring only one view is selected at a time
    func toggleRoleSelection(for containerView: UIView) {
        if selectedRole == containerView {
            UIView.animate(withDuration: 0.2) {
                containerView.layer.borderColor = self.lightGreyColor
            }
            selectedRole = nil
        } else {
            if let previousSelection = selectedRole {
                UIView.animate(withDuration: 0.2) {
                    previousSelection.layer.borderColor = self.lightGreyColor
                }
            }
            UIView.animate(withDuration: 0.2) {
                containerView.layer.borderColor = self.activeColor
            }
            selectedRole = containerView
        }
    }
    
    // Action for the Confirm Button
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        if selectedRole == customerContainerView {
            // Perform segue to Customer Registration
            performSegue(withIdentifier: "customerRegistrationSegue", sender: self)
        } else if selectedRole == serviceProviderContainerView {
            // Perform segue to Service Provider Registration
            performSegue(withIdentifier: "serviceProviderRegistrationSegue", sender: self)
        } else {
            // No role selected, show an alert
            let alertController = UIAlertController(title: "Select a Role", message: "Please select either Customer or Service Provider to proceed.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Action for the Login Button
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Dismiss the current view and return to the Login VC
        self.dismiss(animated: true, completion: nil)
    }
}
