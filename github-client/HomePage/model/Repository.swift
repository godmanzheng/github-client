//
//  Repository.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/4.
//

import Foundation

struct Repository: Decodable {
    let name: String
    let fullName: String
    let description: String
    init?(dictionary: [String: Any]) {
        self.name = (dictionary["name"] as? String) ?? "unknown"
        self.fullName = (dictionary["full_name"] as? String) ?? "unknown"
        self.description = (dictionary["description"] as? String) ?? "unknown"
    }
}
