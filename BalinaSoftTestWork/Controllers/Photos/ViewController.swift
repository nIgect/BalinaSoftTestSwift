

import UIKit
import SWRevealViewController
import CoreData
import SDWebImage
import SVProgressHUD
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var openSlide: UIBarButtonItem!
    
    //MARK: - Properties
    
    let imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if self.revealViewController() != nil {
            openSlide.target = self.revealViewController()
            openSlide.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.imagePicker.delegate = self
        
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
        longPressedSettings()
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getImagesFromServer(page: 0)
    }
    //MARK: - Actions
    
    @IBAction func exitAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are you shure?", message: "Wan't to exit?", preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "Ok", style: .destructive) { (exit) in
            let storyboard = UIStoryboard.init(name: "LoginAndRegisterStoryboard", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                
                userID = ""
                username = ""
                token = ""
                
                DispatchQueue.main.async { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.present(vc, animated: true, completion: nil)
                }
            }
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK:Open camera or gallery
    
    @IBAction func floatActionButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Photo source", message: "Choose a source ", preferredStyle: .actionSheet)
        let actionOpen = UIAlertAction(title: "Camera", style: .default,handler:{ (openCamera) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Error", message: "Camera not available", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
        })
        
        let actionSelect = UIAlertAction(title: "Photo library", style: .default, handler: { (openGalery) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let actionCancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(actionOpen)
        alert.addAction(actionSelect)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Selectors
    
    func deleteComment(with comment: Comment, photoId: String, completion: @escaping ()->()) {
        ServerManager.shared.deleteComment(photoId: photoId, commentId: comment.id!, completion: { (success, response, error) in
            if success {
                CoreDataManager.shared.managedObjectContext.delete(comment)
                CoreDataManager.shared.saveContext()
                completion()
            } else {
                let alert = UIAlertController(title: "Error", message: "Couldn't delete comment", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func deletePhoto(with photo: Photo) {
        
        ServerManager.shared.deletePhoto(photoId:photo.id!,completion: { (success, response, errorString) in
            SVProgressHUD.dismiss()
            if success {
                CoreDataManager.shared.managedObjectContext.delete(photo)
                photo.id = ""
                photo.date = ""
                photo.lat = ""
                photo.lng = ""
                photo.url = ""
                CoreDataManager.shared.saveContext()
                
                let alertSuccess = UIAlertController(title: "Attention", message: "Photo successfully delete ", preferredStyle: .alert)
                let actionSuccess = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertSuccess.addAction(actionSuccess)
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                    self.present(alertSuccess, animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: "Error", message: "Couldn't delete photo", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func getImagesFromServer(page:Int) {
        
        ServerManager.shared.getUserImages(page: page) { (success, response, errorString) in
            if success {
                response["data"].arrayValue.forEach({ (serverPhoto) in
                    
                    if !CoreDataManager.shared.photoIds.contains(serverPhoto["id"].stringValue) {
                        
                        if let entityDescription = NSEntityDescription.entity(forEntityName: "Photo", in: CoreDataManager.shared.managedObjectContext) {
                            
                            let photo = Photo.init(entity: entityDescription, insertInto: CoreDataManager.shared.managedObjectContext)
                            
                            photo.date = serverPhoto["date"].stringValue
                            photo.id = serverPhoto["id"].stringValue
                            photo.url = serverPhoto["url"].stringValue
                            photo.lng = serverPhoto["lng"].stringValue
                            photo.lat = serverPhoto["lat"].stringValue
                            
                            CoreDataManager.shared.saveContext()
                        }
                    }
                })
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Settings of long pressed and selector
    
    func longPressedSettings(){
        let longPressed = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressed.minimumPressDuration = 0.5
        longPressed.delegate = self
        longPressed.delaysTouchesBegan = true
        self.photoCollectionView.addGestureRecognizer(longPressed)
    }
    
    @objc func handleLongPress(gesture:UILongPressGestureRecognizer!) {
        guard gesture.state != .ended else {
            return
        }
        
        let position = gesture.location(in: self.photoCollectionView)
        if let photoIndexPath = self.photoCollectionView.indexPathForItem(at: position) {
            
            print(photoIndexPath)
            
            let photo = CoreDataManager.shared.photos[photoIndexPath.row]
            
            
            if gesture.state == .began {
                let alert = UIAlertController(title: "Attention", message: "Are you shure wan't to delete this photo", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "Ok", style: .destructive, handler: { (deletePhoto) in
                    
                    SVProgressHUD.show()
                    
                    if photo.comments?.count != 0 {
                        let dispatchGroup = DispatchGroup()
                        photo.comments?.forEach({ (comment) in
                            dispatchGroup.enter()
                            self.deleteComment(with: comment as! Comment, photoId: photo.id!, completion: {
                                dispatchGroup.leave()
                            })
                        })
                        dispatchGroup.notify(queue: .main, execute: {
                            self.deletePhoto(with: photo)
                        })
                    } else {
                        self.deletePhoto(with: photo)
                    }
                })
                let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alert.addAction(actionCancel)
                alert.addAction(actionOk)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Couldn't find photo at this position", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    
}


//MARK: Data source and delegate of collection view

extension ViewController:  UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreDataManager.shared.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! CollectionViewCell
        
        let photo = CoreDataManager.shared.photos[indexPath.row]
        
        cell.imageViewCell.sd_setImage(with: URL(string: photo.url!), completed: nil)
        cell.dateLabek.text = Int(photo.date!)?.getDateFromTimestamp()
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var rowCount = 20
        
        if indexPath.row + 1 >= rowCount {
            var currentPage = 0
            currentPage += 1
            getImagesFromServer(page: currentPage)
            rowCount += 20
        }
    }
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let storyboard = UIStoryboard(name: "CommentsStoryboard", bundle: nil)
        let commentController = storyboard.instantiateViewController(withIdentifier: "CommetsController") as! CommetsController
        
        
        
        commentController.currentPhoto = CoreDataManager.shared.photos[indexPath.row]
        
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(commentController, animated: true)
        }
        
    }
    
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width - 50
        return CGSize(width: width/3, height: width/3 + 20);
    }
}

//MARK:-Image picker deleagte&datasource

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        guard let imageData = UIImageJPEGRepresentation(image.compressedImage(), 0.1) else { return }
        
        guard let currentPosition: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        
        let timeInterval: Int = Int(Date().timeIntervalSince1970)
        
        ServerManager.shared.getImage(data: imageData.base64EncodedString(), date: timeInterval, lat: "\(currentPosition.latitude)", lng: "\(currentPosition.longitude)") { (success, response, errorString) in
            print(currentPosition.latitude,currentPosition.longitude)
            if success {
                
                if let entityDescription = NSEntityDescription.entity(forEntityName: "Photo", in: CoreDataManager.shared.managedObjectContext) {
                    
                    let photo = Photo.init(entity: entityDescription, insertInto: CoreDataManager.shared.managedObjectContext)
                    
                    photo.date = response["data"]["date"].stringValue
                    photo.id = response["data"]["id"].stringValue
                    photo.url = response["data"]["url"].stringValue
                    photo.lng = response["data"]["lng"].stringValue
                    photo.lat = response["data"]["lat"].stringValue
                    
                    CoreDataManager.shared.saveContext()
                    
                    let customAnnotation = CustomAnnotation(coordinate:currentPosition)
                    print(customAnnotation.coordinate)
                    DispatchQueue.main.async {
                        picker.dismiss(animated: true, completion: nil)
                        self.photoCollectionView.reloadData()
                    }
                }else{
                    
                    let alert = UIAlertController(title: "Error", message: "GPS must be enabled", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
            }else{
                print(errorString)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK: - Compressed image
extension UIImage {
    
    func compressedImage() -> UIImage {
        
        let actualHeight:CGFloat = self.size.height
        let actualWidth:CGFloat = self.size.width
        let imgRatio:CGFloat = actualWidth/actualHeight
        let maxWidth:CGFloat = 500.0
        let resizedHeight:CGFloat = maxWidth/imgRatio
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData)!
    }
}
//MARK: - Date formattes
extension Int {
    
    func getDateFromTimestamp() -> String {
        
        let date = Date(timeIntervalSince1970: Double(self))
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "dd.MM.yyyy"
        
        return dateformatter.string(from: date)
    }
}

extension Int {
    
    func getDateFromTimestampForComment() -> String {
        
        let date = Date(timeIntervalSince1970: Double(self))
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        return dateformatter.string(from: date)
    }
}


extension ViewController : UIGestureRecognizerDelegate{
    
}
extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.startUpdatingLocation()
        
    }
}


