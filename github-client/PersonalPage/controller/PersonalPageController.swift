//
//  PersonalPageController.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/4.
//

import Foundation
import UIKit
import SafariServices

class PersonalPageController: UIViewController {

    var vc: SFSafariViewController? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(receive(noti:)), name: NSNotification.Name(AppConstants.Local.loginSuccessNotification), object: nil);
    }
    
    @IBAction func clickLoginButton(button:UIButton) {
        let loginURL = URL(string:"\(AppConstants.GitHost.oauthURI)?client_id=\( AppConstants.GitHost.clientID)&redirect_uri=\(AppConstants.GitHost.redirectURI)&scope=\(AppConstants.GitHost.scope)")!
        let safariVC = SFSafariViewController(url: loginURL)
            present(safariVC, animated: true, completion: nil)
  
        self.vc = safariVC
    }
    
    @objc func receive(noti:Notification) {
        if let code = noti.userInfo?["code"] as? String {
            if let safariVC = self.vc {
                safariVC.dismiss(animated: true);
                getUserAccessToken(code: code) {result in
                    switch result {
                        case .success(let accessToken):
                            print("Access Token: \(accessToken)")
                        self.getUserInfo(accessToken: accessToken) {result in
                                switch result {
                                case .success(let user):
                                    print("User info: \(user)")
                                case .failure(let error):
                                    print("Error fetching user info: \(error)")
                            }
                        }
                        case .failure(let error):
                            print("Error fetching access token: \(error)")
                        }
                }
            }
        }
    }
    
    func getUserInfo(accessToken:String, completion: @escaping (Result<GitHubUser, Error>) -> Void) {
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
    
    func getUserAccessToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
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

}
