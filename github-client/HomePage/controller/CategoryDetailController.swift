//
//  CategoryDetailController.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/4.
//

import Foundation
import UIKit

class CategoryDetailController: UIViewController {
    var detailInfo: Repository? = nil;
    
    @IBOutlet var titleLabel:UILabel!;
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var urlLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.titleLabel.text = self.detailInfo?.fullName
        self.detailLabel.text = self.detailInfo?.description
        self.urlLabel.text = self.detailInfo?.url
    }
}
