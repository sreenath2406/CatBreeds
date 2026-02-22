// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

final class BreedsListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private static let showBreedDetailsSegueIdentifier = "showBreedDetailsSegue"
    private lazy var viewModel: BreedsListViewModel = AppCompositionRoot.shared.makeBreedsListViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No breeds found"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupSearchController()
        setupEmptyStateLabel()

        viewModel.catDataDelegate = self
        viewModel.getBreeds()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Self.showBreedDetailsSegueIdentifier else { return }
        guard let detailsViewController = segue.destination as? BreedDetailsViewController else { return }
        guard let selectedBreed = sender as? CatBreed else { return }

        detailsViewController.viewModel = AppCompositionRoot.shared.makeBreedDetailViewModel(breed: selectedBreed)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        // We show results in the same table
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search breeds"
        navigationItem.searchController = searchController
        // Keep the bar pinned so users can search without scrolling to the top first.
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupEmptyStateLabel() {
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension BreedsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayedBreeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catBreed")
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: "catBreed")

        let breed = viewModel.displayedBreeds[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = breed.name ?? "Unknown"
        content.secondaryText = breed.description ?? ""
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content

        return cell
    }

    // Trigger the next page load when the last visible cell is about to appear.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = viewModel.displayedBreeds.count - 1
        guard indexPath.row == lastRowIndex else { return }
        viewModel.loadNextPage()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBreed = viewModel.displayedBreeds[indexPath.row]
        performSegue(withIdentifier: Self.showBreedDetailsSegueIdentifier, sender: selectedBreed)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - CatDataDelegate

extension BreedsListViewController: CatDataDelegate {
    func viewModelDidUpdateBreeds() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !(viewModel.isSearchActive && viewModel.displayedBreeds.isEmpty)
    }
}

// MARK: - UISearchResultsUpdating

extension BreedsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(query: searchController.searchBar.text ?? "")
    }
}
