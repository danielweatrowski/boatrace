//
//  StartViewController.swift
//  boatrace
//
//  Created by Daniel Weatrowski on 12/29/19.
//  Copyright © 2019 saddevelopment. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class StartViewController: UIViewController {
    
    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let activityView = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.mpcManager.delegate = self
       // appDelegate.mpcManager.browser.startBrowsingForPeers()
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()

        // Do any additional setup after loading the view.
    }
     func showActivityIndicatory() {
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    // MARK: - Actions
    @IBAction func didTapStartGame() {
       // appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        
    }
    @IBAction func didTapJoinGame() {
        showActivityIndicatory()
        appDelegate.mpcManager.browser.startBrowsingForPeers()

    }
    
    

    
    // MARK: - Navigation
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {
        // begin browsing
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension StartViewController: MPCManagerDelegate {
    func foundPeer() {}
    func lostPeer() {}
    
    func invitationWasReceived(fromPeer: String) {
        activityView.stopAnimating()
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to play.", preferredStyle: UIAlertController.Style.alert)
        
           let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertAction.Style.default) { (alertAction) -> Void in
               self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
           }
        
           let declineAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (alertAction) -> Void in
               self.appDelegate.mpcManager.invitationHandler(false, nil)
           }
        
           alert.addAction(acceptAction)
           alert.addAction(declineAction)
        
           OperationQueue.main.addOperation { () -> Void in
               self.present(alert, animated: true, completion: nil)
           }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
                // segue to game screen
        OperationQueue.main.addOperation { () -> Void in
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: HomeViewController = mainStoryboard.instantiateViewController(withIdentifier: "GameView") as! HomeViewController
            vc.modalPresentationStyle = .fullScreen
            vc.peerID = peerID
            self.present(vc, animated: true)
        }

    }
    
    
}
