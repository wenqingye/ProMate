
import Foundation
import UIKit

class ProjectCell: UITableViewCell {
	
	@IBOutlet weak var projectNameLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		projectNameLabel.sizeToFit()
	}
}

class TaskCell: UITableViewCell {
	
	@IBOutlet weak var taskNameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var markButton: UIButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		taskNameLabel.sizeToFit()
		dateLabel.sizeToFit()
	}
}

class UserCell: UITableViewCell {
	
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var selectButton: UIButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		profileImage.asCircle()
		nameLabel.sizeToFit()
		emailLabel.sizeToFit()
	}
}
