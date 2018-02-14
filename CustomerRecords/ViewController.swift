//
//  ViewController.swift
//  CustomerRecords
//
//  Created by Adro's Macbook on 14/02/2018.
//  Copyright © 2018 Adromil Balais. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var customerTableView: UITableView!
    
    var customers: [[String: Any]] = []
    var isEmpty = false
    var errorMessage = ""
    
    // Setup predefined point of interet coordinates and distance limit in km
    let center: CLLocation = CLLocation.init(latitude: 53.339428, longitude: -6.257664)
    let distanceKMLimit: CLLocationDistance = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customerTableView.allowsSelection = false
        
        // Get the array of customers passing the distance limit as argument an assign to `customers` variable
        customers = getCustomers(within: distanceKMLimit)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UITableView data sources
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Check if `customers` is empty to set `isEmpty` variable to true
        if (customers.count < 1) {
            isEmpty = true
            return 1
        }
        return customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CustomerCell"
        let cell = customerTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        // Check if `isEmpty` variable is true to notify user of empty record
        // If `isEmpty` is false display all records per cell
        if isEmpty {
            cell.textLabel?.text = errorMessage
            cell.detailTextLabel?.text = ""
        } else {
            cell.textLabel?.text = customers[indexPath.row]["name"] as? String
            cell.detailTextLabel?.text = "User ID: \(String(describing: customers[indexPath.row]["user_id"]!))"
        }
        return cell
    }
    
    // MARK: UITableView delegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // Set the Title Header of the UITableView inidcating the what records are listed.
        return "Customer Records (within \(NSNumber(value: distanceKMLimit).intValue) km)"
    }
    
    // MARK: Custom methods
    
    // Method to get the array of customers based on the limit distance argument
    func getCustomers(within distance: CLLocationDistance) -> [[String: Any]] {
        
        // Initialize array as empty
        var custArray: [[String: Any]] = []
        
        // Assign initial string for empty record to `errorMessage` variable
        errorMessage = "No Records Founds"
        
        // Set the resource file stream path to `path` variable
        if let path = Bundle.main.path(forResource: "gistfile1", ofType: "txt") {
            
            // Try to locate the resource text file (gistfile1.txt)
            if let dataString = try? String(contentsOfFile: path, encoding: .utf8) {
                
                // Parse the resource text file and loop each object per line
                let custStrings = dataString.components(separatedBy: .newlines)
                for custString: String in custStrings {
                    
                    // Check for empty line
                    if custString.trimmingCharacters(in: .whitespaces) != "" {
                        
                        // Serialize objects per line and assign to `loc` CLLocation object the respective coordinates
                        do {
                            let custDictionary = try JSONSerialization.jsonObject(with: custString.data(using: String.Encoding.utf8)!, options: []) as! [String: Any]
                            let lat: Double =  (custDictionary["latitude"] as! NSString).doubleValue
                            let long: Double = (custDictionary["longitude"] as! NSString).doubleValue
                            let loc: CLLocation = CLLocation.init(latitude: lat, longitude: long)
                            
                            // Convert result distance in meters(m) to kilometers(km)
                            let locDistance: CLLocationDistance = loc.distance(from: center) / 1000
                            
                            // Check if distance is withing 100km and add to `custArray` object variable
                            if locDistance <= distance {
                                custArray.append(custDictionary)
                            }
                        } catch {
                            // Skip line if not in JSON format
                        }
                    }
                }
                
                // Do the sorting in ascending order by `user_id` key
                custArray.sort(by: { (a, b) -> Bool in
                    return (a["user_id"] as! Int) < (b["user_id"] as! Int)
                })
            } else {
                
                // Set message prompt here for missing resource
                errorMessage = "Resource was Not Found"
            }            
        }
        return custArray
    }
}

