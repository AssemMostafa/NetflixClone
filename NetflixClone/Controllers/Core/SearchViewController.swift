//
//  SearchViewController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

 
class SearchViewController: UIViewController {

    // MARK: Properties and outlets
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

    // MARK: Pagination
    var isLoading = false
     var currentpage: Int = 1
    fileprivate var lastpage: Int = 1
    fileprivate var totalpages: Int = 1

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.isLoading = true
        fetchUpcoming(currentPage: currentpage)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
    
    // MARK: Helper Methods
    private func setupView() {
        title = "Top Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        view.addSubview(discoverTable)
        discoverTable.dataSource = self
        discoverTable.delegate = self
        discoverTable.prefetchDataSource = self
        discoverTable.isPrefetchingEnabled = true
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    private func navigateToTitlePreviewVC(with ViewModel: TitlePreviewViewModel, titleModel: Title) {
        let vc = TitlePreviewViewController()
        vc.configure(with: ViewModel)
        vc.randomTrendingMovie = titleModel
        navigationController?.pushViewController(vc, animated: true)
    }

    private func fetchUpcoming(currentPage: Int) {
        APICaller.shared.getDiscoverMovies(currentPage: currentPage) { [weak self] result in
            switch result {
            case.success(let response):
                self?.isLoading = false
                self?.totalpages = response.total_pages
                if self?.currentpage != 1 {
                    self?.titles += response.results
                } else {
                    self?.titles = response.results
                }
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: TableView DataSource and Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row >= self.titles.count - 3, currentpage < totalpages, currentpage != totalpages, !self.isLoading {
                currentpage += 1
                fetchUpcoming(currentPage: currentpage)
            }
        }
    }

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
// MARK: UISearchResultsUpdating and SearchResultsViewControllerDelegate
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
