//
//  BoardingPassInterfaceController.swift
//  AirAber
//
//  Created by alex livenson on 2/7/16.
//  Copyright © 2016 Mic Pringle. All rights reserved.
//

import WatchKit
import WatchConnectivity

class BoardingPassInterfaceController: WKInterfaceController {
    
    @IBOutlet var originLabel: WKInterfaceLabel!
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    @IBOutlet var boardingPassImage: WKInterfaceImage!
    
    var flight: Flight? {
        didSet {
            if let flight = flight {
                originLabel.setText(flight.origin)
                destinationLabel.setText(flight.destination)
                
                if let _ = flight.boardingPass {
                    showBoardingPass()
                }
            }
        }
    }
    
    /*
        NOTE: all communication between device and phone is handled by WCSession.
        Use Singleton provided by the framework
    */
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let flight = context as? Flight {
            self.flight = flight
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func didAppear() {
        // 1. Always check that watch connectivity is supported before attempting communication
        if let flight = flight where flight.boardingPass == nil && WCSession.isSupported() {
            // 2. Trigger property observer
            session = WCSession.defaultSession()
            
            // 3. The reply and error handlers are called on background queue, so get main queue
            session?.sendMessage(["reference": flight.reference],
                replyHandler: { (response: [String : AnyObject]) -> Void in
                    if let boardingPassData = response["boardingPassData"] as? NSData
                        , boardingPass = UIImage(data: boardingPassData) {
                            flight.boardingPass = boardingPass
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.showBoardingPass()
                            })
                    }
                }, errorHandler: { (error: NSError) -> Void in
                    print(error)
            })
        }
    }
    
    // MARK: - Private methods
    private func showBoardingPass() {
        boardingPassImage.stopAnimating()
        boardingPassImage.setWidth(120)
        boardingPassImage.setHeight(120)
        boardingPassImage.setImage(flight?.boardingPass)
    }

}

extension BoardingPassInterfaceController: WCSessionDelegate {
    
}
