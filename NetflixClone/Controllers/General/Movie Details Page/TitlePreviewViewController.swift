//
//  TitlePreviewViewController.swift
//  NetflixClone
//
//  Created by Assem on 22/09/2022.
//

import UIKit
import WebKit

class TitlePreviewViewController: UIViewController {

    // MARK: Properties and outlets
    var isCameFromDownloads = false
    var viewModel: TitlePreviewViewModell!

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private let overViewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()

    private let downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Download", for: . normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
        return button
    }()

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }

    // MARK: Helper Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.barTintColor = .white
        view.addSubview(webView)
        view.addSubview(titleLabel)
        view.addSubview(overViewLabel)
        view.addSubview(downloadButton)
        applyConstrains()
        downloadButton.isHidden = isCameFromDownloads
    }

    private func setupViewModel() {
        viewModel.succesDownloadMovie.onUpdate = { [weak self] _ in
            NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil)
        }
        viewModel.errorHandler.onUpdate = { [weak self] _ in
            guard let error = self?.viewModel.errorHandler.value else {return}
            self?.showAlertmessage(with: error)
        }
    }

    private func applyConstrains() {

        let webViewConstrains = [
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300)
        ]

        let downloadButtonConstrains = [
            downloadButton.topAnchor.constraint(equalTo: overViewLabel.bottomAnchor, constant: 25),
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 140),
            downloadButton.heightAnchor.constraint(equalToConstant: 40)
        ]

        let titleLabelConstrains = [
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ]

        let overViewLabelConstrains = [
            overViewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overViewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overViewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]

        NSLayoutConstraint.activate(webViewConstrains)
        NSLayoutConstraint.activate(downloadButtonConstrains)
        NSLayoutConstraint.activate(titleLabelConstrains)
        NSLayoutConstraint.activate(overViewLabelConstrains)
    }

    func configure(with model: TitlePreviewViewModel) {
        titleLabel.text = model.title
        overViewLabel.text = model.titleOverView
        guard let url = URL(string: "https://www.youtube.com/embed/\(model.youtubeView.id.videoId)") else {return}
        webView.load(URLRequest(url: url))
    }


    // MARK: Actions
    @objc func downloadButtonPressed(sender: UIButton!) {
         let title = self.viewModel.randomTrendingMovie
        self.viewModel.downloadTitleAt(viewModel: title)
    }

}
