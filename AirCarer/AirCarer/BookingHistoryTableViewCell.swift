//
//  BookingHistoryTableViewCell.swift
//  AirCarer
//
//  Created by Cian on 2024/10/8.
//

import UIKit

class BookingHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeRangeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Customize cell background and appearance
        contentView.backgroundColor = UIColor.systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        // Customize cell border and shadow
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
        layer.masksToBounds = false
    }
    
    // Configure the cell with a CleaningService object
    func configure(with service: CleaningService) {
        // Set the address
        addressLabel.text = service.address
        
        // Set the time range
        timeRangeLabel.text = "\(service.taskStartTime) ~ \(service.taskEndTime)"
        
        // Set the status and update the color based on the task status
        statusLabel.text = service.taskStatus.rawValue
        switch service.taskStatus {
        case .inQueue:
            statusLabel.textColor = .green
        case .inProgress:
            statusLabel.textColor = .yellow
        case .completed:
            statusLabel.textColor = .red
        }
    }
}
