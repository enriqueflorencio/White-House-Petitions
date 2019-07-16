//
//  ViewController.swift
//  project7
//
//  Created by Enrique Florencio on 7/8/19.
//  Copyright © 2019 Enrique Florencio. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "White House Petitions "
        //Buttons for the users to see the credits and filter petitions they want to see
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(creditsTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterTapped))
        
        //Make a url
        let urlString : String
        
        //Depending on which tab bar item they select, change the url
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        //Fetching data from the background thread so that the UI doesn't lock
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            //Fetch data from the whitehouse url
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    //Parse that data
                    self?.parse(json: data)
                } else {
                    //If we don't get data, show an error
                    self?.showError()
                }
            } else {
                //If the url doesn't work, show an error
                self?.showError()
            }
        }
        
    }
    
    //Function to parse data
    func parse(json: Data) {
        //JSON decoder used to parse JSON
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            
            //Parsing JSON can be done in the background thread but UI work has to run in the main thread at all times
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    //Function for showing errors
    func showError() {
        //No UI work should be done on the background thread
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    //Function for filtering petitions
    func filter(_ petition: String) {
        //Filter in the background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let lowerCasedPetition = petition.lowercased()
            self?.filteredPetitions = (self?.petitions.filter {
                $0.title.lowercased().contains(lowerCasedPetition) ||
                    $0.body.lowercased().contains(lowerCasedPetition)
                })!
        }
        //Return to the main thread when dealing with UI
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }
    
    //Display the credits to the user with an alert controller
    @objc func creditsTapped() {
        let ac = UIAlertController(title: "Source:", message: "This data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    //Get input from the user and send it to our filter function by using an alert controller
    @objc func filterTapped() {
        let ac = UIAlertController(title: "Enter a petition to look for", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let filter = UIAlertAction(title: "Filter", style: .default) {
            [weak self, weak ac] _ in
            
            guard let petition = ac?.textFields?[0].text else {
                return
            }
            self?.filter(petition)
        }
        ac.addAction(filter)
        present(ac, animated: true)
    }
    
    //Define the number of rows in our tableView depending on if they filtered petitions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(filteredPetitions.isEmpty) {
            return petitions.count
        } else {
            return filteredPetitions.count
        }
    }
    
    //Define the cells within the tableview
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if(filteredPetitions.isEmpty) {
            let petition = petitions[indexPath.row]
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.body
        } else {
            let petition = filteredPetitions[indexPath.row]
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.body
        }
        
        return cell
    }
    
    //Display the content of the petition when a cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        if(filteredPetitions.isEmpty) {
            vc.detailItem = petitions[indexPath.row]
        } else {
            vc.detailItem = filteredPetitions[indexPath.row]
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


