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
    
    var vc: SFSafariViewController? = nil
    var loggedIn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, 
                                selector: #selector(receive(noti:)),
                                name: NSNotification.Name(AppConstants.Local.loginSuccessNotification),
                                object: nil);
        self.logButton.titleLabel?.text = NSLocalizedString("login", comment: "")
    }
    
    @IBAction func clickLoginButton(button:UIButton) {
        if (!self.loggedIn) {
            let loginURL = URL(string:"\(AppConstants.GitHost.oauthURI)?client_id=\( AppConstants.GitHost.clientID)&redirect_uri=\(AppConstants.GitHost.redirectURI)&scope=\(AppConstants.GitHost.scope)")!
            
            let safariVC = SFSafariViewController(url: loginURL)
            present(safariVC, animated: true, completion: nil)
            self.vc = safariVC
            
        } else {
            
            print("logging out...")
            GithubConnector.logout()
            self.iconImageView.image = UIImage(named: "header")
            self.nameLabel.text = NSLocalizedString("unlogin", comment: "")
            self.loggedIn = false;
        }
    }
    
    @objc func receive(noti:Notification) {
        
        guard let code = noti.userInfo?["code"] as? String else {return}
        guard let safariVC = self.vc else {return}
        
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
                                    self.updateState(user: user)
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
    
    func updateState(user:GitHubUser) {
        self.nameLabel.text = user.login;
        self.logButton.titleLabel?.text = NSLocalizedString("logout", comment: "")
        self.loggedIn = true;
        if let url = URL(string: user.avatar_url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.iconImageView.image = image
                    }
                }
            }.resume()
        }
    }
}
