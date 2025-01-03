//
//  RandomTopic.swift
//  InSpace
//
//  Created by Andy Copsey on 02/01/2025.
//

import Foundation

/// Encapsulates a list of available random space-themed topics
class RandomTopic {
    
    /// Returns a random keyword string
    public static func getRandomTopic() -> String {
        let topics = ["saturn", "neptune", "mercury", "mars", "earth", "uranus", "pluto", "venus", "jupiter", "kuiper", "asteroid", "comet", "nebula", "galaxy", "stars", "jpl", "nasa", "astronaut", "cosmonaut", "isp", "administration", "grc-atf", "grc", "facility", "orion", "webb", "hubble", "rover", "terrain", "artemis", "lunar", "moon", "titan", "space", "planet", "distant", "mountains", "oceans", "clouds", "plume", "sun", "solar", "corona", "wide-field", "telescope", "reflector", "spacecraft", "lander", "iss", "station", "crew", "orbiter", "orbit", "satellite"]
        return topics.randomElement() ?? "space"
    }
}
