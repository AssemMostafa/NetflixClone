//
//  Movie.swift
//  NetflixClone
//
//  Created by Assem on 21/09/2022.
//

import Foundation

struct TrendingMovieResponse: Codable{
    let results: [Title]
}

struct Title: Codable {
    let id: Int
    let media_type: String?
    let original_name: String?
    let poster_path: String?
    let vote_average: Double?
    let vote_count: Int?
    let release_date: String?
    let original_title: String?
    let overview: String?
}
