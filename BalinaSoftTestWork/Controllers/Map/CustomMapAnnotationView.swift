

import UIKit

class CustomMapAnnotationView: UIView {
    
    //MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
    }
}
