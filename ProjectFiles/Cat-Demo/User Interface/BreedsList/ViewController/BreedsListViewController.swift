// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

final class BreedsListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private static let showBreedDetailsSegueIdentifier = "showBreedDetailsSegue"
    private lazy var viewModel: BreedsListViewModel = AppCompositionRoot.shared.makeBreedsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88

        viewModel.catDataDelegate = self
        viewModel.getBreeds()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Self.showBreedDetailsSegueIdentifier else { return }
        guard let detailsViewController = segue.destination as? BreedDetailsViewController else { return }
        guard let selectedBreed = sender as? CatBreed else { return }

        detailsViewController.viewModel = AppCompositionRoot.shared.makeBreedDetailViewModel(breed: selectedBreed)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension BreedsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.catBreeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catBreed")
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: "catBreed")

        let breed = viewModel.catBreeds[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = breed.name ?? "Unknown"
        content.secondaryText = breed.description ?? ""
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content

        return cell
    }

    // Trigger the next page load when the last visible cell is about to appear.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = viewModel.catBreeds.count - 1
        guard indexPath.row == lastRowIndex else { return }
        viewModel.loadNextPage()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBreed = viewModel.catBreeds[indexPath.row]
        performSegue(withIdentifier: Self.showBreedDetailsSegueIdentifier, sender: selectedBreed)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - CatDataDelegate

extension BreedsListViewController: CatDataDelegate {
    func viewModelDidUpdateBreeds() {
        tableView.reloadData()
    }
}
