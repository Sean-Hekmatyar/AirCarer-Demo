//
//  RequestFeedbackViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/10/14.
//

import UIKit

class RequestFeedbackViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusMessageLabel: UILabel!
    
    var cleaningService: CleaningService? // To hold the passed data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the data into the labels
        loadStatusLabel()
        loadStatusMessage()
    }

    // Function to set the status label with color
    func loadStatusLabel() {
        guard let service = cleaningService else {
            return
        }
        
        // Set the status label's text and color based on the service status
        statusLabel.text = service.taskStatus.rawValue
        
        switch service.taskStatus {
        case .inQueue:
            statusLabel.textColor = UIColor.systemGreen
        case .inProgress:
            statusLabel.textColor = UIColor.systemYellow
        case .completed:
            statusLabel.textColor = UIColor.systemRed
        }
    }

    // Function to load the status message
    func loadStatusMessage() {
        guard let service = cleaningService else {
            return
        }
        
        let roomTypeText = service.roomType.rawValue
        let attributedMessage: NSMutableAttributedString
        
        // Customize the message based on the status
        switch service.taskStatus {
        case .inQueue:
            let message = "Your cleaning request for \(roomTypeText) is currently in queue. Please wait for a cleaner to accept your request."
            attributedMessage = NSMutableAttributedString(string: message)
            let statusRange = (message as NSString).range(of: "in queue")
            attributedMessage.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: statusRange)
            
        case .inProgress:
            let message = "A cleaner is in progress of your request for \(roomTypeText). Please wait for the cleaner’s response."
            attributedMessage = NSMutableAttributedString(string: message)
            let statusRange = (message as NSString).range(of: "in progress")
            attributedMessage.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: statusRange)
            
        case .completed:
            let message = "Your cleaning request for \(roomTypeText) has been completed. Thank you for using our service!"
            attributedMessage = NSMutableAttributedString(string: message)
            let statusRange = (message as NSString).range(of: "completed")
            attributedMessage.addAttribute(.foregroundColor, value: UIColor.systemRed, range: statusRange)
        }
        
        // Set the attributed text to the statusMessageLabel
        statusMessageLabel.attributedText = attributedMessage
    }
    
    // Go back to Booking History VC
    @IBAction func goBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
