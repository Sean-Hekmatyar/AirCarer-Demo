//
//  CustomerRequestViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/10/7.
//

import UIKit
import PhotosUI

class CustomerRequestViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var roomTypeTextField: UITextField!
    
    @IBOutlet weak var serviceTypeTextField: UITextField!
    
    // Additional Services Fields
    @IBOutlet weak var wallWashingTextField: UITextField!
    @IBOutlet weak var ovenCleaningTextField: UITextField!
    @IBOutlet weak var rangehoodCleaningTextField: UITextField!
    @IBOutlet weak var microwaveCleaningTextField: UITextField!
    @IBOutlet weak var fridgeCleaningTextField: UITextField!
    @IBOutlet weak var blindsCleaningTextField: UITextField!
    @IBOutlet weak var garageCleaningTextField: UITextField!
    @IBOutlet weak var carpetSteamTextField: UITextField!
    @IBOutlet weak var windowCleaningTextField: UITextField!
    @IBOutlet weak var balconyCleaningTextField: UITextField!
    @IBOutlet weak var singleCarpetTextField: UITextField!
    @IBOutlet weak var tileAndGroutTextField: UITextField!
    
    // Upload Photo Button
    @IBOutlet weak var uploadPhotosButton: UILabel!
    
    // Address Fields
    @IBOutlet weak var addressLine1TextField: UITextField!
    @IBOutlet weak var addressLine2TextField: UITextField!
    @IBOutlet weak var suburbTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    
    // Time Fields
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    // Customer comments to cleaner
    @IBOutlet weak var customerCommentsTextView: UITextView!
    
    // Arrays for Room Type, Service Type, and Australian States
    let roomTypes: [RoomType] = [.studio, .oneBedOneBath, .twoBedOneBath, .twoBedTwoBath, .threeBedOneBath, .threeBedTwoBath, .fourBedTwoBath]
    let serviceTypes: [ServiceType] = [.nonSteam, .steam, .includingSteam]
    let australianStates: [String] = ["NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT"]
    
    var selectedRoomType: RoomType? // Store the selected room type
    var selectedServiceType: ServiceType? // Store the selected service type
    var selectedState: String? // Store the selected state
    var roomTypePicker: UIPickerView! // Picker view for room types
    var serviceTypePicker: UIPickerView! // Picker view for service types
    var statePicker: UIPickerView! // Picker view for states
    var selectedImages: [UIImage] = [] // Array to store uploaded images
    var tempSelectedImages: [UIImage] = [] // Temporary array to hold images during selection
    
    // Time Pickers
    var startTimePicker: UIDatePicker!  // Date picker for start time
    var endTimePicker: UIDatePicker! // Date picker for end time
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Customize text fields and other UI elements
        customizeTextField()
        setupTextFieldBorders()
        
        // Set up pickers
        setupRoomTypePicker()
        setupServiceTypePicker() // Set up for service type
        setupStatePicker()
        setupTimePickers()
        
        // Set up customer comments TextView
        setupCommentsTextView()
    }
    
    // Setup Comments TextView with border, placeholder, and other attributes
    func setupCommentsTextView() {
        customerCommentsTextView.layer.borderColor = UIColor.black.cgColor
        customerCommentsTextView.layer.borderWidth = 1.5
        customerCommentsTextView.layer.cornerRadius = 8.0
        customerCommentsTextView.layer.masksToBounds = true

        // Set placeholder text
        customerCommentsTextView.text = "Leave your comments here (optional)"
        customerCommentsTextView.textColor = .lightGray
        customerCommentsTextView.delegate = self
    }
    
    // Clear placeholder when the user starts editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // Reset placeholder when the user ends editing
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Leave your comments here (optional)"
            textView.textColor = UIColor.lightGray
        }
    }
    
    // Upload Photos Action
    @IBAction func uploadPhotosTapped(_ sender: UIButton) {
        // Store previous images temporarily before uploading
        tempSelectedImages = selectedImages

        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0 // Allow unlimited selection of images
        config.filter = .images // We want to pick images, not videos

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }

    // PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if results.isEmpty {
            // User canceled, revert to previously selected images
            return
        }

        // Clear the original images and add the newly selected ones
        selectedImages.removeAll()

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.selectedImages.append(image)
                    }
                }
            }
        }
    }
    
    // Submit Request Action
    @IBAction func submitRequestTapped(_ sender: UIButton) {
        // Validate all fields before proceeding
        if validateFields() {
            // Check if there is already a request in "In Queue" or "In Progress" status
            if checkForPendingRequests() {
                // Show a confirmation alert if there are pending requests
                let alertController = UIAlertController(
                    title: "Request In Progress",
                    message: "You already have a request that is in process. Are you sure you want to create another one?",
                    preferredStyle: .alert
                )

                let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    // Proceed to confirm request as usual
                    self?.performSegue(withIdentifier: "confirmRequest", sender: self)
                }

                let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)

                self.present(alertController, animated: true, completion: nil)
            } else {
                // Proceed to confirm request as usual if no pending requests
                performSegue(withIdentifier: "confirmRequest", sender: self)
            }
        }
    }

    // Check if there is a pending request in progress
    func checkForPendingRequests() -> Bool {
        // Get all cleaning services from the manager
        let allRequests = CleaningServiceManager.shared.cleaningServices

        // Check if there is any request with "In Queue" or "In Progress" status
        return allRequests.contains { $0.taskStatus == .inQueue || $0.taskStatus == .inProgress }
    }

    // Passing Data to ConfirmRequestViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmRequest" {
            if let confirmVC = segue.destination as? ConfirmRequestViewController {
                // Pass the room type
                confirmVC.roomType = roomTypeTextField.text
                confirmVC.serviceType = serviceTypeTextField.text

                // Pass the time range (start and end time)
                confirmVC.timeRange = "\(startTimeTextField.text ?? "") ~ \(endTimeTextField.text ?? "")"

                // Pass the address
                confirmVC.address = getFullAddress()

                // Pass the uploaded images
                confirmVC.uploadedImages = selectedImages

                // Capture customer comments: pass "No comments" if empty or placeholder is shown
                let customerComments: String
                if customerCommentsTextView.text.isEmpty || customerCommentsTextView.text == "Leave your comments here (optional)" {
                    customerComments = "No comments"
                } else {
                    customerComments = customerCommentsTextView.text
                }
                confirmVC.customerComments = customerComments

                // Capture additional services and quantities
                var additionalRequests: [String] = []
                var additionalServiceQuantities: [String: Int] = [:]

                // Check each additional service text field and add it to the array if a quantity is entered
                if let wallWashingQuantity = wallWashingTextField.text, let quantity = Int(wallWashingQuantity), quantity > 0 {
                    additionalRequests.append("Wall washing x \(quantity)")
                    additionalServiceQuantities["Wall Washing"] = quantity
                }
                if let ovenCleaningQuantity = ovenCleaningTextField.text, let quantity = Int(ovenCleaningQuantity), quantity > 0 {
                    additionalRequests.append("Oven cleaning x \(quantity)")
                    additionalServiceQuantities["Oven Cleaning"] = quantity
                }
                if let rangehoodCleaningQuantity = rangehoodCleaningTextField.text, let quantity = Int(rangehoodCleaningQuantity), quantity > 0 {
                    additionalRequests.append("Rangehood cleaning x \(quantity)")
                    additionalServiceQuantities["Rangehood Cleaning"] = quantity
                }
                if let microwaveCleaningQuantity = microwaveCleaningTextField.text, let quantity = Int(microwaveCleaningQuantity), quantity > 0 {
                    additionalRequests.append("Microwave cleaning x \(quantity)")
                    additionalServiceQuantities["Microwave Cleaning"] = quantity
                }
                if let fridgeCleaningQuantity = fridgeCleaningTextField.text, let quantity = Int(fridgeCleaningQuantity), quantity > 0 {
                    additionalRequests.append("Fridge cleaning x \(quantity)")
                    additionalServiceQuantities["Fridge Cleaning"] = quantity
                }
                if let blindsCleaningQuantity = blindsCleaningTextField.text, let quantity = Int(blindsCleaningQuantity), quantity > 0 {
                    additionalRequests.append("Blinds cleaning x \(quantity)")
                    additionalServiceQuantities["Blinds Cleaning"] = quantity
                }
                if let garageCleaningQuantity = garageCleaningTextField.text, let quantity = Int(garageCleaningQuantity), quantity > 0 {
                    additionalRequests.append("Garage cleaning x \(quantity)")
                    additionalServiceQuantities["Garage Cleaning"] = quantity
                }
                if let carpetSteamQuantity = carpetSteamTextField.text, let quantity = Int(carpetSteamQuantity), quantity > 0 {
                    additionalRequests.append("Carpet steam cleaning x \(quantity)")
                    additionalServiceQuantities["Carpet Steam Cleaning"] = quantity
                }
                if let windowCleaningQuantity = windowCleaningTextField.text, let quantity = Int(windowCleaningQuantity), quantity > 0 {
                    additionalRequests.append("Window cleaning x \(quantity)")
                    additionalServiceQuantities["Window Cleaning"] = quantity
                }
                if let balconyCleaningQuantity = balconyCleaningTextField.text, let quantity = Int(balconyCleaningQuantity), quantity > 0 {
                    additionalRequests.append("Balcony cleaning x \(quantity)")
                    additionalServiceQuantities["Balcony Cleaning"] = quantity
                }
                if let singleCarpetQuantity = singleCarpetTextField.text, let quantity = Int(singleCarpetQuantity), quantity > 0 {
                    additionalRequests.append("Single carpet cleaning x \(quantity)")
                    additionalServiceQuantities["Single Carpet Cleaning"] = quantity
                }
                if let tileAndGroutQuantity = tileAndGroutTextField.text, let quantity = Int(tileAndGroutQuantity), quantity > 0 {
                    additionalRequests.append("Tile and grout cleaning x \(quantity)")
                    additionalServiceQuantities["Tile and Grout Cleaning"] = quantity
                }

                // Check if there are no additional requests
                if additionalRequests.isEmpty {
                    additionalRequests.append("No additional services")
                }

                // Pass the additional requests and quantities
                confirmVC.additionalRequests = additionalRequests
                confirmVC.additionalServiceQuantities = additionalServiceQuantities
            }
        }
    }
    
    // Add a new method to clear all the text fields
    func clearFields() {
        roomTypeTextField.text = ""
        serviceTypeTextField.text = ""
        wallWashingTextField.text = ""
        ovenCleaningTextField.text = ""
        rangehoodCleaningTextField.text = ""
        microwaveCleaningTextField.text = ""
        fridgeCleaningTextField.text = ""
        blindsCleaningTextField.text = ""
        garageCleaningTextField.text = ""
        carpetSteamTextField.text = ""
        windowCleaningTextField.text = ""
        balconyCleaningTextField.text = ""
        singleCarpetTextField.text = ""
        tileAndGroutTextField.text = ""
        addressLine1TextField.text = ""
        addressLine2TextField.text = ""
        suburbTextField.text = ""
        stateTextField.text = ""
        postcodeTextField.text = ""
        startTimeTextField.text = ""
        endTimeTextField.text = ""

        // Reset selected room and service type
        selectedRoomType = nil
        selectedServiceType = nil
        roomTypeTextField.placeholder = "Select room type"
        serviceTypeTextField.placeholder = "Select service type"

        // Reset the uploaded images
        selectedImages.removeAll()
        
        // Reset start and end time pickers and disable end time text field
        startTimePicker.date = Date()
        endTimePicker.date = Date()
        endTimeTextField.isEnabled = false

        // Reset customer comments TextView
        customerCommentsTextView.text = "Leave your comments here (optional)"
        customerCommentsTextView.textColor = UIColor.lightGray
    }

    // Validation Methods
    func validateFields() -> Bool {
        // Check if room type is selected
        guard selectedRoomType != nil else {
            showAlert("Room Type", "Please select a room type.")
            return false
        }
        
        // Check if service type is selected
        guard selectedServiceType != nil else {
            showAlert("Service Type", "Please select a service type.")
            return false
        }
        
        // Check if required address fields are filled (except Address Line 2)
        if addressLine1TextField.text?.isEmpty ?? true ||
           suburbTextField.text?.isEmpty ?? true ||
           stateTextField.text?.isEmpty ?? true ||
           postcodeTextField.text?.isEmpty ?? true {
            showAlert("Incomplete Address", "Please fill in all required fields marked with *.")
            return false
        }

        // Ensure suburb contains only letters and spaces
        if containsInvalidCharacters(suburbTextField.text ?? "") {
            showAlert("Invalid Suburb", "Please enter a correct suburb (letters and spaces only).")
            return false
        }

        // Check if postcode is exactly 4 digits
        if let postcode = postcodeTextField.text, postcode.count != 4 || !postcode.allSatisfy({ $0.isNumber }) {
            showAlert("Invalid Postcode", "Postcode must be 4 digits.")
            return false
        }

        // Check if start time is selected
        if startTimeTextField.text?.isEmpty ?? true {
            showAlert("Start Time", "Please select a start time.")
            return false
        }
        
        // If end time is empty, set it to be 1 hour after the start time by default
        if endTimeTextField.text?.isEmpty ?? true {
            endTimePicker.date = startTimePicker.date.addingTimeInterval(3600)
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            endTimeTextField.text = formatter.string(from: endTimePicker.date)
        }

        // Ensure the end time is at least 1 hour after the start time
        let selectedStartTime = startTimePicker.date
        let selectedEndTime = endTimePicker.date
        
        if selectedEndTime < selectedStartTime.addingTimeInterval(3600) {
            showAlert("Invalid End Time", "End time must be at least 1 hour after start time.")
            return false
        }

        return true
    }
    
    // Helper function to check if a string contains invalid characters
    func containsInvalidCharacters(_ string: String) -> Bool {
        // Allow letters and spaces only
        let validCharacterSet = CharacterSet.letters.union(CharacterSet.whitespaces)
        return string.rangeOfCharacter(from: validCharacterSet.inverted) != nil
    }

    // Helper function to show an alert with a specific message
    func showAlert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // Set up Start and End Time pickers
    func setupTimePickers() {
        // Start Time Picker
        startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimeTextField.inputView = startTimePicker
        
        let startTimeToolbar = UIToolbar()
        startTimeToolbar.sizeToFit()
        let doneStartTimeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneStartTimePicker))
        startTimeToolbar.setItems([doneStartTimeButton], animated: true)
        startTimeTextField.inputAccessoryView = startTimeToolbar

        // End Time Picker
        endTimePicker = UIDatePicker()
        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimeTextField.inputView = endTimePicker
        endTimeTextField.isEnabled = false // Disable end time initially

        let endTimeToolbar = UIToolbar()
        endTimeToolbar.sizeToFit()
        let doneEndTimeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEndTimePicker))
        endTimeToolbar.setItems([doneEndTimeButton], animated: true)
        endTimeTextField.inputAccessoryView = endTimeToolbar
    }
    
    @objc func doneStartTimePicker() {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        startTimeTextField.text = formatter.string(from: startTimePicker.date)
        startTimeTextField.resignFirstResponder()

        // Enable end time and adjust its minimum time to be at least 1 hour after the start time
        endTimeTextField.isEnabled = true
        endTimePicker.minimumDate = startTimePicker.date.addingTimeInterval(3600)
    }
    
    @objc func doneEndTimePicker() {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        endTimeTextField.text = formatter.string(from: endTimePicker.date)
        endTimeTextField.resignFirstResponder()
    }

    // Room Type Picker Setup
    func setupRoomTypePicker() {
        roomTypePicker = UIPickerView()
        roomTypePicker.delegate = self
        roomTypePicker.dataSource = self
        roomTypeTextField.inputView = roomTypePicker

        let roomToolbar = UIToolbar()
        roomToolbar.sizeToFit()
        let doneRoomButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneRoomPicker))
        roomToolbar.setItems([doneRoomButton], animated: true)
        roomTypeTextField.inputAccessoryView = roomToolbar
    }

    // Service Type Picker Setup
    func setupServiceTypePicker() {
        serviceTypePicker = UIPickerView()
        serviceTypePicker.delegate = self
        serviceTypePicker.dataSource = self
        serviceTypeTextField.inputView = serviceTypePicker

        let serviceToolbar = UIToolbar()
        serviceToolbar.sizeToFit()
        let doneServiceButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneServicePicker))
        serviceToolbar.setItems([doneServiceButton], animated: true)
        serviceTypeTextField.inputAccessoryView = serviceToolbar
    }

    // State Picker Setup
    func setupStatePicker() {
        statePicker = UIPickerView()
        statePicker.delegate = self
        statePicker.dataSource = self
        stateTextField.inputView = statePicker

        let stateToolbar = UIToolbar()
        stateToolbar.sizeToFit()
        let doneStateButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneStatePicker))
        stateToolbar.setItems([doneStateButton], animated: true)
        stateTextField.inputAccessoryView = stateToolbar
    }

    // Done Button Actions for Pickers
    @objc func doneRoomPicker() {
        roomTypeTextField.resignFirstResponder()
    }
    
    @objc func doneServicePicker() {
        serviceTypeTextField.resignFirstResponder()
    }
    
    @objc func doneStatePicker() {
        stateTextField.resignFirstResponder()
    }
    
    // UIPickerView Delegate & Data Source Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == roomTypePicker {
            return roomTypes.count
        } else if pickerView == serviceTypePicker {
            return serviceTypes.count
        } else {
            return australianStates.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == roomTypePicker {
            return roomTypes[row].rawValue
        } else if pickerView == serviceTypePicker {
            return serviceTypes[row].rawValue
        } else {
            return australianStates[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == roomTypePicker {
            roomTypeTextField.text = roomTypes[row].rawValue
            selectedRoomType = roomTypes[row]
        } else if pickerView == serviceTypePicker {
            serviceTypeTextField.text = serviceTypes[row].rawValue
            selectedServiceType = serviceTypes[row]
        } else {
            stateTextField.text = australianStates[row]
            selectedState = australianStates[row]
        }
    }
    
    // Customization Methods
    func customizeTextField() {
        roomTypeTextField.layer.borderColor = UIColor.black.cgColor
        roomTypeTextField.layer.borderWidth = 1.5
        roomTypeTextField.layer.cornerRadius = 8.0
        roomTypeTextField.layer.masksToBounds = true
        roomTypeTextField.placeholder = "Select room type"

        serviceTypeTextField.layer.borderColor = UIColor.black.cgColor
        serviceTypeTextField.layer.borderWidth = 1.5
        serviceTypeTextField.layer.cornerRadius = 8.0
        serviceTypeTextField.layer.masksToBounds = true
        serviceTypeTextField.placeholder = "Select service type"
        
        stateTextField.layer.borderColor = UIColor.black.cgColor
        stateTextField.layer.borderWidth = 1.5
        stateTextField.layer.cornerRadius = 8.0
        stateTextField.layer.masksToBounds = true
        stateTextField.placeholder = "Select state"
    }

    func setupTextFieldBorders() {
        let textFields = [
            wallWashingTextField, ovenCleaningTextField, rangehoodCleaningTextField,
            microwaveCleaningTextField, fridgeCleaningTextField, blindsCleaningTextField,
            garageCleaningTextField, carpetSteamTextField, windowCleaningTextField,
            balconyCleaningTextField, singleCarpetTextField, tileAndGroutTextField,
            addressLine1TextField, addressLine2TextField, suburbTextField, postcodeTextField
        ]

        for textField in textFields {
            textField?.layer.borderColor = UIColor.black.cgColor
            textField?.layer.borderWidth = 1.5
            textField?.layer.cornerRadius = 8.0
            textField?.layer.masksToBounds = true
        }
    }

    // Function to format and return the full address
    func getFullAddress() -> String {
        var address = ""
        address += (addressLine1TextField.text ?? "")
        address += (addressLine2TextField.text?.isEmpty ?? true ? "" : ", \(addressLine2TextField.text ?? "")")
        address += ", \(suburbTextField.text ?? ""), \(stateTextField.text ?? ""), \(postcodeTextField.text ?? "")"
        return address
    }
}
