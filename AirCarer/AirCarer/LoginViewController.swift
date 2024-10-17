//
//  LoginViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/9/17.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets for the Customer and Service Provider container views
    @IBOutlet weak var customerContainerView: UIView!
    @IBOutlet weak var serviceProviderContainerView: UIView!
    
    // Outlets for the Image Views
    @IBOutlet weak var customerImageView: UIImageView!
    @IBOutlet weak var serviceProviderImageView: UIImageView!
    
    // Outlets for the text fields (Mobile Number and Password)
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Outlets for the Login button
    @IBOutlet weak var loginButton: UIButton!
    
    // Color constants for light grey and #6cacf5
    let lightGreyColor = UIColor.lightGray.cgColor
    let activeColor = UIColor(red: 0.424, green: 0.675, blue: 0.961, alpha: 1.0).cgColor // #6cacf5
    
    // Keep track of which role is currently selected
    var selectedRole: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup for Customer View
        setupViewAppearance(containerView: customerContainerView)
        
        // Setup for Service Provider View
        setupViewAppearance(containerView: serviceProviderContainerView)
        
        // Set up corner radius for images
        customerImageView.layer.cornerRadius = 30
        customerImageView.layer.masksToBounds = true
        
        serviceProviderImageView.layer.cornerRadius = 30
        serviceProviderImageView.layer.masksToBounds = true
        
        // Set up the text fields with light grey border and delegate
        setupTextFieldAppearance(textField: mobileNumberTextField)
        setupTextFieldAppearance(textField: passwordTextField)
        
        // Set the delegate to self to monitor text changes
        mobileNumberTextField.delegate = self
        passwordTextField.delegate = self
        
        // Set up corner radius for the Login button
        setupButtonAppearance(button: loginButton)
        
        // Add tap gesture for Customer View
        let customerTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCustomer))
        customerContainerView.addGestureRecognizer(customerTapGesture)
        
        // Add tap gesture for Service Provider View
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
        containerView.layer.borderWidth = 2  // Border width of 2 points
        containerView.layer.borderColor = lightGreyColor  // Initial border color (light grey)
        containerView.layer.cornerRadius = 10  // Corner radius of 10 points
        containerView.layer.masksToBounds = true  // Ensure content stays within rounded corners
    }
    
    // Function to set up the appearance of the text fields
    func setupTextFieldAppearance(textField: UITextField) {
        // Add light grey border to the text field
        textField.layer.borderWidth = 1  // Border width of 1 point
        textField.layer.borderColor = UIColor.lightGray.cgColor  // Light grey border color
        textField.layer.cornerRadius = 5  // Optional: Set a corner radius
        textField.layer.masksToBounds = true
        
        // Set the placeholder text color to light grey
        if let placeholderText = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
        
        // Set the initial text color to black for user input
        textField.textColor = UIColor.black
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
            // If the selected view is tapped again, deselect it (revert to light grey)
            UIView.animate(withDuration: 0.2) {
                containerView.layer.borderColor = self.lightGreyColor
            }
            selectedRole = nil // No role is selected now
        } else {
            // Deselect the previously selected role (if any)
            if let previousSelection = selectedRole {
                UIView.animate(withDuration: 0.2) {
                    previousSelection.layer.borderColor = self.lightGreyColor
                }
            }
            // Select the new role (change border to #6cacf5)
            UIView.animate(withDuration: 0.2) {
                containerView.layer.borderColor = self.activeColor
            }
            selectedRole = containerView // Update the selected role
        }
    }
    
    // UITextFieldDelegate method to monitor when users are typing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black  // Ensure text is black while typing
    }
    
    // UITextFieldDelegate method to handle placeholder appearance when text is cleared
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Combine the current text and the replacement string to see the updated text
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        // If the text field becomes empty, show the placeholder in light grey
        if updatedText.isEmpty {
            if let placeholderText = textField.placeholder {
                textField.attributedPlaceholder = NSAttributedString(
                    string: placeholderText,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                )
            }
        }
        return true
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "signupSegue", sender: self)
    }
}
