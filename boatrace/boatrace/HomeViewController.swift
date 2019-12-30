//
//  HomeViewController.swift
//  boatrace
//
//  Created by Daniel Weatrowski on 12/29/19.
//  Copyright © 2019 saddevelopment. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var peerID: MCPeerID?

    var counter = 0.0
    var countdown = 3.0
    var timer = Timer()
    var countDownTimer = Timer()
    var isPlaying = false
    var didWin = true
    
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.text = String(counter)
        stopButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(handleMPCReceivedDataWithNotification), name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: nil)
    }

    @objc func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        let receivedData = notification.object as! String
        print("DATA RECIEVED: \(receivedData)")
        OperationQueue.main.addOperation {
        
            switch (receivedData) {
            case "start":
                self.startCountDown()
                break
            case "stop":
                if (self.isPlaying) {
                    self.didWin = false
                }
                //self.stopTimer()
                break
            case "loser":
                self.didWin = false
            default: break
            }
        }
    }
    // MARK: - Actions
    fileprivate func startTimer() {
        if(isPlaying) {
            return
        }
        OperationQueue.main.addOperation {
            self.startButton.isEnabled = false
            self.stopButton.isEnabled = true
        }

        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isPlaying = true
        
    }
    func startCountDown() {
        if(isPlaying) {
            return
        }
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountDown), userInfo: nil, repeats: true)
    }
    
    @IBAction func didTapStart(_ sender: AnyObject) {
        startCountDown()
       // race.send(string: "Start")
        appDelegate.mpcManager.send(string: "start")
    }
    fileprivate func stopTimer() {
        OperationQueue.main.addOperation {
            self.startButton.isEnabled = true
            self.stopButton.isEnabled = false
        }
        
        timer.invalidate()
        isPlaying = false

    }
    
    @IBAction func didTapStop(_ sender: AnyObject) {
        // only send message if no winner has been established
        if (isPlaying || !didWin) {
            appDelegate.mpcManager.send(string: "stop")
            appDelegate.mpcManager.send(string: "loser")
        }
        // stop timer and segue to game over view 
        stopTimer()
        showFinalScore()
    }
    
    @objc func updateCountDown() {
        if countdown != 0 {
            countdown -= 1
        } else {
            countDownTimer.invalidate()
            startTimer()
        }
        OperationQueue.main.addOperation {
            self.timeLabel.text = String(format: "%.1f", self.countdown)
        }
        
    }
    @objc func UpdateTimer() {
        counter = counter + 0.1
        OperationQueue.main.addOperation {
            self.timeLabel.text = String(format: "%.1f", self.counter)
        }
    }

    // MARK: - Navigation
    func showFinalScore() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: GameOverViewController = mainStoryboard.instantiateViewController(withIdentifier: "GameOverView") as! GameOverViewController
        
        vc.time = String(format: "%.1f", self.counter)
        vc.didWin = self.didWin
        vc.previousPeerID = peerID

        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

