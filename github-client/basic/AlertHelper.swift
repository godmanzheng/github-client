//
//  AlertHelper.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/5.
//

import Foundation
import UIKit

class AlertHelper {
    static func showConfirmAlert(title:String, message:String, presenter: UIViewController) {
        let alert = UIAlertController(title: title,
                            message: message,
                            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:NSLocalizedString("confirm", comment: ""),
                                      style: .default))
        presenter.present(alert, animated: true)
    }
    
}
