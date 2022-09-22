//
//  SearchViewController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

 
class SearchViewController: UIViewController {

    private var titles = [Title]()

    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a Movie or Tv show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()

    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchUpcoming()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }

    private func setupView() {
        title = "Top Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        view.addSubview(discoverTable)
        discoverTable.dataSource = self
        discoverTable.delegate = self
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }

    private func fetchUpcoming() {
        APICaller.shared.getDiscoverMovies { [weak self] result in
            switch result {
            case.success(let movies):
                self?.titles = movies
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func navigateToTitlePreviewVC(with ViewModel: TitlePreviewViewModel, titleModel: Title) {
        let vc = TitlePreviewViewController()
        vc.configure(with: ViewModel)
        vc.randomTrendingMovie = titleModel
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = titles[indexPath.row]
        cell.configure(with: TitleViewModel(posterURL: viewModel.poster_path, titleName: viewModel.original_title ?? "Unknown"))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = titles[indexPath.row]
        guard let titleName = title.original_title else {
            return
        }
        guard let titleOverview = title.overview else {return}
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                guard let strongSelf = self else {return}
                let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverView: titleOverview)
                DispatchQueue.main.async {
                    strongSelf.navigateToTitlePreviewVC(with: viewModel, titleModel: title)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

}

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func SearchResultsViewControllerDidTapItem(_ ViewModel: TitlePreviewViewModel, titleModel: Title) {
        DispatchQueue.main.async {
            self.navigateToTitlePreviewVC(with: ViewModel, titleModel: titleModel)
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
                  return
              }
        resultsController.delegate = self
        APICaller.shared.search(with: query) { result in
            switch result {
            case .success(let titles) :
                resultsController.titles = titles
                DispatchQueue.main.async {
                    resultsController.searchResultcollectionView.reloadData()
                }
            case .failure(let error) :
                print(error)
            }
        }
    }

}
