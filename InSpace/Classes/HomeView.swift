//
//  ViewController.swift
//  InSpace
//
//  Created by Andy Copsey on 27/12/2024.
//

import UIKit

class HomeView: UIViewController {
    
    /// The default feed keywords to use
    fileprivate let defaultFeedKeywords: String = "jupiter"
    
    // Outlets
    @IBOutlet weak var tview: UITableView!
    @IBOutlet weak var vTableContainer: UIView!
    @IBOutlet weak var btnRandomTopic: UIButton!
    @IBOutlet weak var lblTopic: UILabel!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var vLoadingTopic: UIView!
    @IBOutlet weak var vTopicScroller: UIView!
    
    /// Stores a list of feed results
    var lastResults: NASAFeedContainer?
    
    /// The last performed search
    var lastSearch: String = ""
    
    /// Date formatter (declared at top level for better efficiency)
    let inputDateFormatter = ISO8601DateFormatter()
    let outputDateFormatter = DateFormatter()
    
    /// A search bar to use as the table view's header view
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search for something!"
        sb.sizeToFit()
        return sb
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set up the search parameters
        lastSearch = defaultFeedKeywords
        
        // check if we have a saved feed session
        let lastSaved = Defaults.readString(key: "lastFeed")
        if (!lastSaved.isEmpty) { lastSearch = lastSaved }
        
        lblTopic.text = "L O A D I N G"
        aiv.isHidden = false
        btnRandomTopic.isHidden = true
        vLoadingTopic.isHidden = true
        
        // topic loader styling
        vLoadingTopic.layer.cornerRadius = 8
        vLoadingTopic.addShadow(size: 10, opacity: 0.3, offset: 10)
        
        // set up the table view
        let nib = UINib(nibName: "ItemCell", bundle: .main)
        tview.register(nib, forCellReuseIdentifier: "cell")
        tview.dataSource = self
        tview.delegate = self
        tview.keyboardDismissMode = .onDrag
        
        let sb = self.searchBar
        sb.delegate = self
        tview.tableHeaderView = sb
        
        // set up the date foramtter
        inputDateFormatter.formatOptions = [.withInternetDateTime]
        outputDateFormatter.dateFormat = "d MMMM yyyy 'at' h:mma"
        outputDateFormatter.amSymbol = "am"
        outputDateFormatter.pmSymbol = "pm"
        
        // check if we have an offline version of our main feed
        let file = FileManager.default.filenameForKeywords(lastSearch)
        if (FileManager.default.hasSavedFile(file)) {
            do {
                let data = try FileManager.default.readDataFromDocs(filename: file) as NASAFeedContainer?
                lastResults = data
                
                // update the feed display
                DispatchQueue.main.async { self.displaySearchResults() }
            }
            catch {
                print("No saved data for default feed")
                lastSearch = defaultFeedKeywords
                loadDefaultFeed()
            }
        }
        else {
            // load the default feed
            lastSearch = defaultFeedKeywords
            loadDefaultFeed()
        }
        
        // show the help view, if not already seen
        let shownHelp = Defaults.readString(key: "shownHelp")
        if (shownHelp.isEmpty) {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "helpOverlay") {
                // injects this new view controller's view into the current parent
                // (see Extensions.swift for implementation details of this function)
                vc.injectView(into: self, animated: true)
            }
        }
    }
    
    /// Loads the default feed
    private func loadDefaultFeed() {
        
        print("Loading default feed")
        Task { await fetchFeed(keywords: "jupiter") }
    }
    
    /// Attempts to perform a new search feed request
    private func fetchFeed(keywords: String) async {
        
        do {
            // perform the search request
            let result = try await FeedManager.requestSearch(keywords)
            guard let result = result as NASAFeedContainer? else {
                UIAlertController.show(parent: self, title: "Error", message: "Unable to download at this time")
                enableUI()
                return
            }
            
            // copy these results
            lastResults = result
            lastSearch = keywords
            
            // write this to the user defaults so that we can restore it on next load
            Defaults.writeString(key: "lastFeed", value: keywords)
            
            // flatten the search keywords into a suitable filename
            let filename = FileManager.default.filenameForKeywords(keywords)
            do {
                // try writing these results to disk for later offline retrieval
                let data = try JSONEncoder().encode(result)
                try FileManager.default.writeDataToDocs(data: data, filename: filename)
            }
            catch {
                print("Unable to save feed result to disk!")
            }
            
            // update the feed display
            DispatchQueue.main.async { self.displaySearchResults() }
        }
        catch (let error) {
            UIAlertController.show(parent: self, title: "Error", message: error.localizedDescription)
            enableUI()
        }
    }
    
    /// Updates the search results display
    private func displaySearchResults() {
        
        // fade between the old topic heading and the new one
        UIView.transition(with: lblTopic, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.lblTopic.text = self.getPaddedString(self.lastSearch.uppercased())
        }, completion: nil)
        
        // load the new table data
        tview.reloadData()
        enableUI()
    }
    
    /// Disables parts of the UI (usually to prevent accidental inputs during background tasks)
    private func disableUI() {
        
        self.searchBar.isEnabled = false
        self.btnRandomTopic.isEnabled = false
        self.vTopicScroller.isUserInteractionEnabled = false
        self.vTopicScroller.alpha = 0.7
    }
    
    /// Enables the UI
    private func enableUI() {
        
        DispatchQueue.main.async {
            self.searchBar.isEnabled = true
            self.aiv.isHidden = true
            self.btnRandomTopic.isEnabled = true
            self.btnRandomTopic.isHidden = false
            self.tview.isUserInteractionEnabled = true
            self.tview.alpha = 1
            self.vLoadingTopic.layer.removeAllAnimations()
            self.vLoadingTopic.transform = .identity
            self.vLoadingTopic.isHidden = true
            self.vTopicScroller.isUserInteractionEnabled = true
            self.vTopicScroller.alpha = 1
        }
    }
    
    /// Pads out a string by adding a space after every character (used for the topic title)
    private func getPaddedString(_ input:String) -> String {
        
        guard !input.isEmpty else { return input }
        var str = ""
        // loop over every character
        for (idx, char) in input.enumerated() {
            str += String(char)
            if (idx < input.count - 1) { str += " " }
        }
        return str
    }
    
    /// Starts running a new search with the given parameters
    private func startNewSearch(_ text: String) {
        // start this search
        disableUI()
        btnRandomTopic.isHidden = true
        aiv.isHidden = false
        tview.isUserInteractionEnabled = false
        tview.alpha = 0.7
        showLoadingPopup()
        Task { await fetchFeed(keywords: text) }
    }
    
    /// Picks a random feed topic
    @IBAction func tapRandomTopic() {
        
        // make sure this isn't the last-performed search (ignore if this is the case)
        let kw = RandomTopic.getRandomTopic().lowercased()
        if (kw.elementsEqual(lastSearch)) { return }
        
        // start this search
        startNewSearch(kw)
    }
    
    /// User taps an item in the topic links bar
    @IBAction func tapTopicLink(_ sender: Any) {
        // get a reference to the button's label
        guard let btn = sender as? UIButton else { return }
        guard let topic = btn.titleLabel?.text, !topic.isEmpty else { return }
        
        // start this search
        startNewSearch(topic)
    }
    
    /// User taps the info button
    @IBAction func tapAbout() {
        
        // set up a new instance of the about view
        guard let sb = storyboard, let vc = sb.instantiateViewController(withIdentifier: "aboutView") as? AboutView else {
            return
        }
        
        // configure
        vc.modalPresentationStyle = .formSheet
        vc.sheetPresentationController?.detents = [.large()]
        
        // show
        present(vc, animated: true)
    }
    
    /// Displays the 'loading content' overlay with a springy scaling effect
    private func showLoadingPopup() {
        
        // scale the view to zero first
        vLoadingTopic.transform = CGAffineTransform(scaleX: 0, y: 0)
        vLoadingTopic.isHidden = false
        
        // animate with a spring curve
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, animations: {
            self.vLoadingTopic.transform = .identity
        }, completion: nil)
    }
    
    /// Override layoutSubviews to add our table gradient / masking effect
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        // set up a gradient to use for our table viewmask
        let grad = CAGradientLayer()
        grad.frame = vTableContainer.bounds
        grad.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        grad.locations = [0.0, 0.9, 1.0]
        
        // add the mask
        vTableContainer.layer.mask = grad
        
        // set up a gradient to use for our topics bar mask
        let gradTopics = CAGradientLayer()
        gradTopics.frame = vTopicScroller.bounds
        gradTopics.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradTopics.startPoint = CGPoint(x: 0.9, y: 0)
        gradTopics.endPoint = CGPoint(x: 1, y: 0)
        
        // add the mask
        vTopicScroller.layer.mask = gradTopics
    }
    
    /// Respond to trait changes (to pick up changes between light/dark modes)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            traitAppearanceUpdated()
        }
    }
    
    /// The trait appearance changed since launch, so update any parts of the UI that need it
    private func traitAppearanceUpdated() {
        
        // update the loading topic border
        vLoadingTopic.layer.borderColor = UIColor.label.withAlphaComponent(0.2).cgColor
        vLoadingTopic.layer.borderWidth = 1
    }
}

/// Extension for UITableView delegates
extension HomeView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return lastResults?.collection?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }
        
        // prepare the cell data and ensure it's within bounds
        guard let items = lastResults?.collection?.items, indexPath.row < items.count else {
            return UITableViewCell()
        }
        
        // pass the cell the data it needs to layout
        cell.loadData(items[indexPath.row], inputDateFormatter: inputDateFormatter, outputDateFormatter: outputDateFormatter, indexPath: indexPath, tableView: tview)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // get the data for this new view
        guard let items = lastResults?.collection?.items, indexPath.row < items.count,
                let item = items[indexPath.row] as NASAFeedItem? else {
            return
        }
        
        // set up a new instance of the detail view
        guard let sb = storyboard, let vc = sb.instantiateViewController(withIdentifier: "detailView") as? DetailView else {
            return
        }
        
        // configure
        vc.modalPresentationStyle = .formSheet
        vc.sheetPresentationController?.detents = [.large()]
        vc.feedItem = item
        
        // show
        present(vc, animated: true)
    }
}

/// Extensiont to handle search bar delegates
extension HomeView: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // close the keyboard
        searchBar.resignFirstResponder()
        
        // determine if we should run a search, or show an alert
        guard let txt = searchBar.text, txt.count >= 3 else {
            UIAlertController.show(parent: self, title: "Try again!", message: "Please enter at least 3 characters for your keywords")
            return
        }
        
        // make sure this isn't the last-performed search (ignore if this is the case)
        let kw = txt.lowercased()
        if (kw.elementsEqual(lastSearch)) { return }
        
        // start this search
        disableUI()
        Task { await fetchFeed(keywords: kw) }
    }
}

/// Convenience extensions for UIView
extension UIView {
    /// Adds a shadow to this view
    func addShadow(size: CGFloat, opacity: CGFloat, offset: CGFloat) {
        layer.shadowOffset = CGSize(width: 0, height: offset)
        layer.shadowOpacity = Float(opacity)
        layer.shadowRadius = size
        layer.shadowColor = UIColor.black.cgColor
    }
}

