//
//  ApiConfig.swift
//  NetflixClone
//
//  Created by Assem on 23/09/2022.
//

import Foundation

struct Constants {
    static let API_KEY = "cd900db219608312150c849ef88c2a62"
    static let baseURL = "https://api.themoviedb.org"
    static let YoutubeBaseURL = "https://youtube.googleapis.com/youtube/v3/search?"
    static let YoutubeAPI_KEY = "AIzaSyAFUkTYxSb_ZUex8hoHJtzMppVqzaJ3eq4"
}

enum APIError: Error {
    case faildToGetData
}
