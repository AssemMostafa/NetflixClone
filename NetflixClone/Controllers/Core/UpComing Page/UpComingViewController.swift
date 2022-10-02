//
//  UpComingViewController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

class UpComingViewController: UIViewController {

    // MARK: Properties and outlets

    private var viewModel = UpComingViewModel()
    private let upComingTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upComingTable.frame = view.bounds
    }

    // MARK: Helper Methods
    private func setupView() {
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        view.addSubview(upComingTable)
        upComingTable.dataSource = self
        upComingTable.delegate = self
        upComingTable.prefetchDataSource = self
        upComingTable.isPrefetchingEnabled = true
    }

    private func setupViewModel() {
        viewModel.titles.onUpdate = { [weak self] _ in
            self?.upComingTable.reloadData()
        }
        viewModel.errorHandler.onUpdate = { [weak self] _ in
            guard let error = self?.viewModel.errorHandler.value else {return}
            self?.showAlertmessage(with: error)
        }

        viewModel.isLoading = true
        viewModel.fetchUpcoming(currentPage: viewModel.currentpage)
    }

    private func navigateToTitlePreviewVC(with ViewModel: TitlePreviewViewModel, titleModel: Title) {
        let vc = ViewControllerProvider.navigateToTitlePreviewVC(with: ViewModel, randomTrendingMovie: titleModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: TableView DataSource and Delegate
extension UpComingViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row >= viewModel.titles.value.count - 3, viewModel.currentpage < viewModel.totalpages, viewModel.currentpage != viewModel.totalpages, !viewModel.isLoading {
                viewModel.currentpage += 1
                viewModel.fetchUpcoming(currentPage: viewModel.currentpage)
            }
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.titles.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = viewModel.titles.value[indexPath.row]
        cell.configure(with: TitleViewModel(posterURL: viewModel.poster_path, titleName: viewModel.original_title ?? "Unknown"))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = viewModel.titles.value[indexPath.row]
        guard let titleName = title.original_title else {
            return
        }
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                guard let strongSelf = self else {return}
                guard let titleOverview = title.overview else {return}
                let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverView: titleOverview)
                DispatchQueue.main.async {
                    strongSelf.navigateToTitlePreviewVC(with: viewModel, titleModel: title)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlertmessage(with: error.localizedDescription)
                }
            }
        }
    }
}
