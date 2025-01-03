//
//  ItemCell.swift
//  InSpace
//
//  Created by Andy Copsey on 02/01/2025.
//

import UIKit

class ItemCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgThumb.layer.cornerRadius = 8
        imgThumb.layer.masksToBounds = true
        imgThumb.contentMode = .scaleAspectFill
        imgThumb.backgroundColor = .label.withAlphaComponent(0.2)
        lblTitle.text = ""
        lblSubtitle.text = ""
        lblDetail.text = ""
        imgPlay.layer.shadowOffset = CGSize(width: 0, height: 0)
        imgPlay.layer.shadowOpacity = 0.5
        imgPlay.layer.shadowRadius = 6
        imgPlay.layer.shadowColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Loads a single feed item into this cell
    func loadData(_ item: NASAFeedItem, inputDateFormatter: ISO8601DateFormatter, outputDateFormatter: DateFormatter, indexPath: IndexPath, tableView: UITableView) {
        
        // Hide the play button until we're sure this is a playable video item
        imgPlay.isHidden = true
        
        // ensure we have the data object to pull from
        guard let data = item.data, data.count > 0, let i = data.first else { return }
        
        // i represents the data item we'll be using for this cell
        lblTitle.text = i.title ?? ""
        lblSubtitle.text = i.center ?? ""
        
        // format the date, which can be identified in the international ISO-8601 standard
        if let date = inputDateFormatter.date(from: i.date_created ?? "") {
            lblDetail.text = outputDateFormatter.string(from: date)
        }
        else {
            lblDetail.text = ""
        }
        
        // reset the image (until we know for sure we have it available)
        imgThumb.image = nil
        
        // make sure we have a valid image link to fetch
        if let links = item.links, links.count > 0, let imgURL = links[0].href, imgURL.count > 0 {
            if let url = URL(string: imgURL) {
                Task {
                    do {
                        // start loading this image (either from the memory cache, disk cache, or downloaded)
                        let cellImage = try await MediaCache.shared.getImage(url: url)
                        
                        // make sure that when this process has completed that we still have a valid instance of this
                        // cell, and it hasn't been recycled for another cell (due to dequeuing)
                        await MainActor.run {
                            if let originCell = tableView.cellForRow(at: indexPath) as? ItemCell {
                                originCell.imgThumb.image = cellImage
                                originCell.setNeedsLayout()
                            }
                        }
                    }
                    catch {
                        print("Error loading cell image '\(url.absoluteString)' in row \(indexPath.row)")
                    }
                }
            }
        }
        
        // is this a video item?
        if let type = i.media_type, type.elementsEqual("video") {
            imgPlay.isHidden = false
        }
    }
}
