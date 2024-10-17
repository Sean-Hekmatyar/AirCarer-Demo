//
//  ConfirmRequestViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/10/7.
//

import UIKit

class ConfirmRequestViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // Labels to display the passed data
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var serviceTypeLabel: UILabel!
    @IBOutlet weak var timeRangeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var additionalRequestsTextView: UITextView!
    @IBOutlet weak var customerCommentsTextView: UITextView!
    @IBOutlet weak var finalPriceLabel: UILabel!
    
    var uploadedImages: [UIImage] = [] // To hold the passed images
    var roomType: String?               // To hold the room type passed
    var serviceType: String?            // To hold the service type passed
    var timeRange: String?              // To hold the time range passed
    var address: String?                // To hold the address passed
    var additionalRequests: [String] = [] // To hold the additional requests passed
    var additionalServiceQuantities: [String: Int] = [:] // For quantity of additional services
    var customerComments: String? // To hold the customer comments passed

    // Placeholder image when no photos are uploaded
    let placeholderImage = UIImage(named: "no_photos_uploaded") // Ensure this is added in your assets

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up collection view
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self

        // Enable horizontal scrolling in the collection view layout
        if let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }

        // Set up page control
        pageControl.numberOfPages = uploadedImages.isEmpty ? 1 : uploadedImages.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = true

        // Display the passed values in the labels
        roomTypeLabel.text = roomType
        serviceTypeLabel.text = serviceType
        timeRangeLabel.text = timeRange
        addressLabel.text = address

        // Display the additional requests in the UITextView
        if additionalRequests.isEmpty {
            additionalRequestsTextView.text = "No additional services"
        } else {
            additionalRequestsTextView.text = additionalRequests.joined(separator: "\n")
        }

        // **Set the customer comments**
        customerCommentsTextView.text = customerComments ?? "No comments"

        // Dynamically adjust the height of the text view based on content
        adjustTextViewHeight(additionalRequestsTextView)
        adjustTextViewHeight(customerCommentsTextView)

        // Calculate and display the final price
        calculateAndDisplayFinalPrice()
    }

    // Dynamically adjust the UITextView height based on its content
    func adjustTextViewHeight(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        // Update the height constraint of the text view
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.heightAnchor.constraint(equalToConstant: estimatedSize.height).isActive = true
    }

    // Calculate and display the final price based on room type, service type, and additional services
    func calculateAndDisplayFinalPrice() {
        guard let roomType = roomType, let serviceType = serviceType else {
            finalPriceLabel.text = "Unable to calculate price"
            return
        }

        // Extract start and end times from timeRange
        let timeComponents = timeRange?.components(separatedBy: " ~ ")
        let taskStartTime = timeComponents?.first ?? ""
        let taskEndTime = timeComponents?.last ?? ""

        // Calculate the final price using the CleaningServiceManager
        let finalPrice = CleaningServiceManager.shared.handleCustomerRequest(
            roomType: RoomType(rawValue: roomType)!,
            serviceType: ServiceType(rawValue: serviceType)!,
            additionalServiceQuantities: additionalServiceQuantities,
            address: address ?? "",
            postcode: "",
            taskStartTime: taskStartTime,
            taskEndTime: taskEndTime,
            customerComments: nil
        )

        // Display the final price in the correct format
        finalPriceLabel.text = String(format: "$%.2f in total", finalPrice)
    }
    
    // Cancel Button Action
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        // Clear all fields in the CustomerRequestViewController and dismiss
        if let customerRequestVC = presentingViewController as? CustomerRequestViewController {
            customerRequestVC.clearFields()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // Confirm Button Action
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        // Show a confirmation alert
        let alertController = UIAlertController(
            title: "Confirm Request",
            message: "Are you sure you want to post this request? You cannot change the service contents once the request is posted.",
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Pass data to the Booking History and dismiss back to Customer Request
            self?.postRequestAndDismiss()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    // Pass data to Booking History and dismiss Confirm Request VC
    func postRequestAndDismiss() {
        // Create the confirmed CleaningService object
        let confirmedService = createConfirmedService()

        // Find the BookingHistoryViewController and add the new booking
        if let tabBarController = self.presentingViewController as? UITabBarController,
           let bookingHistoryVC = (tabBarController.viewControllers?[1] as? UINavigationController)?.viewControllers.first as? BookingHistoryViewController {
            // Pass the confirmed request to Booking History
            bookingHistoryVC.addBookingRequest(request: confirmedService)
        }

        // Also find the CustomerRequestViewController and call clearFields()
        if let customerRequestVC = (self.presentingViewController as? UITabBarController)?.viewControllers?.first as? CustomerRequestViewController {
            customerRequestVC.clearFields()
        }

        // Dismiss back to the Customer Request View Controller
        self.dismiss(animated: true, completion: nil)
    }

    // Function to create a confirmed CleaningService object
    func createConfirmedService() -> CleaningService {
        let timeComponents = timeRange?.components(separatedBy: " ~ ")
        let taskStartTime = timeComponents?.first ?? ""
        let taskEndTime = timeComponents?.last ?? ""

        return CleaningService(
            roomType: RoomType(rawValue: roomType ?? "")!,
            serviceType: ServiceType(rawValue: serviceType ?? "")!,
            standardCleaningPrice: 0.0, // This can be calculated if needed
            steamCleaningPrice: 0.0,
            standardPlusSteamPrice: 0.0,
            additionalServices: [],  // You can pass selected additional services
            address: address ?? "",
            postcode: "",  // Can be added if needed
            feedbackComments: nil,
            customerComments: customerComments ?? "No comments",  // Pass the customer comments
            taskStartTime: taskStartTime,
            taskEndTime: taskEndTime,
            taskDate: getCurrentDate(),
            taskStatus: .inQueue,  // Default as in queue
            roomPhotos: uploadedImages,
            rating: 0,
            feedbackText: nil
        )
    }

    // Helper function to get the current date
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: Date())
    }

    // MARK: - UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return 1 if no images uploaded to show placeholder image
        return uploadedImages.isEmpty ? 1 : uploadedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell

        if uploadedImages.isEmpty {
            // Display placeholder image if no photos were uploaded
            cell.imageView.image = placeholderImage
        } else {
            // Display uploaded images
            let image = uploadedImages[indexPath.row]
            cell.imageView.image = image
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Ensure each cell is as wide as the collection view
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    // ScrollView delegate to update page control when swiping
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = photosCollectionView.frame.width
        let currentPage = Int(photosCollectionView.contentOffset.x / pageWidth)
        pageControl.currentPage = currentPage
    }
    
    // Page Control Value Changed Method
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let indexPath = IndexPath(item: currentPage, section: 0)

        // Scroll to the selected page
        photosCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // Go back to Customer Request
    @IBAction func goBackTapped(_ sender: UIButton) {
        // Dismiss the current view controller
        self.dismiss(animated: true, completion: nil)
    }
}
