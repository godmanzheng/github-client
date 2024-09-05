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

    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
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
                GithubConnector.getUserAccessToken(code: code) {result in
                    switch result {
                        case .success(let accessToken):
                            print("Access Token: \(accessToken)")
                        GithubConnector.getUserInfo(accessToken: accessToken) {result in
                                switch result {
                                case .success(let user):
                                    print("User info: \(user)")
                                    DispatchQueue.main.async {
                                        self.updateUI(user: user)
                                    }
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
    
    func updateUI(user:GitHubUser) {
        
    }
}
