//
//  History.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/8/24.
//

import UIKit
import CoreData

class History: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var showhistory = [Showhistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHistory()
    }
    
    struct Article {
        var cityName: String
        var title: String
        var description: String
        var source: Source
        var author: String?
        
        struct Source {
            var name: String
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showhistory.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let history = showhistory[indexPath.row]
        
        if history.newsTitle != nil { // Check if it's a news history entry
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsHistory", for: indexPath) as! Newshistorycell
            cell.cityName.text = history.cityName
            cell.newsTitle.text = history.newsTitle
            cell.newsDescription.text = history.newsDescription
            cell.newsSource.text = history.newsSource
            cell.newsAuthor.text = history.newsAuthor
            return cell
        } else if history.from != nil { // Check if it's a map history entry
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapHistory", for: indexPath) as! Maphistorycell
            cell.from.text = "Starting Point: \(history.from ?? "Unknown")"
            cell.to.text = "Ending Point: \(history.to ?? "Unknown")"
            cell.distance.text = "Distance: \(history.distance ?? "Unknown")"
            cell.modeOfTransport.text = "Mode: \(history.modeOfTravel ?? "Unknown")"
            return cell
        } else { // Otherwise, it's a weather history entry
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherHistory", for: indexPath) as! Weatherhistorycell
            cell.cityName.text = history.cityName
            cell.temperature.text = history.temperature
            cell.humidity.text = history.humidity
            cell.windSpeed.text = history.windSpeed
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let historyToDelete = showhistory[indexPath.row]
            context.delete(historyToDelete)
            
            do {
                try context.save()
                showhistory.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting history: \(error)")
            }
        }
    }
    
    func fetchHistory() {
        var allHistory = [Showhistory]()
        
        // Fetch all news history
        if let newsHistory = fetchAllHistory(withPredicate: NSPredicate(format: "newsTitle != nil")) {
            allHistory.append(contentsOf: newsHistory)
        }
        
        // Fetch all map history
        if let mapHistory = fetchAllHistory(withPredicate: NSPredicate(format: "from != nil")) {
            allHistory.append(contentsOf: mapHistory)
        }
        
        // Fetch all weather history
        if let weatherHistory = fetchAllHistory(withPredicate: NSPredicate(format: "cityName != nil")) {
            allHistory.append(contentsOf: weatherHistory)
        }
        
        // Sort all history entries by createdAt in descending order
        allHistory.sort { $0.createdAt! > $1.createdAt! }
        
        showhistory = allHistory
        self.tableView.reloadData()
    }

    func fetchAllHistory(withPredicate predicate: NSPredicate) -> [Showhistory]? {
        let fetchRequest: NSFetchRequest<Showhistory> = Showhistory.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            print("Error while fetching history: \(error)")
            return nil
        }
    }


    
    func addNewsToHistory(article: Article) {
        if let existingHistory = showhistory.first {
            // Update existing history entry with new information for the latest searched city
            existingHistory.cityName = article.cityName
            existingHistory.newsTitle = article.title
            existingHistory.newsDescription = article.description
            existingHistory.newsSource = article.source.name
            existingHistory.newsAuthor = article.author ?? "Unknown Author"
            existingHistory.createdAt = Date()
        }
        else {
            // Create a new history entry for the latest searched city
            let newHistory = Showhistory(context: context)
            newHistory.cityName = article.cityName
            newHistory.newsTitle = article.title
            newHistory.newsDescription = article.description
            newHistory.newsSource = article.source.name
            newHistory.newsAuthor = article.author ?? "Unknown Author"
            newHistory.createdAt = Date()
            
            showhistory.append(newHistory)
        }
        
        do {
            try context.save()
            self.tableView.reloadData()
        } catch {
            print("Error adding news to history: \(error)")
        }
    }
    
}
