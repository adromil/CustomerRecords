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
    let locMgr: CLLocationManager = CLLocationManager()
    
    let center: CLLocation = CLLocation.init(latitude: 53.339428, longitude: -6.257664)
    let distanceKMLimit: CLLocationDistance = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        print(customers.count)
        return customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CustomerCell"
        let cell = customerTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = customers[indexPath.row]["name"] as? String
        cell.detailTextLabel?.text = String(describing: customers[indexPath.row]["user_id"]!)
        return cell
    }
    
    // MARK: UITableView delegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Customer Records (within 100km)"
    }
    
    // MARK: Custom methods
    
    func getCustomers(within distance: CLLocationDistance) -> [[String: Any]] {
        var custArray: [[String: Any]] = []
        if let path = Bundle.main.path(forResource: "gistfile1", ofType: "txt") {
            do {
                let dataString = try String(contentsOfFile: path, encoding: .utf8)
                let custStrings = dataString.components(separatedBy: .newlines)
                print(custStrings.count)
                for custString: String in custStrings {
                    let custDictionary = try! JSONSerialization.jsonObject(with: custString.data(using: String.Encoding.utf8)!, options: []) as! [String: Any]
                    let lat: Double =  (custDictionary["latitude"] as! NSString).doubleValue
                    let long: Double = (custDictionary["longitude"] as! NSString).doubleValue
                    let loc: CLLocation = CLLocation.init(latitude: lat, longitude: long)
                    
                    let locDistance: CLLocationDistance = loc.distance(from: center) / 1000
                    
                    if locDistance <= distance {
                        custArray.append(custDictionary)
                    }
                    custArray.sort(by: { (a, b) -> Bool in
                        return (a["user_id"] as! Int) < (b["user_id"] as! Int)
                    })
                }
            } catch {
                print(error)
            }
        }
        return custArray
    }
    
}

