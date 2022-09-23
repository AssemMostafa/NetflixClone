//
//  UpComingViewController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

class UpComingViewController: UIViewController {

    // MARK: Properties and outlets

    private var titles = [Title]()

    private let upComingTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchUpcoming()
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
    }

    private func fetchUpcoming() {
        APICaller.shared.getUpcomingMovies { [weak self] result in
            switch result {
            case.success(let movies):
                self?.titles = movies
                DispatchQueue.main.async {
                    self?.upComingTable.reloadData()
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
// MARK: TableView DataSource and Delegate
extension UpComingViewController: UITableViewDelegate, UITableViewDataSource {

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
                print(error)
            }
        }
    }
}
