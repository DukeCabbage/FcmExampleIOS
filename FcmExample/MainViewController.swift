//
//  MainViewController.swift
//  FcmExample
//
//  Created by Leo Wang on 2016-07-19.
//  Copyright © 2016 DDS. All rights reserved.
//

import UIKit
import Firebase

class MainViewController : UIViewController {
    
    @IBOutlet weak var labelToken: UILabel!
    @IBAction func printToken(sender: UIButton) {
        if let token = FIRInstanceID.instanceID().token() {
            print("onTokenRefresh: " + token)
            labelToken.text = token
        } else {
            print("token is nil")
            labelToken.text = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
