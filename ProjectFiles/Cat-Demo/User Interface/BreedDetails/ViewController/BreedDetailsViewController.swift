//
//  BreedDetailsViewController.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import UIKit

final class BreedDetailsViewController: UIViewController {
    @IBOutlet private weak var breedImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var temperamentLabel: UILabel!
    @IBOutlet private weak var lifeSpanLabel: UILabel!
    @IBOutlet private weak var originLabel: UILabel!
    @IBOutlet private weak var wikipediaButton: UIButton!

    @IBOutlet private weak var adaptabilityImageView: UIImageView!
    @IBOutlet private weak var adaptabilityValueLabel: UILabel!
    @IBOutlet private weak var affectionImageView: UIImageView!
    @IBOutlet private weak var affectionValueLabel: UILabel!
    @IBOutlet private weak var childFriendlyImageView: UIImageView!
    @IBOutlet private weak var childFriendlyValueLabel: UILabel!
    @IBOutlet private weak var dogFriendlyImageView: UIImageView!
    @IBOutlet private weak var dogFriendlyValueLabel: UILabel!
    @IBOutlet private weak var energyImageView: UIImageView!
    @IBOutlet private weak var energyValueLabel: UILabel!
    @IBOutlet private weak var groomingImageView: UIImageView!
    @IBOutlet private weak var groomingValueLabel: UILabel!
    @IBOutlet private weak var healthIssuesImageView: UIImageView!
    @IBOutlet private weak var healthIssuesValueLabel: UILabel!
    @IBOutlet private weak var intelligenceImageView: UIImageView!
    @IBOutlet private weak var intelligenceValueLabel: UILabel!
    @IBOutlet private weak var sheddingImageView: UIImageView!
    @IBOutlet private weak var sheddingValueLabel: UILabel!
    @IBOutlet private weak var socialNeedsImageView: UIImageView!
    @IBOutlet private weak var socialNeedsValueLabel: UILabel!
    @IBOutlet private weak var strangerFriendlyImageView: UIImageView!
    @IBOutlet private weak var strangerFriendlyValueLabel: UILabel!
    @IBOutlet private weak var vocalisationImageView: UIImageView!
    @IBOutlet private weak var vocalisationValueLabel: UILabel!

    // Injected by the presenting view controller
    var viewModel: BreedDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard viewModel != nil else {
            assertionFailure("viewModel must be set before pushing BreedDetailsViewController.")
            return
        }

        title = viewModel.breed.name ?? "Breed Details"
        configureImageView()
        populateDetails()
        viewModel.delegate = self
        viewModel.fetchImage()
    }

    private func configureImageView() {
        breedImageView.backgroundColor = .secondarySystemBackground
        breedImageView.contentMode = .scaleAspectFit
        breedImageView.clipsToBounds = true
    }

    private func populateDetails() {
        let breed = viewModel.breed
        nameLabel.text = breed.name ?? "Unknown Breed"
        descriptionLabel.text = breed.description ?? "No description available."
        temperamentLabel.text = "Temperament: \(breed.temperament ?? "Unknown")"
        lifeSpanLabel.text = "Life Span: \(breed.lifeSpan ?? "Unknown")"

        let codes = breed.countryCodes ?? "-"
        originLabel.text = "Origin: \(breed.origin ?? "Unknown") (\(codes))"

        setRating(imageView: adaptabilityImageView,
                  valueLabel: adaptabilityValueLabel,
                  value: breed.adaptability)
        setRating(imageView: affectionImageView,
                  valueLabel: affectionValueLabel,
                  value: breed.affectionLevel)
        setRating(imageView: childFriendlyImageView,
                  valueLabel: childFriendlyValueLabel,
                  value: breed.childFriendly)
        setRating(imageView: dogFriendlyImageView,
                  valueLabel: dogFriendlyValueLabel,
                  value: breed.dogFriendly)
        setRating(imageView: energyImageView,
                  valueLabel: energyValueLabel,
                  value: breed.energyLevel)
        setRating(imageView: groomingImageView,
                  valueLabel: groomingValueLabel,
                  value: breed.grooming)
        setRating(imageView: healthIssuesImageView,
                  valueLabel: healthIssuesValueLabel,
                  value: breed.healthIssues)
        setRating(imageView: intelligenceImageView,
                  valueLabel: intelligenceValueLabel,
                  value: breed.intelligence)
        setRating(imageView: sheddingImageView,
                  valueLabel: sheddingValueLabel,
                  value: breed.sheddingLevel)
        setRating(imageView: socialNeedsImageView,
                  valueLabel: socialNeedsValueLabel,
                  value: breed.socialNeeds)
        setRating(imageView: strangerFriendlyImageView,
                  valueLabel: strangerFriendlyValueLabel,
                  value: breed.strangerFriendly)
        setRating(imageView: vocalisationImageView,
                  valueLabel: vocalisationValueLabel,
                  value: breed.vocalisation)

        let linkAvailable = viewModel.wikipediaURL != nil
        wikipediaButton.isHidden = false
        wikipediaButton.isEnabled = linkAvailable
        wikipediaButton.alpha = linkAvailable ? 1.0 : 0.5
        wikipediaButton.setTitle(linkAvailable ? "Read More on Wikipedia" : "Wikipedia link unavailable", for: .normal)
    }

    private func setRating(imageView: UIImageView, valueLabel: UILabel, value: Int?) {
        imageView.image = viewModel.ratingImageName(for: value).flatMap { UIImage(named: $0) }
        valueLabel.text = viewModel.ratingText(for: value)
    }

    @IBAction private func readMoreTapped(_ sender: UIButton) {
        guard let url = viewModel.wikipediaURL else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - BreedDetailViewModelDelegate

extension BreedDetailsViewController: BreedDetailViewModelDelegate {
    func viewModelDidStartImageFetch() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func viewModelDidFetchImage(imageData: Data) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        // Fall back to the system placeholder if decoding fails for some reason.
        breedImageView.image = UIImage(data: imageData) ?? UIImage(systemName: "photo")
    }

    func viewModelDidFailImageFetch(error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        breedImageView.image = UIImage(systemName: "photo")
        print(error.localizedDescription)
    }
}
