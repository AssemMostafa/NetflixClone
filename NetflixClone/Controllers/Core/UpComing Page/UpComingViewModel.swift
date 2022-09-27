//
//  UpComingViewModel.swift
//  NetflixClone
//
//  Created by Assem on 27/09/2022.
//

import Foundation

class UpComingViewModel {

    var titles: Variable<[Title]> = Variable([])
    var errorHandler: Variable<String> = Variable("")

    // MARK: Pagination
    var isLoading = false
     var currentpage: Int = 1
     var lastpage: Int = 1
     var totalpages: Int = 1


     func fetchUpcoming(currentPage: Int) {
        APICaller.shared.getUpcomingMovies(currentPage: currentPage) { [weak self] result in
            switch result {
            case.success(let response):
                self?.isLoading = false
                self?.totalpages = response.total_pages
                if self?.currentpage != 1 {
                    self?.titles.value += response.results
                } else {
                    self?.titles.value = response.results
                }
            case .failure(let error):
                self?.errorHandler.value = error.localizedDescription
            }
        }
    }
}
