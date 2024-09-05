//
//  GithubConnector.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/5.
//

import Foundation

class GithubConnector {
    static func getUserAccessToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://github.com/login/oauth/access_token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
        let parameters = "client_id=\(AppConstants.GitHost.clientID)&client_secret=\(AppConstants.GitHost.clientSecret)&code=\(code)&redirect_uri=\(AppConstants.GitHost.redirectURI)"
            request.httpBody = parameters.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "GitHubAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                    return
                }
                do {
                           let tokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                           completion(.success(tokenResponse.access_token))
                       } catch {
                           completion(.failure(error))
                       }
                   }
                   
                   task.resume()
    }
    
    static func getUserInfo(accessToken:String, completion: @escaping (Result<GitHubUser, Error>) -> Void) {
        let url = URL(string: "https://api.github.com/user")!
        var request = URLRequest(url: url)
        request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "GitHubAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(GitHubUser.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
}
