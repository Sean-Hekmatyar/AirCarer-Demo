//
//  ServiceProviderSignupDetailsViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/9/22.
//

import UIKit

class ServiceProviderSignupDetailsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var serviceProviderNicknameTextField: UITextField!
    @IBOutlet weak var serviceProviderContactNumberTextField: UITextField!
    @IBOutlet weak var serviceProviderPostcodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegates
        serviceProviderNicknameTextField.delegate = self
        serviceProviderContactNumberTextField.delegate = self
        serviceProviderPostcodeTextField.delegate = self
        
        // Set the initial placeholder text with black color
        setBlackPlaceholder(textField: serviceProviderNicknameTextField, placeholder: "Enter nickname here")
        setBlackPlaceholder(textField: serviceProviderContactNumberTextField, placeholder: "Enter contact number here")
        setBlackPlaceholder(textField: serviceProviderPostcodeTextField, placeholder: "Confirm postcode here")
        
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
        // Set nicknameTextField border
        serviceProviderNicknameTextField.layer.borderColor = UIColor.black.cgColor
        serviceProviderNicknameTextField.layer.borderWidth = 2.0
        serviceProviderNicknameTextField.layer.cornerRadius = 8
        
        // Set contactNumberTextField border
        serviceProviderContactNumberTextField.layer.borderColor = UIColor.black.cgColor
        serviceProviderContactNumberTextField.layer.borderWidth = 2.0
        serviceProviderContactNumberTextField.layer.cornerRadius = 8
        
        // Set postcodeTextField border
        serviceProviderPostcodeTextField.layer.borderColor = UIColor.black.cgColor
        serviceProviderPostcodeTextField.layer.borderWidth = 2.0
        serviceProviderPostcodeTextField.layer.cornerRadius = 8
    }
    
    // Wipe the placeholder text when the user taps into the text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == serviceProviderNicknameTextField && textField.text == "Enter nickname" {
            textField.text = "" // Clear placeholder text
        } else if textField == serviceProviderContactNumberTextField && textField.text == "Enter contact number" {
            textField.text = "" // Clear placeholder text
        } else if textField == serviceProviderPostcodeTextField && textField.text == "Enter postcode" {
            textField.text = "" // Clear placeholder text
        }
    }
    
    // Restore the placeholder text if the text field is empty
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == serviceProviderNicknameTextField && textField.text?.isEmpty == true {
            textField.text = "Enter nickname"
        } else if textField == serviceProviderContactNumberTextField && textField.text?.isEmpty == true {
            textField.text = "Enter contact number"
        } else if textField == serviceProviderPostcodeTextField && textField.text?.isEmpty == true {
            textField.text = "Enter postcode"
        }
    }
    
    @IBAction func letsGoTapped(_ sender: UIButton) {
        // Validate that all fields are filled
        guard let nickname = serviceProviderNicknameTextField.text, !nickname.isEmpty,
              let contactNumber = serviceProviderContactNumberTextField.text, !contactNumber.isEmpty,
              let postcode = serviceProviderPostcodeTextField.text, !postcode.isEmpty else {
            showError(message: "Please fill in all fields.")
            return
        }
        
        // Validate contact number format
        if !isValidContactNumber(contactNumber) {
            showError(message: "Please enter a valid 10-digit contact number.")
            return
        }
        
        // Validate postcode format
        if !isValidPostcode(postcode) {
            showError(message: "Please enter a valid postcode (4 digits).")
            return
        }
        
        // If validation is successful, show the success message
        showSuccess(message: "Details saved successfully!")
    }
    
    // Function to show an error message
    func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // Function to show a success message
    func showSuccess(message: String) {
        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // After dismissing the alert, perform segue to Login View Controller
            self.performSegue(withIdentifier: "goToLoginFromServiceProviderDetails", sender: self)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    // Function to validate contact number format (10-digit numbers)
    func isValidContactNumber(_ number: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"  // Exactly 10 digits
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePredicate.evaluate(with: number)
    }
    
    // Function to validate postcode format (4-digit numbers)
    func isValidPostcode(_ postcode: String) -> Bool {
        let postcodeRegEx = "^[0-9]{4}$"  // Exactly 4 digits
        let postcodePredicate = NSPredicate(format: "SELF MATCHES %@", postcodeRegEx)
        return postcodePredicate.evaluate(with: postcode)
    }
}
