//
//  CustomerHomepageViewController.swift
//  AirCarer
//
//  Created by Cian on 2024/9/19.
//

import UIKit

class CustomerHomepageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var serviceTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var pageLabel: UILabel!
    
    var filteredServices: [CleaningService] = []
    let pageSize = 3       // Number of services per page
    var currentPage = 0    // Current page index

    override func viewDidLoad() {
        super.viewDidLoad()

        serviceTableView.delegate = self
        serviceTableView.dataSource = self

        serviceTableView.rowHeight = UITableView.automaticDimension
        serviceTableView.estimatedRowHeight = 150

        // Filter services with "In Queue" status initially
        filteredServices = CleaningServiceManager.shared.getServicesFilteredByStatus(statuses: [.inQueue])
        updatePageLabel()
        serviceTableView.reloadData()

        customizeSearchTextField()
        
        if let items = tabBarController?.tabBar.items {
            // Iterate through each tab bar item
            for item in items {
                // Set the font size and color for unselected state
                let unselectedAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
                item.setTitleTextAttributes(unselectedAttributes, for: .normal)

                // Set the font size and color for selected state
                let selectedAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
                item.setTitleTextAttributes(selectedAttributes, for: .selected)
            }
        }

        // Optional: Adjust the tab bar's tint color (affects icon and text of selected tab)
        tabBarController?.tabBar.tintColor = UIColor.black

        // Optional: Adjust the tab bar's unselected item tint color
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.gray
    }

    // Helper function to customize the search text field
    func customizeSearchTextField() {
        searchTextField.layer.borderColor = UIColor.white.cgColor
        searchTextField.layer.borderWidth = 1.5
        searchTextField.layer.cornerRadius = 8

        let placeholderText = "How can I help you?"
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
    }

    // Helper function to get services for the current page
    func getServicesForCurrentPage() -> [CleaningService] {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, filteredServices.count)

        guard startIndex < endIndex else {
            return []
        }

        return Array(filteredServices[startIndex..<endIndex])
    }

    // MARK: - UITableViewDataSource
    func tableView(_ serviceTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getServicesForCurrentPage().count
    }

    func tableView(_ serviceTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = serviceTableView.dequeueReusableCell(withIdentifier: "CleaningServiceCell", for: indexPath) as! CleaningServiceTableViewCell
        let service = getServicesForCurrentPage()[indexPath.row]

        let details = """
        \(service.roomType.rawValue)
        Standard: $\(service.standardCleaningPrice), Steam: $\(service.steamCleaningPrice), Both: $\(service.standardPlusSteamPrice)
        Additional Services: \(service.additionalServices.map { "\($0.serviceName): \($0.priceRange)" }.joined(separator: ", "))
        """
        //cell.serviceTitleLabel.text = service.title
        cell.serviceDetailsLabel.text = details
        cell.serviceAddressLabel.text = "\(service.address), \(service.postcode)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTaskDetails", sender: self)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // Adjust this as per your design
    }

    // Update the page label (e.g., "1/3")
    func updatePageLabel() {
        let totalPages = (filteredServices.count + pageSize - 1) / pageSize
        pageLabel.text = "\(currentPage + 1)/\(totalPages)"
    }
    
    // Search Function
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let searchText = searchTextField.text?.lowercased(), !searchText.isEmpty else {
            filteredServices = CleaningServiceManager.shared.cleaningServices // Fetch all services from manager
            currentPage = 0
            updatePageLabel()
            serviceTableView.reloadData()
            return
        }

        // Check if the input is a number or text
        if let searchNumber = Int(searchText) {
            // Handle numeric search for bedrooms, bathrooms, and exact postcode match
            filteredServices = CleaningServiceManager.shared.cleaningServices.filter { service in
                return service.roomType.rawValue.contains("\(searchNumber) Bedrooms") ||
                       service.roomType.rawValue.contains("\(searchNumber) Bathrooms") ||
                       service.postcode == searchText || // Exact match for postcode
                       service.address.contains("\(searchNumber)") // Search in address for numeric match
            }
        } else {
            // Handle text search (search in title, room type, address, and additional services)
            filteredServices = CleaningServiceManager.shared.cleaningServices.filter { service in
                let addressComponents = service.address.lowercased().components(separatedBy: " ")
                let addressMatch = addressComponents.contains { $0.contains(searchText) } // Search in each component of address
                
                return //service.title.lowercased().contains(searchText) ||
                       service.roomType.rawValue.lowercased().contains(searchText) ||
                       addressMatch || // Search in address components
                       service.additionalServices.contains { $0.serviceName.lowercased().contains(searchText) }
            }
        }

        currentPage = 0
        updatePageLabel()
        serviceTableView.reloadData()
    }

    // Pagination Buttons
    @IBAction func previousPageTapped(_ sender: UIButton) {
        if currentPage > 0 {
            currentPage -= 1
            serviceTableView.reloadData()
            updatePageLabel()
        }
    }
    
    @IBAction func nextPageTapped(_ sender: UIButton) {
        let maxPage = (filteredServices.count - 1) / pageSize
        if currentPage < maxPage {
            currentPage += 1
            serviceTableView.reloadData()
            updatePageLabel()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTaskDetails" {
            if let indexPath = serviceTableView.indexPathForSelectedRow {
                let service = getServicesForCurrentPage()[indexPath.row]
                let taskDetailsVC = segue.destination as! TaskDetailsViewController
                taskDetailsVC.selectedService = service
            }
        }
    }
}
