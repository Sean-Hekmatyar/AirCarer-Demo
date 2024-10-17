//
//  BookingHistoryViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/10/8.
//

import UIKit

class BookingHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paginationLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var bookingHistory: [CleaningService] = [] // This will hold the full list of user's booking history
    var paginatedHistory: [CleaningService] = [] // This will hold the current page's requests

    var currentPage = 1 // Current page
    let itemsPerPage = 3 // Number of items to display per page
    var totalPages: Int {
        return max(1, Int(ceil(Double(bookingHistory.count) / Double(itemsPerPage))))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Load the booking history from the CleaningServiceManager
        loadBookingHistory()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure the view is fully loaded before updating the table view and controls
        print("View did appear: Re-loading data...")
        loadBookingHistory()
        updatePaginatedHistory()
        updatePaginationControls()
    }

    // Load booking history from the CleaningServiceManager
    func loadBookingHistory() {
        bookingHistory = CleaningServiceManager.shared.cleaningServices
        print("Loaded \(bookingHistory.count) booking(s) from shared manager.")
        updatePaginatedHistory()
        updatePaginationControls()
    }

    // Method to update paginated history for the current page
    func updatePaginatedHistory() {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, bookingHistory.count)
        paginatedHistory = Array(bookingHistory[startIndex..<endIndex])
        
        print("Paginated history updated for page \(currentPage). Showing \(paginatedHistory.count) bookings.")
        
        // Refresh the table view
        tableView.reloadData()
    }

    // Update pagination label and button states
    func updatePaginationControls() {
        paginationLabel.text = "\(currentPage)/\(totalPages)"
        previousButton.isEnabled = currentPage > 1
        nextButton.isEnabled = currentPage < totalPages
    }
    
    // Pagination Button Actions
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        if currentPage > 1 {
            currentPage -= 1
            updatePaginatedHistory()
            updatePaginationControls()
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if currentPage < totalPages {
            currentPage += 1
            updatePaginatedHistory()
            updatePaginationControls()
        }
    }

    // Method to add a new booking request to the history
    func addBookingRequest(request: CleaningService) {
        print("Adding new booking request: \(request.address)")
        bookingHistory.append(request)
        
        // Also update the shared manager to ensure it's globally available
        CleaningServiceManager.shared.cleaningServices.append(request)
        
        // After adding the request, reload the booking history and refresh the pagination
        loadBookingHistory()
    }

    // MARK: - UITableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paginatedHistory.count  // Display only the current page's requests
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingHistoryCell", for: indexPath) as! BookingHistoryTableViewCell
        let service = paginatedHistory[indexPath.row]
        cell.configure(with: service)  // Pass the service to configure the cell
        return cell
    }

    // MARK: - UITableView Delegate Method
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120  // Adjust the cell height as needed
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedService = paginatedHistory[indexPath.row]
        performSegue(withIdentifier: "goToFeedback", sender: selectedService) // Perform the segue with selected service
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFeedback" {
            if let feedbackVC = segue.destination as? RequestFeedbackViewController {
                feedbackVC.cleaningService = sender as? CleaningService // Pass the selected service to the RequestFeedbackViewController
            }
        }
    }
}
