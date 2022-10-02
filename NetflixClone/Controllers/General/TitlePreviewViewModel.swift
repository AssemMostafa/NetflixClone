//
//  TitlePreviewViewModel.swift
//  NetflixClone
//
//  Created by Assem on 01/10/2022.
//

import Foundation

class TitlePreviewViewModell {

    var randomTrendingMovie: Title
    var succesDownloadMovie: Variable<Bool> = Variable(false)
    var errorHandler: Variable<String?> = Variable(nil)

     init (randomTrendingMovie: Title) {
        self.randomTrendingMovie = randomTrendingMovie
    }


    func downloadTitleAt(viewModel: Title) {
        DataPersistenceManger.shared.downloadTitle(with: viewModel) { result in
            switch result {
            case .success():
                self.succesDownloadMovie.value = true
            case .failure(let error) :
                self.errorHandler.value = error.localizedDescription
            }
        }
    }
}
