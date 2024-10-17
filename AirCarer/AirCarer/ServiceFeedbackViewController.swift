//
//  ServiceFeedbackViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/10/1.
//

import UIKit

class ServiceFeedbackViewController: UIViewController {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceStatusLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var feedbackTextView: UITextView!
    
    // Property to store the selected service passed from OrderInformationVC
    var service: CleaningService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the labels and feedback based on the passed service
        if let service = service {
            //serviceNameLabel.text = service.title
            serviceStatusLabel.text = service.taskStatus.rawValue
            
            // Color based on status
            switch service.taskStatus {
            case .inProgress:
                serviceStatusLabel.textColor = .green
                ratingLabel.text = "0/5" // No rating yet
                feedbackTextView.text = "No Feedback. You need to complete the task first."
                feedbackTextView.textColor = .gray
            case .completed:
                serviceStatusLabel.textColor = .red
                ratingLabel.text = "\(service.rating)/5" // Show the given rating
                feedbackTextView.text = service.feedbackText ?? "No feedback available."
            default:
                serviceStatusLabel.textColor = .gray
            }
        }
    }
    
    @IBAction func goBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
