//
//  AboutView.swift
//  InSpace
//
//  Created by Andy Copsey on 02/01/2025.
//

import UIKit

class AboutView: UIViewController {
    
    // Outlets
    @IBOutlet weak var imgAvatar: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imgAvatar.layer.cornerRadius = imgAvatar.frame.height / 2
        imgAvatar.layer.masksToBounds = true
    }
    
    /// User taps on the reset popups button
    @IBAction func tapResetHelp() {
        Defaults.deleteKey(key: "hasSeenWelcome")
        Defaults.deleteKey(key: "shownHelp")
        
        // show a confirmation alert
        UIAlertController.show(parent: self, title: "Help Reset", message: "The app's help popups have been reset and will display next time you fully close and re-open the app.")
    }

    /// User taps on the licence details button
    @IBAction func tapLicenceDetails() {
        let url = URL(string: "https://creativecommons.org/licenses/by-nc-nd/4.0/deed.en")!
        UIApplication.shared.open(url)
    }
    
    /// User taps on the GitHub button
    @IBAction func tapVisitGitHub() {
        let url = URL(string: "https://github.com/Pixel-Prime/InSpace")!
        UIApplication.shared.open(url)
    }
    
    /// User taps on the LinkedIn button
    @IBAction func tapVisitLinkedIn() {
        let url = URL(string: "https://www.linkedin.com/in/andy-copsey-bab713a8")!
        UIApplication.shared.open(url)
    }
}
