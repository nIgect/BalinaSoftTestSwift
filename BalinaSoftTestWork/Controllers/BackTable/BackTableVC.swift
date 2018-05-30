import Foundation
import UIKit
import SWRevealViewController

class BackTableVC: UITableViewController  {
    
    var tableArray = [String]()
    var userName: String?
    var myIndex = 0
    
    @IBOutlet weak var userNameOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableArray = ["Photos" , "Map"]
        self.tableView.tableFooterView = UIView()
    }
    
    //MARK:Data source and delegate of table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuHeaderCell") as! MenuHeaderCell
        
        cell.nameLabel.text = username!
        
        return cell
    }
    
    //MARK: Selected maps or photo
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        
        if myIndex == 0 {
            let storyboard = UIStoryboard(name: "Reveal", bundle: nil)
            let mainController = storyboard.instantiateInitialViewController()
           
            DispatchQueue.main.async {
                self.revealViewController().pushFrontViewController(mainController, animated: true)
            }
         
        }else if myIndex == 1{
            let storyboard = UIStoryboard(name: "MapStoryboard", bundle: nil)
            if let mapController = storyboard.instantiateInitialViewController() {
                DispatchQueue.main.async {
                    self.revealViewController().pushFrontViewController(mapController, animated: true)
                }
            }
        }
    }
        
  


}

