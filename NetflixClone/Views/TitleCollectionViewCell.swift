//
//  TitleCollectionViewCell.swift
//  NetflixClone
//
//  Created by Assem on 21/09/2022.
//

import UIKit

class TitleCollectionViewCell: UICollectionViewCell {

    static let identifier = "TitleCollectionViewCell"

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(posterImageView)
    }
    public func configure(with model: String) {
        let imagUrl = "https://image.tmdb.org/t/p/w500/\(model)"
        posterImageView.loadImageUsingCache(withUrl: imagUrl)
    }
}
