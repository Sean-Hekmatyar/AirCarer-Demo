//
//  CustomerRegistrationViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/10/15.
//

import UIKit

class CustomerRegistrationViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Outlet for the customer icon
    @IBOutlet weak var customerImageView: UIImageView!
    
    // Outlet for the form container view
    @IBOutlet weak var formContainerView: UIView!
    
    // Outlet for the customer information text fields
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var customerGenderTextField: UITextField!
    @IBOutlet weak var customerMobileNumberTextField: UITextField!
    @IBOutlet weak var customerPasswordTextField: UITextField!
    @IBOutlet weak var customerConfirmPasswordTextField: UITextField!
    
    // Data for gender picker
    let genderOptions = ["Male", "Female", "Other"]
    var genderPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the image round
        customerImageView.layer.cornerRadius = customerImageView.frame.size.width / 2
        customerImageView.layer.masksToBounds = true
        
        // Make the form container view have rounded corners
        formContainerView.layer.cornerRadius = 30
        formContainerView.layer.masksToBounds = true
        
        // Set delegates for text fields
        customerNameTextField.delegate = self
        customerMobileNumberTextField.delegate = self
        customerPasswordTextField.delegate = self
        customerConfirmPasswordTextField.delegate = self
        
        // Set up the gender picker view
        genderPicker.delegate = self
        genderPicker.dataSource = self
        customerGenderTextField.inputView = genderPicker
        customerGenderTextField.delegate = self
        
        // Set secure text entry for password and confirm password
        customerPasswordTextField.isSecureTextEntry = true
        customerConfirmPasswordTextField.isSecureTextEntry = true
    }
    
    // Limit name text field to letters only
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == customerNameTextField {
            let allowedCharacters = CharacterSet.letters
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        if textField == customerMobileNumberTextField {
            // Limit mobile number to 10 characters
            let currentText = (textField.text ?? "") as NSString
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            return updatedText.count <= 10 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        }
        
        return true
    }
    
    // Gender field is not editable, picker only
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == customerGenderTextField {
            return true // Show the picker
        }
        return true
    }
    
    // UIPickerViewDelegate & UIPickerViewDataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        customerGenderTextField.text = genderOptions[row]
        customerGenderTextField.resignFirstResponder() // Dismiss picker when selected
    }
    
    // Validation & Sign-Up
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        // Check if all fields are filled
        guard let name = customerNameTextField.text, !name.isEmpty,
              let gender = customerGenderTextField.text, !gender.isEmpty,
              let mobile = customerMobileNumberTextField.text, !mobile.isEmpty,
              let password = customerPasswordTextField.text, !password.isEmpty,
              let confirmPassword = customerConfirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }
        
        // Validate that the name only contains letters
        let allowedCharacters = CharacterSet.letters
        if name.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            showAlert(message: "Name must contain letters only.")
            return
        }
        
        // Validate mobile number is exactly 10 digits
        if mobile.count != 10 {
            showAlert(message: "Mobile number must be exactly 10 digits.")
            return
        }
        
        // Ensure that mobile number contains only digits
        if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: mobile)) {
            showAlert(message: "Mobile number must contain digits only.")
            return
        }
        
        // Validate password and confirm password match
        if password != confirmPassword {
            showAlert(message: "Password and Confirm Password do not match.")
            return
        }
        
        // All validations have passed
        
        // Display a success message and move to the next screen
        showAlert(message: "Registration successful!", title: "Success")
    }
    
    // Go back to previous step
    @IBAction func returnButtonTapped(_ sender: UIButton) {
        // Dismiss the current view and return to the previous VC
        self.dismiss(animated: true, completion: nil)
    }
    
    // Function to display an alert
    func showAlert(message: String, title: String = "Error") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
