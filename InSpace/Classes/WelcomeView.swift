//
//  WelcomeView.swift
//  InSpace
//
//  Created by Andy Copsey on 03/01/2025.
//

import UIKit

class WelcomeView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // check if we've already shown this view in a previous session
        let hasSeenWelcome = Defaults.readString(key: "hasSeenWelcome")
        if (!hasSeenWelcome.isEmpty) {
            tapViewMain()
            return
        }
        
        // set a flag to indicate this view has been seen
        Defaults.writeString(key: "hasSeenWelcome", value: "1")
    }

    /// Called when the user interacts with the tap gesture recognizer
    @IBAction func tapViewMain() {
        // load the required view controller
        guard let nav = self.navigationController, let sb = storyboard, let vc = sb.instantiateViewController(withIdentifier: "homeView") as UIViewController? else {
            return
        }
        
        // reset the navigation stack to only contain the new view controller
        // (prevents pops to root coming back here)
        nav.setViewControllers([vc], animated: true)
    }
}
