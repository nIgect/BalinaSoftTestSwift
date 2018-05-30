

import UIKit

class CommentsViewCell: UITableViewCell {

    @IBOutlet weak var textCommentLabel: UILabel!
    @IBOutlet weak var dateCommnetLabel: UILabel!
    @IBOutlet weak var backViewCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
