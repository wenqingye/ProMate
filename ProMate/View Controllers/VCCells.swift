
import Foundation
import UIKit

class ProjectCell: UITableViewCell {
	
	@IBOutlet weak var projectNameLabel: UILabel!
	@IBOutlet weak var managerNameLabel: UILabel!
}

class TaskCell: UITableViewCell {
	
	@IBOutlet weak var taskNameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var markButton: UIButton!
}

class UserCell: UITableViewCell {
	
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var selectButton: UIButton!
}
