//
//  Helper.swift
//  LoveKeeper
//
//  Created by Matej Kusnier on 11/7/15.
//  Copyright © 2015 LoveKeepers. All rights reserved.
//

import UIKit
import Firebase

class Helper: NSObject {
    
    
    
    func send () -> Void {
    
        // Create a reference to a Firebase location
        var myRootRef = Firebase(url:"https://popping-fire-9519.firebaseio.com")
        // Write data to Firebase
        myRootRef.setValue(["nehehe", "nehehe"])
    }

    
    func retValues() -> Int? {
        
        var myRootRef = Firebase(url:"https://popping-fire-9519.firebaseio.com")
        
        myRootRef.setValue(["dfj", "kufh"])
        print("picee")
        myRootRef.observeEventType(.Value, withBlock: {
            snapshot in
            print(" tuto to je\(snapshot.key) -> \(snapshot.value)")
        })
        
        return 0;
    
    }
}
