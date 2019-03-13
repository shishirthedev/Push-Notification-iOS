//
//  ViewController.swift
//  PushNotificationiOS
//
//  Created by Developer Shishir on 3/8/19.
//  Copyright © 2019 Shishir's App Studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

