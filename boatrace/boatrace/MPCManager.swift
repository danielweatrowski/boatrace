//
//  MPCManager.swift
//  boatrace
//
//  Created by Daniel Weatrowski on 12/29/19.
//  Copyright © 2019 saddevelopment. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MPCManagerDelegate {
    func foundPeer()
 
    func lostPeer()
 
    func invitationWasReceived(fromPeer: String)
 
    func connectedWithPeer(peerID: MCPeerID)
    
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {

    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!

    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession?)->Void)!
    

    var delegate: MPCManagerDelegate?

    override init() {
        super.init()
     
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "boatrace")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "boatrace")
        self.advertiser.startAdvertisingPeer()
        advertiser.delegate = self
        
    }
    // send string to peer - works
    func send(string : String) {
        NSLog("%@", "sendColor: \(string) to \(session.connectedPeers.count) peers")

        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(string.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }

    }
    // send data to peer
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {

        do {
            let dataToSend = try NSKeyedArchiver.archivedData(withRootObject: dictionary, requiringSecureCoding: true)
            let peersArray = NSArray(object: targetPeer)
            try session.send(dataToSend, toPeers: peersArray as! [MCPeerID], with: .reliable)
        
        } catch let error as NSError {
            print("Error sending data: \(error.localizedDescription)")
            return false
        }
     
        return true
    }
    
    // MARK: - Protocol Stubs
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
               print("Connected to session: \(session)")
               delegate?.connectedWithPeer(peerID: peerID)
        
        case MCSessionState.connecting:
               print("Connecting to session: \(session)")
        
           default:
               print("Did not connect to session: \(session)")
           }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        // append new peer to foundPeers array
        foundPeers.append(peerID)
        delegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // remove lost peers from array
        for (index, aPeer) in foundPeers.enumerated() {
           if aPeer == peerID {
             foundPeers.remove(at: index)
               break
           }
       }
       delegate?.lostPeer()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
    }

}
