//
//  GameOverViewController.swift
//  boatrace
//
//  Created by Daniel Weatrowski on 12/29/19.
//  Copyright © 2019 saddevelopment. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameOverViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet var winLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    var time: String = "0:0"
    var didWin = false
    var previousPeerID: MCPeerID?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    // MARK - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView() {
        winLabel.text = didWin ? "Winner" : "Loser"
        timeLabel.text = time
    }
    // MARK: - Actions
    @IBAction func didTapDone() {
        self.performSegue(withIdentifier: "unwindToStart", sender: self)
    }
    @IBAction func didTapRematch() {
        // TODO: Present Confirmation alert
        guard let peerID = previousPeerID else {return}
        appDelegate.mpcManager.browser.invitePeer(peerID, to: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }
    // give users option to disqualify/delete last game
    // can be requested by either user, peer needs to accept or reject refute request
    // within 30 seconds
    @IBAction func didTapRefute() {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension GameOverViewController: MPCManagerDelegate {
    // Can ignore these protocol stubs since rematch will be with the same peerID
    func foundPeer() {}
    func lostPeer() {}
    
    // send invitation to peer
    func invitationWasReceived(fromPeer: String) {
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
    
    // segue to game screen (HomeViewController)
    func connectedWithPeer(peerID: MCPeerID) {
        // jump to main queue
        OperationQueue.main.addOperation { () -> Void in
            guard let peerID = self.previousPeerID else {return}
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: HomeViewController = mainStoryboard.instantiateViewController(withIdentifier: "GameView") as! HomeViewController
            vc.modalPresentationStyle = .fullScreen
            vc.peerID = peerID
            self.present(vc, animated: true)
        }
    }
    
    
}
