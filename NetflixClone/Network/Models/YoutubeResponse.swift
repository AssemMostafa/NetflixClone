//
//  YoutubeResponse.swift
//  NetflixClone
//
//  Created by Assem on 22/09/2022.
//

import Foundation

struct YoutubeResponse: Codable{
    let items: [VideoElement]
}

struct VideoElement: Codable{
    let id: idVideoElement
}

struct idVideoElement: Codable{
    let videoId: String
    let kind: String

}
