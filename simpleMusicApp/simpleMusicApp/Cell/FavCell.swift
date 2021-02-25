//
//  FavCell.swift
//  simpleMusicApp
//
//  Created by Kalbek Saduakassov on 25.02.2021.
//

import UIKit

class FavCell: UITableViewCell {
    @IBOutlet weak var artImage: UIImageView!
    @IBOutlet weak var trackLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
