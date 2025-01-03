//
//  DetailView.swift
//  InSpace
//
//  Created by Andy Copsey on 02/01/2025.
//

import UIKit
import AVKit
import AVFoundation

class DetailView: UIViewController {
    
    // Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var imgContent: UIImageView!
    @IBOutlet weak var vVideoContainer: UIView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var vTextContainer: UIView!
    
    // References
    var feedItem: NASAFeedItem?
    var videoPlayer: AVPlayer?
    private var dataItems: [DataItem] = []
    
    // Styling
    private var colorHeading = UIColor.label
    private var colorSubheading = UIColor.systemRed
    private var colorBody = UIColor.darkGray
    private var sizeHeading: CGFloat = 20.0
    private var sizeBody: CGFloat = 18.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ensure we have the data object to pull from
        guard let item = feedItem, let data = item.data, data.count > 0, let i = data.first else {
            dismiss(animated: true)
            return
        }
        
        // image config
        imgContent.layer.cornerRadius = 8
        imgContent.layer.masksToBounds = true
        imgContent.contentMode = .scaleAspectFill
        imgContent.backgroundColor = .label.withAlphaComponent(0.2)
        
        // i represents the data item we'll be using for this cell
        lblTitle.text = i.title ?? ""
        lblSubtitle.text = i.center ?? ""
        vVideoContainer.isHidden = true
        
        // attempt to parse out the date using the ISO-8601 standard
        let inputDateFormatter = ISO8601DateFormatter()
        inputDateFormatter.formatOptions = [.withInternetDateTime]
        
        // set up an output date formatter
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "d MMMM yyyy 'at' h:mma"
        outputDateFormatter.amSymbol = "am"
        outputDateFormatter.pmSymbol = "pm"
        
        inputDateFormatter.formatOptions = [.withInternetDateTime]
        if let date = inputDateFormatter.date(from: i.date_created ?? "") {
            dataItems.append(DataItem(label: "Created", value: outputDateFormatter.string(from: date)))
        }
        
        // output other known metadata
        if let data = i.center { dataItems.append(DataItem(label: "Center", value: data)) }
        if let data = i.nasa_id { dataItems.append(DataItem(label: "NASA Id", value: data)) }
        if let data = i.secondary_creator { dataItems.append(DataItem(label: "Secondary contributions", value: data)) }
        if let data = i.description { dataItems.append(DataItem(label: "Description", value: data)) }
        
        // output keywords list
        if let keywords = i.keywords, keywords.count > 0 {
            var str = ""
            for k in keywords {
                if !str.isEmpty { str.append(", ") }
                str.append(k)
            }
            dataItems.append(DataItem(label: "Keywords", value: str))
        }
        
        // output the main body text
        let body = NSMutableAttributedString()
        body.append(NSAttributedString.bold("More information\n\n", color: colorHeading, size: sizeHeading))
        
        // add the details list
        if (dataItems.count > 0) {
            for d in dataItems {
                
                /// ensure both label and value have content before we output
                if d.label.count > 0, d.value.count > 0 {
                    body.append(NSAttributedString.bold("\(d.label)\n", color: colorSubheading, size: sizeBody))
                    body.append(NSAttributedString.regular("\(d.value)\n\n", color: colorBody, size: sizeBody))
                }
            }
        }
        
        // add a small amount of additional padding to account for our gradient mask
        body.append(NSAttributedString.regular("\n\n\n\n\n\n", color: colorBody, size: sizeBody))
        
        // apply this text
        txtView.attributedText = body
        
        // check we have a valid image link to fetch
        if let links = item.links, links.count > 0, let imgURL = links[0].href, imgURL.count > 0 {
            if let url = URL(string: imgURL) {
                Task {
                    do {
                        // start loading this image (either from the memory cache, disk cache, or downloaded)
                        let useImage = try await MediaCache.shared.getImage(url: url)
                        
                        // make sure that when this process has completed that we still have a valid instance of this
                        // image (it hasn't lost its reference due to early dismissal)
                        await MainActor.run {
                            if let imgContent = imgContent {
                                imgContent.image = useImage
                                self.view.setNeedsLayout()
                            }
                        }
                    }
                    catch {
                        print("Error loading image '\(url.absoluteString)'")
                    }
                }
            }
        }
        
        // check if this is a video item
        if let type = i.media_type, type.elementsEqual("video") {
            // download the media collection JSON
            if let href = item.href, !href.isEmpty {
                Task { await self.requestCollectionData(href) }
            }
        }
    }
    
    /// Capture view unloading event
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // terminate any running videos
        videoPlayer?.pause()
    }
    
    /// Overrides default view drawing routine
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set up a gradient to use for our text view mask
        let grad = CAGradientLayer()
        grad.frame = vTextContainer.bounds
        grad.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        grad.locations = [0.0, 0.9, 1.0]
        
        // add the mask
        vTextContainer.layer.mask = grad
    }
    
    /// Sets up a video player with a given streamable MP4 file link
    func loadVideoWithURL(_ url: String) {
        print("Loading video: \(url)")
        self.vVideoContainer.isHidden = false
        
        // set up the video player
        guard let videoURL = URL(string: url) else { return }
        videoPlayer = AVPlayer(url: videoURL)
        guard let videoPlayer = videoPlayer else { return }
        
        // add the player controller
        let controller = AVPlayerViewController()
        controller.player = videoPlayer
        addChild(controller)
        controller.view.frame = vVideoContainer.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        vVideoContainer.addSubview(controller.view)
        
        // add constraints
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: vVideoContainer.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: vVideoContainer.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: vVideoContainer.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: vVideoContainer.bottomAnchor)
        ])
        
        // notify that the controller has had its ownership updated
        controller.didMove(toParent: self)
        
        // start the video
        videoPlayer.play()
    }
    
    /// Looks for a valid playable media file in a collection of URLs
    func findAndLoadVideo(_ collection: [String]) {
        for c in collection {
            if c.contains("~mobile.mp4") {
                loadVideoWithURL(c)
                return
            }
        }
    }
    
    /// Requests a new set of collection data for this media item
    func requestCollectionData(_ url: String) async {
        
        print("Requesting collection data to handle video media")
        
        // perform the search request
        do {
            let result = try await FeedManager.requestCollectionData(url)
            guard let result = result as [String]? else {
                print("Unable to parse collection data response as [String]")
                return
            }
            
            // ensure we still have a valid view context before continuing
            guard self.viewIfLoaded?.window != nil else {
                // the view was dismissed, stop here
                return
            }
            
            // parse our collection data
            self.findAndLoadVideo(result)
        }
        catch {
            // unable to download collection data
            print("Unable to download collection data")
        }
    }
    
    /// User taps to close the view
    @IBAction func tapClose() {
        dismiss(animated: true)
    }
    
    /// Defines a label/value pair
    private struct DataItem {
        let label: String
        let value: String
    }
}
