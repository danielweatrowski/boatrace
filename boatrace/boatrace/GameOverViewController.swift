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
        appDelegate.mpcManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleMPCReceivedDataWithNotification), name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: nil)
//        appDelegate.mpcManager.browser.startBrowsingForPeers()
//        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
    }
    
    func setUpView() {
        winLabel.text = didWin ? "Winner" : "Loser"
        timeLabel.text = time
    }
    @objc func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        let receivedData = notification.object as! String
        print("DATA RECIEVED: \(receivedData)")
        guard let peerID = self.previousPeerID else {
            print("unable to unwrap peerid")
            return
        }
        OperationQueue.main.addOperation {
        
            switch (receivedData) {
                case "request":
                    self.confirmRematch()
                    break
                case "accepted":
                    self.connectedWithPeer(peerID: peerID)
                    break
                case "done":
                    self.endSession()
                    self.didTapDone()
                    break
                //self.didWin = false
                default: break
            }
        }
    }
    func confirmRematch() {
        guard let peerID = self.previousPeerID else {
            print("unable to unwrap peerid")
            return
        }
        let alert = UIAlertController(title: "", message: "\(peerID) requests a rematch.", preferredStyle: UIAlertController.Style.alert)
    
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: .default) { (alertAction) -> Void in
            print("accepted rematch from \(peerID)")
            self.appDelegate.mpcManager.send(string: "accepted")
            self.connectedWithPeer(peerID: peerID)
        }
    
        let declineAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) -> Void in
           //self.appDelegate.mpcManager.invitationHandler(false, nil)
        }
    
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
    
        OperationQueue.main.addOperation { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }
    func endSession() {
        appDelegate.mpcManager.session.disconnect()
        //appDelegate.mpcManager.browser.stopBrowsingForPeers()
        //appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
    }
    // MARK: - Actions
    @IBAction func didTapDone() {
        // disconnect session and stop browsing
        self.appDelegate.mpcManager.send(string: "done")
        self.performSegue(withIdentifier: "unwindToStart", sender: self)
    }
    
    @IBAction func didTapRematch() {
        // unwrap peerID
        guard let peerID = self.previousPeerID else {
            print("unable to unwrap peerID")
            return
        }

        // present confirmation alert
        let alert = UIAlertController(title: "", message: "Request Rematch with \(peerID)?", preferredStyle: UIAlertController.Style.alert)
        let acceptAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { (alertAction) -> Void in
            // send invitation to peer if confirmed
            print("Inviting peer for rematch")
            // send request to peer
            self.appDelegate.mpcManager.send(string: "request")
        }
    
        let declineAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) -> Void in
            // do something
        }
    
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
    
        OperationQueue.main.addOperation { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
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
        guard let peerID = self.previousPeerID else {
            print("unable to unwrap peerid")
            return
        }
        let alert = UIAlertController(title: "", message: "\(fromPeer) requests a rematch.", preferredStyle: UIAlertController.Style.alert)
    
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: .default) { (alertAction) -> Void in
            print("accepted rematch from \(fromPeer)")
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
            self.connectedWithPeer(peerID: peerID)
        }
    
        let declineAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) -> Void in
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
        print("reconnected with peer")
        OperationQueue.main.addOperation { () -> Void in
            guard let peerID = self.previousPeerID else {
                print("unable to unwrap peerid")
                return
            }
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: HomeViewController = mainStoryboard.instantiateViewController(withIdentifier: "GameView") as! HomeViewController
            vc.modalPresentationStyle = .fullScreen
            vc.peerID = peerID
            self.present(vc, animated: true)
        }
    }
    
    
}
