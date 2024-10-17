//
//  OrderInformationViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/10/1.
//

import UIKit

class OrderInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var pageLabel: UILabel!
    
    var orders: [CleaningService] = []
    var filteredOrders: [CleaningService] = [] // To hold the orders for the current page
    
    let pageSize = 3  // Number of orders per page
    var currentPage = 0  // Current page index

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the table view's delegate and data source
        orderTableView.delegate = self
        orderTableView.dataSource = self

        // Load the order data from CleaningServiceManager
        loadOrders()
        
        // Initially show the first page of orders
        filteredOrders = getOrdersForCurrentPage()
        updatePageLabel()
        orderTableView.reloadData()
    }
    
    // Ensure the latest data is fetched every time the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load the latest orders
        loadOrders()
        
        // Refresh the current page and update the table view
        filteredOrders = getOrdersForCurrentPage()
        updatePageLabel()
        orderTableView.reloadData()
    }
    
    // Load orders that are either "In Progress" or "Completed"
    func loadOrders() {
        orders = CleaningServiceManager.shared.getServicesFilteredByStatus(statuses: [.inProgress, .completed])
    }
    
    // Helper function to get orders for the current page
    func getOrdersForCurrentPage() -> [CleaningService] {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, orders.count)

        guard startIndex < endIndex else {
            return []
        }

        return Array(orders[startIndex..<endIndex])
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderInfoCell", for: indexPath) as! OrderInfoTableViewCell
        let order = filteredOrders[indexPath.row]

        // Configure the cell using the new configureCell method
        cell.configureCell(with: order)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // Adjust this as per your design
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedService = filteredOrders[indexPath.row]
        performSegue(withIdentifier: "showServiceFeedback", sender: selectedService)
    }
    
    // Pagination Buttons
    @IBAction func previousPageTapped(_ sender: UIButton) {
        if currentPage > 0 {
            currentPage -= 1
            filteredOrders = getOrdersForCurrentPage()
            orderTableView.reloadData()
            updatePageLabel()
        }
    }
    
    @IBAction func nextPageTapped(_ sender: UIButton) {
        let maxPage = (orders.count - 1) / pageSize
        if currentPage < maxPage {
            currentPage += 1
            filteredOrders = getOrdersForCurrentPage()
            orderTableView.reloadData()
            updatePageLabel()
        }
    }
    
    // Update the page label (e.g., "1/3")
    func updatePageLabel() {
        let totalPages = (orders.count + pageSize - 1) / pageSize
        pageLabel.text = "\(currentPage + 1)/\(totalPages)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showServiceFeedback" {
            if let feedbackVC = segue.destination as? ServiceFeedbackViewController,
               let selectedOrder = sender as? CleaningService {
                feedbackVC.service = selectedOrder
            }
        }
    }
}
