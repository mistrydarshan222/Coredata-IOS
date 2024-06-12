//
//  Newslistcell.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/14/24.
//

import UIKit

class Newslistcell: UITableViewCell {
    
    
    @IBOutlet weak var newsTitle: UILabel!
    
    @IBOutlet weak var newsDescription: UITextView!
    
    @IBOutlet weak var sourceName: UILabel!
    
    @IBOutlet weak var newsAuthor: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
