//
//  StartViewController.swift
//  boatrace
//
//  Created by Daniel Weatrowski on 12/29/19.
//  Copyright © 2019 saddevelopment. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let activityView = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
     func showActivityIndicatory() {
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    // MARK: - Actions
    @IBAction func didTapStartGame() {
        
    }
    @IBAction func didTapJoinGame() {
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        showActivityIndicatory()
    }
    
    

    
    // MARK: - Navigation
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {}

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
