//
//  CategoryDetailController.swift
//  github-client
//
//  Created by godmanzheng on 2024/9/4.
//

import Foundation
import UIKit

class CategoryDetailController: UIViewController {
    var detailInfo: String = "";
    @IBOutlet var label:UILabel!;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red;
        self.label.text = self.detailInfo;
    }
}
