//
//  CleaningServiceManager.swift
//  AirCarer
//
//  Created by Cian on 2024/10/1.
//

import UIKit

// Define a model for cleaning services
struct CleaningService {
    var roomType: RoomType
    var serviceType: ServiceType  // Field for service type
    var standardCleaningPrice: Double
    var steamCleaningPrice: Double
    var standardPlusSteamPrice: Double
    var additionalServices: [AdditionalService]
    var address: String
    var postcode: String
    var feedbackComments: String? // Comments for service feedback
    var customerComments: String? // Comments for customer request
    
    var taskStartTime: String  // Specific task start time
    var taskEndTime: String    // Specific task end time
    var taskDate: String       // Task date
    var taskStatus: TaskStatus // Task status (in-progress/completed)
    
    var roomPhotos: [UIImage]  // Array of images representing room photos
    
    var rating: Int            // Rating (0-5)
    var feedbackText: String?  // Feedback text
}

enum RoomType: String {
    case studio = "Studio"
    case oneBedOneBath = "1 Bedroom, 1 Bathroom"
    case twoBedOneBath = "2 Bedrooms, 1 Bathroom"
    case twoBedTwoBath = "2 Bedrooms, 2 Bathrooms"
    case threeBedOneBath = "3 Bedrooms, 1 Bathroom"
    case threeBedTwoBath = "3 Bedrooms, 2 Bathrooms"
    case fourBedTwoBath = "4 Bedrooms, 2 Bathrooms"
}

enum ServiceType: String {  // Enum for service types
    case nonSteam = "Non-Steam"
    case steam = "Steam"
    case includingSteam = "Including Steam"
}

enum TaskStatus: String {
    case inQueue = "In Queue"
    case inProgress = "In Progress"
    case completed = "Completed"
}

struct AdditionalService {
    var serviceName: String
    var priceRange: String  // Price ranges like "$30-$50"
    var quantity: Int = 0   // Quantity to store user input
}

// Shared Data Manager (Singleton)
class CleaningServiceManager {

    // Singleton instance
    static let shared = CleaningServiceManager()

    // Declare the cleaning services array
    var cleaningServices: [CleaningService] = []

    // Array of all available additional services (class-level property)
    let allAdditionalServices: [AdditionalService] = [
        AdditionalService(serviceName: "Wall Washing", priceRange: "$50 and up"),
        AdditionalService(serviceName: "Oven Cleaning", priceRange: "$30-$50"),
        AdditionalService(serviceName: "Rangehood Cleaning", priceRange: "$30-$50"),
        AdditionalService(serviceName: "Microwave Cleaning", priceRange: "$30"),
        AdditionalService(serviceName: "Fridge Cleaning", priceRange: "$30-$50"),
        AdditionalService(serviceName: "Blinds Cleaning", priceRange: "$15 per piece"),
        AdditionalService(serviceName: "Garage Cleaning", priceRange: "$260 and up"),
        AdditionalService(serviceName: "Carpet Steam Cleaning", priceRange: "$80-$150"),
        AdditionalService(serviceName: "Window Cleaning", priceRange: "$50"),
        AdditionalService(serviceName: "Balcony Cleaning", priceRange: "$50 and up"),
        AdditionalService(serviceName: "Single Carpet Cleaning", priceRange: "$60 and up"),
        AdditionalService(serviceName: "Tile and Grout Cleaning", priceRange: "$40 and up")
    ]

    private init() {
        // Initialize without loading test data (test objects disabled)
    }

    // Method to handle customer request and return final price
    func handleCustomerRequest(
        roomType: RoomType,
        serviceType: ServiceType,
        additionalServiceQuantities: [String: Int],
        address: String,
        postcode: String,
        taskStartTime: String,
        taskEndTime: String,
        customerComments: String? = nil // Now accepts customer comments
    ) -> Double {  // Return the final price
        // Filter the services that were selected by the user with non-zero quantities
        var selectedServices: [AdditionalService] = []

        for service in allAdditionalServices {
            if let quantity = additionalServiceQuantities[service.serviceName], quantity > 0 {
                var updatedService = service
                updatedService.quantity = quantity
                selectedServices.append(updatedService)
            }
        }

        // Calculate the final price
        let roomPrice = getRoomTypePrice(roomType: roomType, serviceType: serviceType)
        let additionalServicesPrice = calculateAdditionalServicesPrice(services: selectedServices)
        let finalPrice = roomPrice + additionalServicesPrice

        // Create a new cleaning service request
        let newService = CleaningService(
            roomType: roomType,
            serviceType: serviceType,
            standardCleaningPrice: roomPrice,
            steamCleaningPrice: 0.0,     // Not applicable for custom requests
            standardPlusSteamPrice: 0.0, // Not applicable for custom requests
            additionalServices: selectedServices,
            address: address,
            postcode: postcode,
            feedbackComments: nil, // No feedback comments yet
            customerComments: customerComments, // Pass customer comments here
            taskStartTime: taskStartTime, // Ensure start time is set
            taskEndTime: taskEndTime,     // Ensure end time is set
            taskDate: getCurrentDate(),   // Get the current date
            taskStatus: .inQueue,         // Initially, the task is in queue
            roomPhotos: [],               // You can add room photos later
            rating: 0,                    // No rating yet
            feedbackText: nil             // No feedback yet
        )

        // Add the new service to the cleaning services list
        cleaningServices.append(newService)

        return finalPrice
    }

    // Helper function to calculate room type price based on service type
    private func getRoomTypePrice(roomType: RoomType, serviceType: ServiceType) -> Double {
        switch roomType {
        case .studio:
            return getPriceForRoom(serviceType: serviceType, standardPrice: 140, steamPrice: 150, combinedPrice: 290)
        case .oneBedOneBath:
            return getPriceForRoom(serviceType: serviceType, standardPrice: 180, steamPrice: 190, combinedPrice: 330)
        case .twoBedOneBath:
            return getPriceForRoom(serviceType: serviceType, standardPrice: 220, steamPrice: 250, combinedPrice: 370)
        case .twoBedTwoBath:
            return getPriceForRoom(serviceType: serviceType, standardPrice: 250, steamPrice: 280, combinedPrice: 430)
        case .threeBedOneBath:
            return getPriceForRoom(serviceType: serviceType, standardPrice: 300, steamPrice: 350, combinedPrice: 500)
        case .threeBedTwoBath:
            return getPriceForRoom(serviceType: serviceType, standardPrice: 350, steamPrice: 450, combinedPrice: 550)
        case .fourBedTwoBath:
            return getPriceForRoom(serviceType: serviceType, standardPrice: 450, steamPrice: 550, combinedPrice: 710)
        }
    }

    // Helper function to get the price based on service type
    private func getPriceForRoom(serviceType: ServiceType, standardPrice: Double, steamPrice: Double, combinedPrice: Double) -> Double {
        switch serviceType {
        case .nonSteam:
            return standardPrice
        case .steam:
            return steamPrice
        case .includingSteam:
            return combinedPrice
        }
    }

    // Helper function to calculate the total price for selected additional services
    private func calculateAdditionalServicesPrice(services: [AdditionalService]) -> Double {
        var total: Double = 0.0

        for service in services {
            let price = calculatePriceForService(priceRange: service.priceRange)
            total += price * Double(service.quantity)
        }

        return total
    }

    // Helper function to calculate the price for an additional service based on its price range
    private func calculatePriceForService(priceRange: String) -> Double {
        if priceRange.contains("-") {
            let prices = priceRange.components(separatedBy: "-").compactMap { priceString -> Double? in
                let cleanedPrice = priceString.trimmingCharacters(in: CharacterSet(charactersIn: "$ "))
                return Double(cleanedPrice)
            }
            if prices.count == 2 {
                return (prices[0] + prices[1]) / 2.0 // Take the mid-price
            }
        } else if priceRange.contains("and up") {
            return 50.0 // Handle "and up" prices (e.g., "$50 and up")
        } else if let price = Double(priceRange.replacingOccurrences(of: "$", with: "")) {
            return price
        }

        return 0.0 // Fallback if no valid price is found
    }

    // Helper function to get the current date
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: Date())
    }

    // Update service status
    func updateServiceStatus(for service: CleaningService, to newStatus: TaskStatus) {
        if let index = cleaningServices.firstIndex(where: { $0.address == service.address && $0.taskStartTime == service.taskStartTime }) {
            cleaningServices[index].taskStatus = newStatus
        }
    }

    // Add new method to update feedback and rating
    func updateFeedback(for service: CleaningService, rating: Int, feedback: String?, feedbackComments: String?) {
        if let index = cleaningServices.firstIndex(where: { $0.address == service.address && $0.taskStartTime == service.taskStartTime }) {
            cleaningServices[index].rating = rating
            cleaningServices[index].feedbackText = feedback
            cleaningServices[index].feedbackComments = feedbackComments // Update feedback comments
        }
    }

    // Helper function to filter services by multiple statuses
    func getServicesFilteredByStatus(statuses: [TaskStatus]) -> [CleaningService] {
        return cleaningServices.filter { statuses.contains($0.taskStatus) }
    }
}
