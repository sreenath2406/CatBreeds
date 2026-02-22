// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation

struct CatBreed: Decodable {
    let id: String?
    let name: String?
    let description: String?
    let temperament: String?
    let origin: String?
    let countryCodes: String?
    let lifeSpan: String?
    let wikipediaUrl: String?
    let referenceImageId: String?
    let image: CatImage?

    // Boolean traits — the API sends 0 or 1, not a real Bool.
    let experimental: Int?
    let hairless: Int?
    let indoor: Int?
    let lap: Int?
    let hypoallergenic: Int?
    let rare: Int?
    let natural: Int?

    // Characteristic ratings on a 1–5 scale.
    let adaptability: Int?
    let affectionLevel: Int?
    let childFriendly: Int?
    let dogFriendly: Int?
    let energyLevel: Int?
    let grooming: Int?
    let healthIssues: Int?
    let intelligence: Int?
    let sheddingLevel: Int?
    let socialNeeds: Int?
    let strangerFriendly: Int?
    let vocalisation: Int?

    struct CatImage: Decodable {
        let id: String?
        let width: Int?
        let height: Int?
        let url: String?
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, temperament, origin
        case countryCodes       = "country_codes"
        case lifeSpan           = "life_span"
        case wikipediaUrl       = "wikipedia_url"
        case referenceImageId   = "reference_image_id"
        case image
        case experimental, hairless, indoor, lap, hypoallergenic, rare, natural
        case adaptability
        case affectionLevel     = "affection_level"
        case childFriendly      = "child_friendly"
        case dogFriendly        = "dog_friendly"
        case energyLevel        = "energy_level"
        case grooming
        case healthIssues       = "health_issues"
        case intelligence
        case sheddingLevel      = "shedding_level"
        case socialNeeds        = "social_needs"
        case strangerFriendly   = "stranger_friendly"
        case vocalisation
    }
}

struct CatDetails: Decodable {
    let breeds: [CatBreedDetails]?
    let url: String?

    struct CatBreedDetails: Decodable {
        let id: String?
        let name: String?
        let temperament: String?
    }
}
