//
//  HomePageController.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/4.
//

import Foundation
import UIKit

class HomePageController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var repositories:[Repository] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGitHubRepositories()
    }
    
    //basic function
    func fetchGitHubRepositories() {
        let url = URL(string: AppConstants.GitHost.repositionUrl)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let repositories = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    self.repositories = repositories.compactMap(Repository.init)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    //dataSource function
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.repositories.isEmpty {
            return UITableViewCell.init();
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let repository = self.repositories[indexPath.row]
        cell.textLabel?.text = repository.fullName
        cell.detailTextLabel?.text = repository.description;
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
//segue function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let destVC = segue.destination as? CategoryDetailController {
                let indexPath = self.tableView.indexPathForSelectedRow;
                let repo = self.repositories[indexPath!.row];
                destVC.detailInfo = repo.fullName;
            }
        }
    }
    
}
