//
//  TaskDetailsViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/9/29.
//

import UIKit

class TaskDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var serviceTitleLabel: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // confirm order view
    @IBOutlet weak var confirmOrderView: UIView!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var commentsTextView: UITextView!
    
    
    // Filled Buttons
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var confirmOrderButton: UIButton!
    
    // Variable to hold the selected service
    var selectedService: CleaningService?  // Add this property
    
    var isOrderAccepted = false // Track if the order has already been accepted
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate and data source for collection view
        collectionView.delegate = self
        collectionView.dataSource = self

        // Setup collection view flow layout for horizontal scrolling
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        collectionView.collectionViewLayout = layout

        // Setup Page Control
        pageControl.numberOfPages = selectedService?.roomPhotos.count ?? 0
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true

        // Populate labels with service details
        if let service = selectedService {
            //serviceTitleLabel.text = service.title
            roomTypeLabel.text = service.roomType.rawValue
            priceLabel.text = """
            Standard Cleaning: $\(service.standardCleaningPrice)
            Steam Cleaning: $\(service.steamCleaningPrice)
            Standard + Steam: $\(service.standardPlusSteamPrice)
            """
            addressLabel.text = "\(service.address), \(service.postcode)"
            
            // Set the comments in the commentsTextView
            if let comments = service.feedbackComments, !comments.isEmpty {
                commentsTextView.text = comments
            } else {
                commentsTextView.text = "No comments"
            }
        }

        // Initially hide the confirm order view
        confirmOrderView.isHidden = true
        
        // Round the corners of the buttons
        roundButtonCorners()
    }
    
    // Helper function to round button corners
    func roundButtonCorners() {
        let cornerRadius: CGFloat = 10.0 // Adjust this value for more or less rounding

        // Set corner radius for the buttons
        cancelButton.layer.cornerRadius = cornerRadius
        acceptButton.layer.cornerRadius = cornerRadius
        cancelOrderButton.layer.cornerRadius = cornerRadius
        confirmOrderButton.layer.cornerRadius = cornerRadius
    }
    
    // Collection View Data Source Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedService?.roomPhotos.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomPhotoCell", for: indexPath) as! ImageCollectionViewCell
        if let roomPhoto = selectedService?.roomPhotos[indexPath.row] {
            cell.roomPhotosView.image = roomPhoto
        }
        return cell
    }
    
    // Update page control when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    @IBAction func goBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        if isOrderAccepted {
            // Show alert that the order has already been accepted
            let alert = UIAlertController(title: "Already Accepted", message: "You have already accepted this request.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            // Set the final price label to match the price label
            if let service = selectedService {
                finalPriceLabel.text = """
                Standard Cleaning: $\(service.standardCleaningPrice)
                Steam Cleaning: $\(service.steamCleaningPrice)
                Standard + Steam: $\(service.standardPlusSteamPrice)
                """
            }
            
            // Pop up the confirm order view with animation
            UIView.animate(withDuration: 0.3) {
                self.confirmOrderView.isHidden = false
                self.confirmOrderView.alpha = 1
                self.confirmOrderView.transform = CGAffineTransform.identity
            }
        }
    }
    
    @IBAction func cancelOrderTapped(_ sender: UIButton) {
        // Animate fade-out and shrink
        UIView.animate(withDuration: 0.3, animations: {
            self.confirmOrderView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Shrink view
            self.confirmOrderView.alpha = 0 // Fade out
        }, completion: { _ in
            self.confirmOrderView.isHidden = true // Hide the view after animation completes
        })
    }
    
    @IBAction func confirmOrderTapped(_ sender: UIButton) {
        // Close the confirm order view with animation
        UIView.animate(withDuration: 0.3, animations: {
            self.confirmOrderView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Shrink view
            self.confirmOrderView.alpha = 0 // Fade out
        }, completion: { _ in
            self.confirmOrderView.isHidden = true
            self.isOrderAccepted = true

            // Update service status to "In Progress" in the shared data source
            if let service = self.selectedService {
                CleaningServiceManager.shared.updateServiceStatus(for: service, to: .inProgress)
            }

            // Show alert message after confirmation
            let alert = UIAlertController(title: "Order Accepted", message: "You have accepted this request.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        })
    }
}
