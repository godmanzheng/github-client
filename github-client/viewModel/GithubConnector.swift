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
                KeychainService.shared.save(key: AppConstants.Local.keychainAccessTokenKey, data: accessToken.data(using: .utf8)!)
                KeychainService.shared.save(key: AppConstants.Local.keychainUserNameKey, data: user.login.data(using: .utf8)!)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    static func logout() {
        guard let tokenData = KeychainService.shared.load(key: AppConstants.Local.keychainAccessTokenKey) else {return}
        guard let tokenStr = String(data: tokenData, encoding: .utf8) else { return }
        KeychainService.shared.delete(key: AppConstants.Local.keychainUserNameKey)
        KeychainService.shared.delete(key: AppConstants.Local.keychainAccessTokenKey)
       
        revokeAccessToken(clientID: AppConstants.GitHost.clientID, clientSecret: AppConstants.GitHost.clientSecret, accessToken:tokenStr) { resutl in
        }
    }
    
    static func revokeAccessToken(clientID: String, clientSecret: String, accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: AppConstants.GitHost.logoutURI)!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let credentials = "\(clientID):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = ["access_token": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                let error = NSError(domain: "GitHubAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to revoke access token"])
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
        
        task.resume()
    }

}
