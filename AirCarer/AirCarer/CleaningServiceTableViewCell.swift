//
//  CleaningServiceTableViewCell.swift
//  AirCarer
//
//  Created by Cian on 2024/9/29.
//

import UIKit

class CleaningServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceTitleLabel: UILabel!
    @IBOutlet weak var serviceDetailsLabel: UILabel!
    @IBOutlet weak var serviceAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Customize cell background
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

        // Keep the color settings, remove font settings (set font family in storyboard)
        serviceTitleLabel.textColor = UIColor.black
        serviceDetailsLabel.textColor = UIColor.gray
        serviceAddressLabel.textColor = UIColor.darkGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
