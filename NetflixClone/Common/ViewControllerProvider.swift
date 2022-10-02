//
//  ViewControllerProvider.swift
//  NetflixClone
//
//  Created by Assem on 01/10/2022.
//

import UIKit

struct ViewControllerProvider {
    private init() {}
    

     static func navigateToTitlePreviewVC(with ViewModel: TitlePreviewViewModel, randomTrendingMovie: Title) ->  TitlePreviewViewController {
        let vc = TitlePreviewViewController()
        vc.configure(with: ViewModel)
        let TitlePreviewViewModel = TitlePreviewViewModell(randomTrendingMovie: randomTrendingMovie)
        vc.viewModel = TitlePreviewViewModel
        return vc
    }


}
