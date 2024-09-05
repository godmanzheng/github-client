//
//  GitUserInfo.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/5.
//

import Foundation

struct AccessTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let scope: String
}

struct GitHubUser: Codable {
    let login: String
    let id: Int
    let avatar_url: String
    let name: String?
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let bio: String?
}
