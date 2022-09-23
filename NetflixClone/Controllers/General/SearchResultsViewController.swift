//
//  SearchResultsViewController.swift
//  NetflixClone
//
//  Created by Assem on 22/09/2022.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func SearchResultsViewControllerDidTapItem(_ ViewModel: TitlePreviewViewModel, titleModel: Title)
}

class SearchResultsViewController: UIViewController {

    public var titles = [Title]()
    weak var delegate: SearchResultsViewControllerDelegate?
    public let searchResultcollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 10, height: 200)
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultcollectionView.frame = view.bounds
    }
    func setupView() {
        view.addSubview(searchResultcollectionView)
        searchResultcollectionView.delegate = self
        searchResultcollectionView.dataSource = self
//        navigationController?.navigationBar.barTintColor = .white
    }
}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let model = titles[indexPath.row].poster_path {
            cell.configure(with: model)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let title = titles[indexPath.row]
        guard let titleName = title.original_title else {return}
        guard let titleOverview = title.overview else {return}
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                guard let strongSelf = self else {return}
                let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverView: titleOverview)
                strongSelf.delegate?.SearchResultsViewControllerDidTapItem(viewModel, titleModel: title)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlertmessage(with: error.localizedDescription)
                }
            }
        }
    }
}
