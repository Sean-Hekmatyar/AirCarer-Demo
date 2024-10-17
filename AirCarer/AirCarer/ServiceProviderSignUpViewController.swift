//
//  ServiceProviderSignUpViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/9/22.
//

import UIKit

class ServiceProviderSignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var serviceProviderEmailTextField: UITextField!
    @IBOutlet weak var serviceProviderPasswordTextField: UITextField!
    @IBOutlet weak var serviceProviderConfirmPasswordTextField: UITextField!
    
    // A flag to track if the text has been cleared
    var isEmailTextCleared = false
    var isPasswordTextCleared = false
    var isConfirmPasswordTextCleared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegates
        serviceProviderEmailTextField.delegate = self
        serviceProviderPasswordTextField.delegate = self
        serviceProviderConfirmPasswordTextField.delegate = self

        // Set the initial placeholder text with black color
        setBlackPlaceholder(textField: serviceProviderEmailTextField, placeholder: "Enter email here")
        setBlackPlaceholder(textField: serviceProviderPasswordTextField, placeholder: "Enter password here")
        setBlackPlaceholder(textField: serviceProviderConfirmPasswordTextField, placeholder: "Confirm password here")

        // Initially, disable secure text entry so placeholders are visible
        serviceProviderPasswordTextField.isSecureTextEntry = false
        serviceProviderConfirmPasswordTextField.isSecureTextEntry = false

        // Customize the text field borders
        setTextFieldBorders()
    }
    
    // Function to set black placeholder text
    func setBlackPlaceholder(textField: UITextField, placeholder: String) {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
    
    func setTextFieldBorders() {
        // Set emailTextField border
        serviceProviderEmailTextField.layer.borderColor = UIColor.black.cgColor
        serviceProviderEmailTextField.layer.borderWidth = 2.0
        serviceProviderEmailTextField.layer.cornerRadius = 8
        
        // Set passwordTextField border
        serviceProviderPasswordTextField.layer.borderColor = UIColor.black.cgColor
        serviceProviderPasswordTextField.layer.borderWidth = 2.0
        serviceProviderPasswordTextField.layer.cornerRadius = 8
        
        // Set confirmPasswordTextField border
        serviceProviderConfirmPasswordTextField.layer.borderColor = UIColor.black.cgColor
        serviceProviderConfirmPasswordTextField.layer.borderWidth = 2.0
        serviceProviderConfirmPasswordTextField.layer.cornerRadius = 8
    }
    
    // Clear the text only once when the user starts typing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == serviceProviderEmailTextField && !isEmailTextCleared {
            serviceProviderEmailTextField.text = ""
            isEmailTextCleared = true
        } else if textField == serviceProviderPasswordTextField && !isPasswordTextCleared {
            serviceProviderPasswordTextField.text = ""
            serviceProviderPasswordTextField.isSecureTextEntry = true
            isPasswordTextCleared = true
        } else if textField == serviceProviderConfirmPasswordTextField && !isConfirmPasswordTextCleared {
            serviceProviderConfirmPasswordTextField.text = ""
            serviceProviderConfirmPasswordTextField.isSecureTextEntry = true
            isConfirmPasswordTextCleared = true
        }
    }
    
    // Handle when the user finishes editing a text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Restore placeholders if fields are empty
        if textField == serviceProviderEmailTextField && serviceProviderEmailTextField.text?.isEmpty == true {
            serviceProviderEmailTextField.placeholder = "Enter email here"
            isEmailTextCleared = false
        } else if textField == serviceProviderPasswordTextField && serviceProviderPasswordTextField.text?.isEmpty == true {
            serviceProviderPasswordTextField.placeholder = "Enter password here"
            serviceProviderPasswordTextField.isSecureTextEntry = false // Disable secure entry to show placeholder
            isPasswordTextCleared = false
        } else if textField == serviceProviderConfirmPasswordTextField && serviceProviderConfirmPasswordTextField.text?.isEmpty == true {
            serviceProviderConfirmPasswordTextField.placeholder = "Confirm password here"
            serviceProviderConfirmPasswordTextField.isSecureTextEntry = false // Disable secure entry to show placeholder
            isConfirmPasswordTextCleared = false
        }
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        // Validate all fields
        guard let email = serviceProviderEmailTextField.text, !email.isEmpty,
              let password = serviceProviderPasswordTextField.text, !password.isEmpty,
              let confirmPassword = serviceProviderConfirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showError(message: "Please fill in all fields.")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showError(message: "Please enter a valid email address.")
            return
        }
        
        // Check if passwords match
        if password != confirmPassword {
            showError(message: "Passwords do not match.")
            return
        }
        
        // If validation is successful, show success message and perform segue
        showSuccess(message: "Account created successfully!")
    }
    
    @IBAction func goBackToLoginServiceProvider(_ sender: UIButton) {
        performSegue(withIdentifier: "goBackToLoginServiceProvider", sender: self)
    }
    
    // Function to show an error message
    func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // Function to show a success message, and perform to the next segue
    func showSuccess(message: String) {
        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Now perform the segue programmatically after showing the alert
            self.performSegue(withIdentifier: "goToServiceProviderSignupDetails", sender: self)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    // Function to validate email format
    func isValidEmail(_ email: String) -> Bool {
        // Simple regex for email validation
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
