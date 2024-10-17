//
//  OrderInfoTableViewCell.swift
//  AirCarer
//
//  Created by Cian on 2024/10/1.
//

import UIKit

class OrderInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var taskTimeLabel: UILabel!
    @IBOutlet weak var taskStatusLabel: UILabel!

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

        serviceNameLabel.textColor = UIColor.black
        taskTimeLabel.textColor = UIColor.gray
    }
    
    // Configure the cell with data and handle task status color
    func configureCell(with service: CleaningService) {
        //serviceNameLabel.text = service.title
        taskTimeLabel.text = "\(service.taskDate) | \(service.taskStartTime) - \(service.taskEndTime)"
        taskStatusLabel.text = service.taskStatus.rawValue
        
        // Set color for task status
        switch service.taskStatus {
        case .inProgress:
            taskStatusLabel.textColor = UIColor.green
        case .completed:
            taskStatusLabel.textColor = UIColor.red
        default:
            taskStatusLabel.textColor = UIColor.gray
        }
    }
}
