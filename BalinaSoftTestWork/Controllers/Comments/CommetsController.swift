

import UIKit
import SDWebImage
import CoreData

class CommetsController: UIViewController {
    //MARK: - Properties
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var dateLabelForComment: UILabel!
    
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    
    @IBOutlet weak var addCommentTextField: UITextField!
    
    let date = NSDate()
    
    var currentPhoto: Photo!
    var currentComment: Comment!
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getImageview()
        getDate()
        self.commentsTableView.tableFooterView = UIView()
        self.addCommentTextField.delegate = self
        self.commentsTableView.delegate = self
        self.commentsTableView.dataSource = self
        longPressedSettings()
        getCommentsFromServer(page: 0)
        hideKeyboardWhenTappedAround()
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Return to gallery
    @IBAction func comebackToGallery(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - Get image from main screen
    func getImageview(){
        photoImageView.sd_setImage(with: URL(string:currentPhoto.url!), completed: nil)
        
    }
    //MARK: - Get date from main screen
    func getDate(){
        dateLabelForComment.text = "\(currentPhoto.date!)".getDateFromTimestampForComment()
    }
    //FIXME
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    //MARK: - Selectors
    
    
    //MARK: - Post comment
    @IBAction func postCommentAction(_ sender: Any) {
        
        if let text = addCommentTextField.text {
            if !text.isEmpty {
                ServerManager.shared.postComment(text: addCommentTextField.text!, photoId:(currentPhoto.id!)) { (success, response, errorString) in
                    if let entityDescription = NSEntityDescription.entity(forEntityName: "Comment", in: CoreDataManager.shared.managedObjectContext) {
                        
                        let comment = Comment.init(entity: entityDescription, insertInto: CoreDataManager.shared.managedObjectContext)
                        
                        comment.date = response["data"]["date"].stringValue
                        comment.text = response["data"]["text"].stringValue
                        comment.id = response["data"]["id"].stringValue
                        comment.photo = self.currentPhoto
                        
                        CoreDataManager.shared.saveContext()
                        
                        DispatchQueue.main.async { [weak self] () -> Void in
                            
                            guard let strongSelf = self else { return }
                            self?.addCommentTextField.text = ""
                            
                            strongSelf.commentsTableView.reloadData()
                        }
                    }
                }
            } else {
               showAlert()
            }
        } else {
            showAlert()
        }
    }
    
    
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Fill in text field", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Delete comment
    func longPressedSettings(){
        let longPressed = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressed.minimumPressDuration = 0.5
        longPressed.delegate = self
        longPressed.delaysTouchesBegan = true
        self.commentsTableView.addGestureRecognizer(longPressed)
    }
    
    @objc func handleLongPress(gesture:UILongPressGestureRecognizer!) {
        guard gesture.state != .ended else {
            return
        }
        
        let position = gesture.location(in: self.commentsTableView)
        if let commentIndexPath = self.commentsTableView.indexPathForRow(at: position) {
            
            print(commentIndexPath)
            
            let comment = CoreDataManager.shared.comments[commentIndexPath.row]
            
            if gesture.state == .began {
                let alert = UIAlertController(title: "Attention", message: "Are you shure wan't to delete this comment", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "Ok", style: .destructive, handler: { (deleteComment) in
                    ServerManager.shared.deleteComment(photoId: self.currentPhoto.id!, commentId: comment.id!, completion: { (success, response, error) in
                        if success {
                            CoreDataManager.shared.managedObjectContext.delete(comment)
                            CoreDataManager.shared.saveContext()
                            let alertSuccess = UIAlertController(title: "Attention", message: "Comment successfully delete ", preferredStyle: .alert)
                            let actionSuccess = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alertSuccess.addAction(actionSuccess)
                            DispatchQueue.main.async {
                                self.commentsTableView.reloadData()
                                self.present(alertSuccess, animated: true, completion: nil)
                            }
                        }else {
                            let alert = UIAlertController(title: "Error", message: "Couldn't delete comment", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alert.addAction(action)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                })
                let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alert.addAction(actionCancel)
                alert.addAction(actionOk)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }else {
                let alert = UIAlertController(title: "Error", message: "Couldn't find comment at this position", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    
    //MARK: - Get comments from server
    func getCommentsFromServer(page:Int){
        ServerManager.shared.getComment(photoId: (currentPhoto.id!), page: page) { (success, response, stringError) in
            if success {
                response["data"].arrayValue.forEach({ (serverComment) in
                    if !CoreDataManager.shared.commentsIds.contains(serverComment["id"].stringValue){
                        if let entityDescription = NSEntityDescription.entity(forEntityName: "Comment", in: CoreDataManager.shared.managedObjectContext){
                            let comment = Comment.init(entity: entityDescription, insertInto: CoreDataManager.shared.managedObjectContext)
                            comment.date = serverComment["date"].stringValue
                            comment.text = serverComment["text"].stringValue
                            comment.id = serverComment["id"].stringValue
                            comment.photo = self.currentPhoto
                            CoreDataManager.shared.saveContext()
                        }
                    }
                })
                DispatchQueue.main.async { [weak self] () -> Void in
                    
                    guard let strongSelf = self else { return }
                    strongSelf.commentsTableView.reloadData()
                }
            }
            
        }
    }
    
    
    
    func getDate(time: Int) -> String {
        
        let date = Date(timeIntervalSince1970: Double(time))
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM.dd.yyyy HH:mm"
        
        return dateformatter.string(from: date)
    }
}

//MARK: - UITableViewDelegate
extension CommetsController:UITableViewDelegate {
    
    
}

//MARK: - UITableViewDataSource
extension CommetsController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comments =  currentPhoto.comments {
            return comments.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsViewCell", for: indexPath) as! CommentsViewCell
        
        let comment = (currentPhoto.comments?.allObjects as! [Comment])[indexPath.row]
        
         cell.textCommentLabel.text = comment.text
         cell.dateCommnetLabel.text = getDate(time: Int(comment.date!)!)
        
        cell.backViewCell.layer.cornerRadius = 15
        cell.backViewCell.layer.masksToBounds = true
        
        return cell
    }
    
    
    
    
}
extension CommetsController:UITextFieldDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addCommentTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
}
extension String {
    
    func getDateFromTimestampForComment() -> String {
        
        let date = Date(timeIntervalSince1970: Double(self)!)
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        return dateformatter.string(from: date)
    }
}
extension CommetsController : UIGestureRecognizerDelegate{
    
}
