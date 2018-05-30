
import UIKit
import MapKit
import CoreLocation
import SWRevealViewController
import CoreData
import SDWebImage

class MapController: UIViewController  {
    
    //MARK: - Outlets
    
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var mapPhotoView: MKMapView!
    
    //MARK: - Proiperties
    
    let locationManager = CLLocationManager()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapPhotoView.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setMapView()
        
    }
    
    //MARK: - Map zoom
    func zoomByFactor(factor:Double){
        var region:(MKCoordinateRegion) = self.mapPhotoView.region
        var span:(MKCoordinateSpan) = region.span
        span.latitudeDelta *= factor
        span.longitudeDelta *= factor
        region.span = span
        self.mapPhotoView.region = region
        self.mapPhotoView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomPlus(_ sender: Any) {
        zoomByFactor(factor: 0.5)
    }
    @IBAction func zoomMinus(_ sender: Any) {
        zoomByFactor(factor: 2)
    }
    @IBAction func currentLoaction(_ sender: Any) {
        if  mapPhotoView.showsUserLocation == true{
            mapPhotoView.showAnnotations([self.mapPhotoView.userLocation], animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "GPS must be enabled", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - Set map view to current photo
    func setMapView() {
      
           if CoreDataManager.shared.photos.first == nil {
            let alert = UIAlertController(title: "Attention", message: "Add photos on map", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
           }else{
            let initialLocation = CLLocation(latitude: Double(CoreDataManager.shared.photos.first!.lat!)!, longitude: Double(CoreDataManager.shared.photos.first!.lng!)!)
            centerMapOnLocation(location: initialLocation, regionRadius: 1000000, animated: false)
           }
        
      
        
      
        
        mapPhotoView.mapType = .standard
        mapPhotoView.delegate = self
        
        for photo in CoreDataManager.shared.photos {
            let loc = CLLocation(latitude: Double(photo.lat!)!, longitude: Double(photo.lng!)!)
            //            let loc = CLLocation(latitude: 53, longitude: 27)
            print(loc.coordinate)
            createMarkerWithLocation(location: loc, photo: photo.url!)
        }
    }
    //MARK: - Create marker with current location
    func createMarkerWithLocation(location : CLLocation, photo: String) {
        
        let point = CustomAnnotation(coordinate: location.coordinate)
        
        point.photoUrl = photo
        
        self.mapPhotoView.addAnnotation(point)
    }
    //MARK: - Center map on location
    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance, animated: Bool) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, 10000000)
        mapPhotoView.setRegion(coordinateRegion, animated: animated)
    }
    
    
}
//MARK: -  MKMapViewDelegate
extension MapController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = self.mapPhotoView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named:"map-marker-4")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        
        if view.annotation is MKUserLocation {
            return
        }
        
        let customAnnotation = view.annotation as! CustomAnnotation
        let annotationView = UINib(nibName: "CustomMapAnnotationView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomMapAnnotationView
        
        annotationView.imageView.sd_setImage(with: URL(string:customAnnotation.photoUrl!), completed: nil)
        annotationView.center = CGPoint(x: view.bounds.size.width / 2, y: -annotationView.bounds.size.height * 0.52)
        
        view.addSubview(annotationView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }
}
//MARK: - CLLocationManagerDelegate
extension MapController :  CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapPhotoView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
}
//MARK: - extension UIImage resize image
extension UIImage {
    
    func resizeImage(with targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio,height: size.height * heightRatio)
        } else {
            newSize = CGSize.init(width: size.width * widthRatio,height:  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x:0,y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}







