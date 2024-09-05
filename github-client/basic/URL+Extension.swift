//
//  URL+Extension.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/5.
//

import Foundation

extension URL {
    var queryParameters: [String: String]? {
        let comps = URLComponents(url: self, resolvingAgainstBaseURL: false)
        return comps?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
