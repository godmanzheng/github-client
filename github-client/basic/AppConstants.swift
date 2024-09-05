//
//  AppConstant.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/5.
//

import Foundation

struct AppConstants {
    struct GitHost {
        static let repositionUrl = "https://api.github.com/repositories"
        static let tokenUrl = "https://github.com/login/oauth/access_token"
        static let oauthURI = "https://github.com/login/oauth/authorize"
        static let clientID = "Iv23liySobZVupjKsBxU"
        static let clientSecret = "43c3f35b64b46f92b5e0f1244a9317d47851ac41"
        static let redirectURI = "github-client://callback"
        static let scope = "user, repo"
    }
    
    struct Local {
        static let loginSuccessNotification = "LoginSuccessNotification"
    }
    
}
