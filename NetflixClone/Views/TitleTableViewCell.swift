//
//  TitleTableViewCell.swift
//  NetflixClone
//
//  Created by Assem on 22/09/2022.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    static let identifier = "TitleTableViewCell"
    
    private let titlesPosterUiimageView: UIImageView = {
        let image  = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        return image
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()

    private let playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupView() {
        selectionStyle = .none
        contentView.addSubview(titlesPosterUiimageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(playButton)
        applyConstrains()
    }

    private func applyConstrains() {
        let playButtonConstrains = [
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]

        let titlesPosterUiimageViewConstrains = [
            titlesPosterUiimageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titlesPosterUiimageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titlesPosterUiimageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            titlesPosterUiimageView.widthAnchor.constraint(equalToConstant: 100)
        ]
        let titleLabelConstrains = [
            titleLabel.leadingAnchor.constraint(equalTo: titlesPosterUiimageView.trailingAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 250),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(playButtonConstrains)
        NSLayoutConstraint.activate(titleLabelConstrains)
        NSLayoutConstraint.activate(titlesPosterUiimageViewConstrains)

    }

    public func configure(with model: TitleViewModel) {

        guard let url = model.posterURL else {
            return
        }
        let imagUrl = "https://image.tmdb.org/t/p/w500/\(url)"
        titlesPosterUiimageView.loadImageUsingCache(withUrl: imagUrl)
        titleLabel.text = model.titleName
    }
}
