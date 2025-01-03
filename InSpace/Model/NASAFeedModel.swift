//
//  NASAFeedModel.swift
//  InSpace
//
//  Created by Andy Copsey on 02/01/2025.
//

import Foundation

/// Defines the container object that holds the search results feed
class NASAFeedContainer: Codable {
    var collection: NASAFeedCollection?
}

/// Defines the container object that holds the search results
class NASAFeedCollection: Codable {
    var items: [NASAFeedItem]?
    var metadata: NASAFeedMetadata?
    var links: [NASAFeedNavLink]?
}

/// Defines a single NASA feed item
class NASAFeedItem: Codable {
    var href: String?               // a path to this item's collection JSON definition
    var data: [NASAItemData]?       // a list of data items relating to this resource
    var links: [NASAItemLink]?      // a list of links relating to this resource
}

/// Defines metadata for a search result
class NASAFeedMetadata: Codable {
    var total_hits: Int?
}

/// Defines a feed navigation link
class NASAFeedNavLink: Codable {
    var rel: String?        // The relative action for this link (e.g. 'next')
    var prompt: String?     // The textual description for this link (.e.g. 'Next')
    var href: String?       // The path to this link's content (a URL)
}

/// Defines specific metadata relating to a feed item
class NASAItemData: Codable {
    var center: String?                 // 'JPL'
    var title: String?                  // 'Jupiter Plume'
    var nasa_id: String?                // 'PIA01518'
    var date_created: String?           // '1999-03-13T14:54:19Z'
    var keywords: [String]?             // ['jupiter', 'voyager']
    var media_type: String?             // 'image'
    var description_508: String?        // 'Jupiter Plume'
    var secondary_creator: String?      // 'NASA/JPL'
    var description: String?            // 'Jupiter Plume'
}

/// Defines a feed item's list of links
class NASAItemLink: Codable {
    var href: String?               // The path to the link item (a URL)
    var rel: String?                // The type of resource this is (e.g. 'preview')
    var render: String?             // How we should present this item (e.g. 'image')
}


