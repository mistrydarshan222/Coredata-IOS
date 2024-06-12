//
//  News.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/8/24.
//
import UIKit
import CoreData

struct NewsArticle {
    var cityName: String
    var title: String
    var description: String
    var sourceName: String
    var author: String
}

class News: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var newsarticles: [Article] = []
    var cityName: String = "" // Added cityName property
    var showhistory: [Showhistory] = [] // Declaring showhistory as a property
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNews(for: "Waterloo")
    }
    
    @IBAction func searchCity(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Enter City Name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "City Name"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            if let cityName = alertController.textFields?.first?.text {
                self?.cityName = cityName // Store cityName in the property
                self?.fetchNews(for: cityName)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func fetchNews(for cityName: String) {
        let apikey = "fcf0af18ad7f46eca43f746805b54849"
        let newsUrlString = "https://newsapi.org/v2/everything?q=\(cityName)&apiKey=\(apikey)"
        
        if let url = URL(string: newsUrlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let newsResponse = try decoder.decode(NewsResponse.self, from: data)
                        
                        self?.newsarticles = newsResponse.articles
                        
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                } else if let error = error {
                    print("Error fetching data: \(error)")
                }
            }.resume()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsarticles.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsData", for: indexPath) as! Newslistcell
        let article = newsarticles[indexPath.row]
        
        cell.newsTitle.text = article.title
        cell.newsDescription.text = article.description
        cell.sourceName.text = article.source.name
        cell.newsAuthor.text = article.author ?? "Unknown Author"
        let newsArticle = History.Article(cityName: cityName, title: article.title, description: article.description, source: History.Article.Source(name: article.source.name), author: article.author)
        let historyViewController = History()
        historyViewController.addNewsToHistory(article: newsArticle)
        return cell
    }
    
    
    func addNewsToHistory(newsArticle: NewsArticle) {
        let newHistory = Showhistory(context: context)
        newHistory.cityName = newsArticle.cityName
        newHistory.newsTitle = newsArticle.title
        newHistory.newsDescription = newsArticle.description
        newHistory.newsSource = newsArticle.sourceName
        newHistory.newsAuthor = newsArticle.author
        newHistory.createdAt = Date()
        
        showhistory.insert(newHistory, at: 0) // Insert new history at the beginning of the array
        
        do {
            try context.save()
            self.tableView.reloadData()
        } catch {
            print("Error adding news to history: \(error)")
        }
    }
    
    
    
    
    struct NewsResponse: Codable {
        let articles: [Article]
    }
    
    struct Article: Codable {
        let title: String
        let description: String
        let source: Source
        let author: String?
        
        struct Source: Codable {
            let name: String
        }
    }
    
}
