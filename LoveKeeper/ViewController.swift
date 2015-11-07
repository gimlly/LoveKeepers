//
//  ViewController.swift
//  LoveKeeper
//
//  Created by Matej Kusnier on 11/7/15.
//  Copyright © 2015 LoveKeepers. All rights reserved.
//

import UIKit
import WatchConnectivity


class ViewController: UIViewController, WCSessionDelegate {
    
    var session: WCSession!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var rateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self;
            session.activateSession()
        }
        
        
        let helper: Helper! = Helper()
        
        helper.retValues()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    @IBAction func sendToWatch(sender: AnyObject) {
        

        let mess: String! = self.textField.text
        
        //Send Message to WatchKit
        let messageToSend = ["Value":mess]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
        
            }, errorHandler: {error in
                // catch any errors here
                print(error)
        })
    }
    
    //WCS delegate
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        //handle received message
        let value = message["Value"] as? String
        dispatch_async(dispatch_get_main_queue()) {
            self.rateLabel.text = value
        }
    }
    

}

