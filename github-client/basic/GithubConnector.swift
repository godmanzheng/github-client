//
//  GithubConnector.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/5.
//

import Foundation

class GithubConnector {
    static func fetchGitHubRepositories(completion: @escaping (Result<[Repository], Error>) -> Void) {
        let url = URL(string: AppConstants.GitHost.repositionUrl)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let repositories = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let repos = repositories.compactMap(Repository.init)
                    completion(.success(repos))
                }
            } catch {
                print(error)
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func getUserAccessToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: AppConstants.GitHost.accessTokenURI)!
        var request = URLRequest(url: url)
        let parameters = "client_id=\(AppConstants.GitHost.clientID)&client_secret=\(AppConstants.GitHost.clientSecret)&code=\(code)&redirect_uri=\(AppConstants.GitHost.redirectURI)"
        
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = parameters.data(using: .utf8)
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "GitHubAPI", 
                                  code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No data received"])
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
        let url = URL(string: AppConstants.GitHost.userInfoURI)!
        var request = URLRequest(url: url)
        request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "GitHubAPI", 
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(GitHubUser.self, from: data)
                KeychainService.shared.save(key: AppConstants.Local.keychainAccessTokenKey, 
                                    data: accessToken.data(using: .utf8)!)
                KeychainService.shared.save(key: AppConstants.Local.keychainUserNameKey, 
                                    data: user.login.data(using: .utf8)!)
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
       
        revokeAccessToken(clientID: AppConstants.GitHost.clientID, 
                          clientSecret: AppConstants.GitHost.clientSecret,
                          accessToken:tokenStr) { result in
            switch result {
                case .success():
                    print("logout success")
                case .failure(let error):
                    print("logout fail \(error)")
            }
        }
    }
    
    static func revokeAccessToken(clientID: String, 
                        clientSecret: String,
                        accessToken: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: AppConstants.GitHost.logoutURI)!
        var request = URLRequest(url: url)
        let credentials = "\(clientID):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
        let parameters: [String: Any] = ["access_token": accessToken]
        
        request.httpMethod = "DELETE"
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                let error = NSError(domain: "GitHubAPI", 
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to revoke access token"])
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }
}
