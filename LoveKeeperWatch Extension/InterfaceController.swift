//
//  InterfaceController.swift
//  LoveKeeperWatch Extension
//
//  Created by Matej Kusnier on 11/7/15.
//  Copyright © 2015 LoveKeepers. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import HealthKit


class InterfaceController: WKInterfaceController, WCSessionDelegate, HKWorkoutSessionDelegate {
    
    var session : WCSession!
    
    let healthStore = HKHealthStore()
    
    // define the activity type and location
    let workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.CrossTraining, locationType: HKWorkoutSessionLocationType.Indoor)
    let heartRateUnit = HKUnit(fromString: "count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    
    
    @IBOutlet var heart: WKInterfaceImage!
    @IBOutlet var rateLabel: WKInterfaceLabel!
    @IBOutlet var genderLabel: WKInterfaceLabel!
    
    @IBOutlet var label: WKInterfaceLabel!
    
    var counter = 0;

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        workoutSession.delegate = self
        

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        
        var error:NSError?
        
        //WorkoutSession
        guard HKHealthStore.isHealthDataAvailable() == true else {
            rateLabel.setText("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) -> Void in
            if success == false {
              //  self.displayNotAllowed()
            }
        }
        
        
        
       
        //get gender
            var biologicalSex:HKBiologicalSexObject? = try healthStore.biologicalSex()
        
    }


    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    

    
    @IBAction func startAction() {
        
        healthStore.startWorkoutSession(workoutSession)
    }

    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        //handle received message
        let value = message["Value"] as? String
        
        print("recieved message")
        //use this to present immediately on the screen
        dispatch_async(dispatch_get_main_queue()) {
            self.label.setText(value)
            
            WKInterfaceDevice.currentDevice().playHaptic(.Click)


            print("pressed")
        }
        //send a reply
        replyHandler(["Value":"Yes"])
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    //Workout Session
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        switch toState {
        case .Running:
            workoutDidStart(date)
            print("started state")
        case .Ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        print("error \(error)")
        
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    
    //Start Workout
    func workoutDidStart(date : NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.executeQuery(query)
        } else {
            rateLabel.setText("cannot start")
        }
    }
    
    //End workout
    func workoutDidEnd(date : NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.stopQuery(query)
            rateLabel.setText("Stop")
        } else {
            rateLabel.setText("cannot stop")
        }
    }
    
    //Create heart rate session
    func createHeartRateStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor else {return}
            self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.anchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    //Update heart rate
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let sample = heartRateSamples.first else{return}
            let value = sample.quantity.doubleValueForUnit(self.heartRateUnit)
            self.rateLabel.setText(String(UInt16(value)))
            self.sendRate(String(UInt16(value)))
            print("new")
            
            self.animateHeart()
            // retrieve source from sample
            //let name = sample.sourceRevision.source.name
            //self.updateDeviceName(name)
        }
    }
    
    func sendRate (rate : String) -> Void {
        
        
        //Send Message to WatchKit
        let messageToSend = ["Value":rate]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            
            }, errorHandler: {error in
                // catch any errors here
                print(error)
        })
        
    }
    
    
    
    
    func animateHeart() {
        self.animateWithDuration(0.5) {
            self.heart.setWidth(60)
            self.heart.setHeight(60)
        }
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * double_t(NSEC_PER_SEC)))
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_after(when, queue) {
            dispatch_async(dispatch_get_main_queue(), {
                self.animateWithDuration(0.5, animations: {
                    self.heart.setWidth(50)
                    self.heart.setHeight(50)
                })
            })
        }
    }
}
