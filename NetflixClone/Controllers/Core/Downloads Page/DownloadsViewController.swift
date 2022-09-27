//
//  DownloadsViewController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

class DownloadsViewController: UIViewController {

    // MARK: Properties and outlets
    var viewModel = DownloadsViewModel()
    private let downloadedTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = "Your Downloads Are Empty"
        return label
    }()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadedTable.frame = view.bounds
    }
    
    // MARK: Helper Methods
    private func setupView() {
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        view.addSubview(downloadedTable)
        view.addSubview(hintLabel)
        applyConstrains()
        downloadedTable.dataSource = self
        downloadedTable.delegate = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name("downloaded"), object: nil, queue: nil) { _ in
            self.viewModel.fetchLocalStorageForDownload()
        }
    }
    private func setupViewModel() {

        viewModel.titles.onUpdate = { [weak self] _ in
            if  self?.viewModel.titles.value.isEmpty ?? false {
                self?.hintLabel.isHidden = false
                self?.downloadedTable.isHidden = true
            } else {
                self?.hintLabel.isHidden = true
                self?.downloadedTable.isHidden = false
            }
            self?.updateTabBar(with: self?.viewModel.titles.value.count ?? 0)
            self?.downloadedTable.reloadData()
        }
        viewModel.didRemove.onUpdate = { [weak self] index in
            guard let indexPath = index else {return}
            self?.viewModel.titles.value.remove(at: indexPath.row)
            self?.updateTabBar(with: self?.viewModel.titles.value.count ?? 0)
            self?.downloadedTable.deleteRows(at: [indexPath], with: .fade)
            self?.viewModel.fetchLocalStorageForDownload()
        }
        viewModel.errorHandler.onUpdate = { [weak self] _ in
            guard let error  = self?.viewModel.errorHandler.value else {return}
            self?.showAlertmessage(with: error)
        }
        viewModel.fetchLocalStorageForDownload()
    }

    private func applyConstrains() {
        let downloadButtonConstrains = [
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(downloadButtonConstrains)
    }
    
    private func navigateToTitlePreviewVC(with ViewModel: TitlePreviewViewModel) {
        let vc = TitlePreviewViewController()
        vc.configure(with: ViewModel)
        vc.isCameFromDownloads = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateTabBar(with count: Int) {
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[3]
            tabItem.badgeValue = "\(count)"
        }
    }
}

// MARK: TableView DataSource and Delegate
extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {

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
             let titleItem = self.viewModel.titles.value[indexPath.row]
            self.viewModel.deleteLocalStorageForDownload(with: titleItem, indexPath: indexPath)
        default:
            break
        }
    }
}
