//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Yury Radetsky on 27.08.2020.
//  Copyright © 2020 YuryRadetsky. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
        
    // MARK: - Private Properties
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filtredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        
        setupSarchController()

    }
        
    // MARK: - Private Methods
    
    private func setupSarchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder =  "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "type", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    
    @IBAction func unwindSeque (_ seqgue: UIStoryboardSegue) {
        guard let newPlaceVC = seqgue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorting.toggle()
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
}

// MARK: - Table View DataSource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredPlaces.count
        }
        return  places.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating
        return cell
    }
}

// MARK: - Table View Delegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath , animated: true )
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
}

// MARK: - Search Results Updating
extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchTest: String) {
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchTest, searchTest)
        tableView.reloadData()
    }
    
}
