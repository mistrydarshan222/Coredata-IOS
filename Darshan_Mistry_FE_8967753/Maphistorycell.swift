//
//  Maphistorycell.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/17/24.
//

import UIKit

class Maphistorycell: UITableViewCell {
    
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var from: UILabel!
    
    @IBOutlet weak var to: UILabel!
    
    @IBOutlet weak var modeOfTransport: UILabel!

    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
