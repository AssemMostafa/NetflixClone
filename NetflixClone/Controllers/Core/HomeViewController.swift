//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTV = 1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4

}
class HomeViewController: UIViewController {

    // MARK: Properties and outlets

    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderView?

    let sectionTitles: [String] = ["Trending Movies","Popular" , "Trending Tv","Upcoming Movies" , "Top rated"]
    private let homeFeedTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: Helper Methods
    func setupView() {
        self.view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTableView)
        homeFeedTableView.delegate = self
        homeFeedTableView.dataSource = self
        headerView = HeroHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        homeFeedTableView.tableHeaderView = headerView
        configerNavBar()
        configureHeroHeader()
        fetchLocalStorageForDownload()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTableView.frame = view.bounds
    }

    private func configureHeroHeader() {
        APICaller.shared.getTrendingMovies { [weak self] result in
            switch result {
            case.success(let titles):
                let selectedTitle = titles.randomElement()
                self?.randomTrendingMovie = selectedTitle
                DispatchQueue.main.async {
                    self?.headerView?.delegate = self
                    self?.headerView?.configure(with: TitleViewModel(posterURL: selectedTitle?.poster_path, titleName: selectedTitle?.original_title ?? ""))
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func configerNavBar() {
        var image = UIImage(named: "NetflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: #selector(profileButtonPressed)),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: #selector(upComingButtonPressed))
        ]
        navigationController?.navigationBar.tintColor = .white
    }

    private func navigateToTitlePreviewVC(with ViewModel: TitlePreviewViewModel) {
        let vc = TitlePreviewViewController()
        vc.configure(with: ViewModel)
        vc.randomTrendingMovie = self.randomTrendingMovie
        navigationController?.pushViewController(vc, animated: true)
    }

    private func updateTabBar(with count: Int) {
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[3]
            tabItem.badgeValue = "\(count)"
        }
    }

    private func downloadTitleAt(viewModel: Title) {
        DataPersistenceManger.shared.downloadTitle(with: viewModel) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil)
            case .failure(let error) :
                print(error)
            }
        }
    }

    private func fetchLocalStorageForDownload() {
        DataPersistenceManger.shared.fetchingTitlesFromDataBase { [weak self] result in
            switch result {
            case .success(let titles):
                DispatchQueue.main.async {
                    self?.updateTabBar(with: titles.count)
                }
            case .failure(let error) :
                print(error)
            }
        }
    }
    // MARK: Actions

    @objc func profileButtonPressed(sender: UIButton!) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "You should login first", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .default) { _ in}
            alert.view.tintColor = .white
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
    }

    @objc func upComingButtonPressed(sender: UIButton!) {
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = 1
        }
    }
}

// MARK: TableView DataSource and Delegate

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        switch indexPath.section {
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { result in
                switch result {
                case.success(let movies):
                    cell.configerCell(with: movies)
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.TrendingTV.rawValue:
            APICaller.shared.getTrendingTvs { result in
                switch result {
                case.success(let tvs):
                    cell.configerCell(with: tvs)
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.Popular.rawValue:
            APICaller.shared.getPopularMovies { result in
                switch result {
                case.success(let movies):
                    cell.configerCell(with: movies)
                case .failure(let error):
                    print(error)
                }
            }

        case Sections.Upcoming.rawValue:
            APICaller.shared.getUpcomingMovies { result in
                switch result {
                case.success(let movies):
                    cell.configerCell(with: movies)
                case .failure(let error):
                    print(error)
                }
            }

        case Sections.TopRated.rawValue:
            APICaller.shared.getTopRatedMovies { result in
                switch result {
                case.success(let movies):
                    cell.configerCell(with: movies)
                case .failure(let error):
                    print(error)
                }
            }
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

// MARK: CollectionViewTableViewCell Delegate

extension HomeViewController: CollectionViewTableViewCellDelegate {
    func CollectionViewTableViewCellDidTapCell(_cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel) {
        DispatchQueue.main.async {
            self.navigateToTitlePreviewVC(with: viewModel)
        }
    }
}

// MARK: HeroHeaderView Delegate

extension HomeViewController: HeroHeaderViewDelegate {
    func userDidTapOnPlayButton() {
        guard let titleName = randomTrendingMovie?.original_title else {
            return
        }
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                guard let strongSelf = self else {return}
                guard let titleOverview = self?.randomTrendingMovie?.overview else {return}
                let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverView: titleOverview)
                DispatchQueue.main.async {
                    strongSelf.navigateToTitlePreviewVC(with: viewModel)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func userDidTapOnDownloadButton() {
        guard let title = randomTrendingMovie, let _ = randomTrendingMovie?.original_title else {
            return
        }
        downloadTitleAt(viewModel: title)
    }
}
