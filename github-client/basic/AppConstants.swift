//
//  AppConstant.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/5.
//

import Foundation

struct AppConstants {
    struct GitHost {
        //client parameter
        static let clientID = "Iv23liySobZVupjKsBxU"
        static let clientSecret = "43c3f35b64b46f92b5e0f1244a9317d47851ac41"
        static let repositionUrl = "https://api.github.com/repositories"
        
        //URI
        static let tokenURI = "https://github.com/login/oauth/access_token"
        static let oauthURI = "https://github.com/login/oauth/authorize"
        static let logoutURI = "https://api.github.com/applications/\(clientID)/token"
        static let redirectURI = "github-client://callback"
        static let userInfoURI = "https://api.github.com/user"
        static let accessTokenURI = "https://github.com/login/oauth/access_token"
        
        //settings
        static let scope = "user, repo"
    }
    
    struct Local {
        static let loginSuccessNotification = "LoginSuccessNotification"
        static let keychainAccessTokenKey = "GitHubAccessToken"
        static let keychainUserNameKey = "GitHubUserName"
    }
    
}
