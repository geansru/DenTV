//
//  VideoCell.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 13.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(video: Video) {
        title.text = video.name
        about.text = video.about
        let url = NSURL(string: video.thumb!)!
        thumb.loadImageWithURL(url)
    }

}
