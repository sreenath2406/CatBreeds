// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    private lazy var viewModel = AppCompositionRoot.shared.makeBreedsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88

        viewModel.catDataDelegate = self
        viewModel.getBreeds()
    }
}

// MARK: -
// MARK: TableView Delegate Methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {
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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = viewModel.catBreeds.count - 1
        guard indexPath.row == lastRowIndex else { return }
        viewModel.loadNextPage()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        let cat = viewModel.catBreeds[indexPath.row]
        guard let catId = cat.id else {
            return
        }

        viewModel.getCatImage(breedId: catId)
    }
}

// MARK: - CatDataDelegate

extension ViewController: CatDataDelegate {
    /// Called on the main thread after the breeds list is updated.
    func viewModelDidUpdateBreeds() {
        tableView.reloadData()
    }

    /// Called on the main thread after a cat image is fetched.
    func viewModelDidFetchImage() {
        guard let row = tableView.indexPathForSelectedRow?.row else { return }

        let cat = viewModel.catBreeds[row]

        let alert = UIAlertController(title: cat.name, message: nil, preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10.0, y: 50.0, width: 225, height: 225))
        imageView.contentMode = .scaleAspectFit
        imageView.image = viewModel.catImage

        alert.view.addSubview(imageView)

        let height = NSLayoutConstraint(item: alert.view!,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1,
                                        constant: 320)
        let width = NSLayoutConstraint(item: alert.view!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: 250)

        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            alert.dismiss(animated: true)
            self?.tableView.reloadData()
        })

        present(alert, animated: true)
    }
}
