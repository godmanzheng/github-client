//
//  PersonalPageController.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/4.
//

import Foundation
import UIKit
import SafariServices
import SDWebImage
import LocalAuthentication

class PersonalPageController: UIViewController {

    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var vc: SFSafariViewController? = nil
    var loggedIn: Bool = false
    
    //lifecycle function
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, 
                                selector: #selector(receive(noti:)),
                                name: NSNotification.Name(AppConstants.Local.loginSuccessNotification),
                                object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let title = self.loggedIn ?
                    NSLocalizedString("logout", comment: ""):
                    NSLocalizedString("login", comment: "")
        
        self.logButton.setTitle(title, for: .normal)
    }
    
    //UI action handle
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
            self.nameLabel.text = NSLocalizedString("notLogin", comment: "")
            self.logButton .setTitle(NSLocalizedString("login", comment: ""), for: .normal)
            self.loggedIn = false;
        }
    }
        
    @IBAction func clickFaceIDLogin(_ sender: Any) {
        self.authenticateUser()
        
    }
    
    //inner logic handle
    @objc func receive(noti:Notification) {
        guard let code = noti.userInfo?["code"] as? String else {return}
        guard let safariVC = self.vc else {return}
        
        safariVC.dismiss(animated: true);
        GithubConnector.getUserAccessToken(code: code) {result in
            switch result {
                case .success(let accessToken):
                    print("Access Token: \(accessToken)")
                    self.getUserDetailInfo(accessToken: accessToken)
                case .failure(let error):
                    print("Error fetching access token: \(error)")
            }
        }
    }
    
    func getUserDetailInfo(accessToken: String) {
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
    }
    
    func updateState(user:GitHubUser) {
        self.nameLabel.text = user.login;
        self.logButton.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
        self.loggedIn = true;
        
        if let imageURL = URL(string: user.avatar_url) {
            self.iconImageView.sd_setImage(with: imageURL,
                                    placeholderImage: UIImage(named: "haeder"),
                                    context: nil)
        }
    }
    
    func authenticateUser() {
          let context = LAContext()
          var error: NSError?
          
          // check whether device support Biometrics first
          if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
              let reason = NSLocalizedString("tipFaceIDLogin", comment: "")
              
              context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                  DispatchQueue.main.async {
                      if success {
                          self.loginWithFaceID()
                      } else {
                          self.alertFaceIDCheckFail()
                      }
                  }
              }
          } else {
              self.alertFaceIDUnsupported()
          }
      }
    
    func alertFaceIDCheckFail() {
        let confirmFailStr = NSLocalizedString("confirmFail", comment: "")
        let confirmFailReason = NSLocalizedString("confirmFailReason", comment: "")
        
        AlertHelper.showConfirmAlert(title: confirmFailStr,
                            message: confirmFailReason,
                            presenter: self)
    }
    
    func alertFaceIDUnsupported() {
        let unavailableTitle = NSLocalizedString("FaceIDUnavailable", comment: "")
        let unavailabelReason = NSLocalizedString("FaceIDNotSupport", comment: "")
        AlertHelper.showConfirmAlert(title: unavailableTitle,
                        message: unavailabelReason,
                        presenter: self)
    }
    
    func loginWithFaceID() {
        if let data = KeychainService.shared.load(key: AppConstants.Local.keychainAccessTokenKey),
          let accessToken = String(data: data, encoding: .utf8) {
            self.getUserDetailInfo(accessToken: accessToken)
        } else {
            let title = NSLocalizedString("notLoginState", comment: "")
            let message = NSLocalizedString("pleaseLoginFirst", comment: "")
            AlertHelper.showConfirmAlert(title: title, message: message, presenter: self)
        }
    }
}
