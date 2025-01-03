//
//  HelpOverlay.swift
//  InSpace
//
//  Created by Andy Copsey on 03/01/2025.
//

import UIKit

class HelpOverlay: UIViewController {

    // Outlets
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        vContainer.layer.cornerRadius = 16
        vContainer.layer.masksToBounds = true
        vContainer.addShadow(size: 10, opacity: 0.2, offset: 10)
        
        // capture scroll events
        scrollView.delegate = self
    }

    /// User taps to enter the app (close the help overlay)
    @IBAction func tapGo() {
        // disable further taps in this view
        view.isUserInteractionEnabled = false
        
        // fade out the view before destroying
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 0
        } completion: { complete in
            Defaults.writeString(key: "shownHelp", value: "1")
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}

/// Extension to handle scroll delegate events
extension HelpOverlay: UIScrollViewDelegate {
    
    // capture scroll events to calculate the current page
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var pg = Int(scrollView.contentOffset.x / 305)
        if (pg < 0) { pg = 0 }
        if (pg > 2) { pg = 2 }
        pageControl.currentPage = pg
    }
}
