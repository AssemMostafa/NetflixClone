//
//  DownloadsViewModel.swift
//  NetflixClone
//
//  Created by Assem on 27/09/2022.
//

import Foundation

class DownloadsViewModel {
     var titles: Variable<[TitleItem]> = Variable([])
    var errorHandler: Variable<String?> = Variable(nil)
    var didRemove: Variable<IndexPath?> = Variable(nil)


     func fetchLocalStorageForDownload() {
        DataPersistenceManger.shared.fetchingTitlesFromDataBase { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles.value = titles
            case .failure(let error) :
                print(error)
                self?.errorHandler.value = error.localizedDescription
            }
        }
    }


    func deleteLocalStorageForDownload(with title: TitleItem, indexPath: IndexPath) {
        DataPersistenceManger.shared.deleteTitle(with: title) { [weak self]  result in
            switch result {
            case .success() :
                self?.didRemove.value = indexPath
//                self?.fetchLocalStorageForDownload()
            case .failure(let error) :
                print(error)
            }
        }
   }

}
