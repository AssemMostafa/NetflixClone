//
//  DownloadsViewController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

class DownloadsViewController: UIViewController {

    private var titles = [TitleItem]()

    private let downloadedTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchLocalStorageForDownload()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadedTable.frame = view.bounds
    }

    private func setupView() {
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        view.addSubview(downloadedTable)
        downloadedTable.dataSource = self
        downloadedTable.delegate = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name("downloaded"), object: nil, queue: nil) { _ in
            self.fetchLocalStorageForDownload()
        }
    }

    private func navigateToTitlePreviewVC(with ViewModel: TitlePreviewViewModel) {
        let vc = TitlePreviewViewController()
        vc.configure(with: ViewModel)
        vc.isCameFromDownloads = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func fetchLocalStorageForDownload() {
        DataPersistenceManger.shared.fetchingTitlesFromDataBase { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.updateTabBar(with: titles.count)
                    self?.downloadedTable.reloadData()
                }
            case .failure(let error) :
                print(error)
            }
        }
    }

    private func updateTabBar(with count: Int) {
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[3]
            tabItem.badgeValue = "\(count)"
        }
    }

}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {

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
                    strongSelf.navigateToTitlePreviewVC(with: viewModel)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            DataPersistenceManger.shared.deleteTitle(with: titles[indexPath.row]) { [weak self]  result in
                switch result {
                case .success() :
                    self?.titles.remove(at: indexPath.row)
                    self?.updateTabBar(with: self?.titles.count ?? 0)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error) :
                    print(error)
                }
            }
        default:
            break
        }
    }
}
