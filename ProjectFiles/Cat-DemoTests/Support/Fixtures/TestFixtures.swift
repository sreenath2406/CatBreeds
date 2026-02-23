//
//  TestFixtures.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import Foundation
@testable import Cat_Demo

enum TestFixtures {
    static func makeBreed(
        id: String? = "abys",
        name: String? = "Abyssinian",
        description: String? = "Friendly cat",
        wikipediaUrl: String? = "https://en.wikipedia.org/wiki/Abyssinian_(cat)"
    ) -> CatBreed {
        CatBreed(
            id: id,
            name: name,
            description: description,
            temperament: "Active",
            origin: "Egypt",
            countryCodes: "EG",
            lifeSpan: "14 - 15",
            wikipediaUrl: wikipediaUrl,
            referenceImageId: "0XYvRd7oD",
            image: nil,
            experimental: 0,
            hairless: 0,
            indoor: 0,
            lap: 1,
            hypoallergenic: 0,
            rare: 0,
            natural: 1,
            adaptability: 5,
            affectionLevel: 5,
            childFriendly: 3,
            dogFriendly: 4,
            energyLevel: 5,
            grooming: 1,
            healthIssues: 2,
            intelligence: 5,
            sheddingLevel: 2,
            socialNeeds: 5,
            strangerFriendly: 5,
            vocalisation: 1
        )
    }

    static func makeCatDetails(url: String = "https://cdn2.thecatapi.com/images/abc.jpg") -> CatDetails {
        CatDetails(
            breeds: [
                CatDetails.CatBreedDetails(
                    id: "abys",
                    name: "Abyssinian",
                    temperament: "Active"
                )
            ],
            url: url
        )
    }

    static func makeImageData() -> Data {
        Data([0xFF, 0xD8, 0xFF, 0xD9])
    }

    static func validBreedsJSONData() -> Data {
        let json = """
        [
          {
            "id": "abys",
            "name": "Abyssinian",
            "description": "Friendly cat",
            "temperament": "Active",
            "origin": "Egypt",
            "country_codes": "EG",
            "life_span": "14 - 15",
            "wikipedia_url": "https://en.wikipedia.org/wiki/Abyssinian_(cat)",
            "reference_image_id": "0XYvRd7oD",
            "adaptability": 5,
            "affection_level": 5,
            "child_friendly": 3,
            "dog_friendly": 4,
            "energy_level": 5,
            "grooming": 1,
            "health_issues": 2,
            "intelligence": 5,
            "shedding_level": 2,
            "social_needs": 5,
            "stranger_friendly": 5,
            "vocalisation": 1,
            "experimental": 0,
            "hairless": 0,
            "indoor": 0,
            "lap": 1,
            "hypoallergenic": 0,
            "rare": 0,
            "natural": 1
          }
        ]
        """
        return Data(json.utf8)
    }

    static func invalidJSONData() -> Data {
        Data("{ invalid json".utf8)
    }
}
