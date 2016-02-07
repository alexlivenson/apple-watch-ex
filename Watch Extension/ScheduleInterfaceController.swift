//
//  ScheduleInterfaceController.swift
//  AirAber
//
//  Created by alex livenson on 2/6/16.
//  Copyright © 2016 Mic Pringle. All rights reserved.
//

import WatchKit
import Foundation


class ScheduleInterfaceController: WKInterfaceController {

    @IBOutlet var flightsTable: WKInterfaceTable!
    var flights = Flight.allFlights()
    var selectedIndex = 0
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        flightsTable.setNumberOfRows(flights.count, withRowType: "FlightRow")
        flights.enumerate().forEach { (index: Int, flight: Flight) -> () in
            if let controller = flightsTable.rowControllerAtIndex(index) as? FlightRowController {
                controller.flight = flight
            }
        }
    }
    
    override func didAppear() {
        super.didAppear()
        
        if flights[selectedIndex].checkedIn,
            let controller = flightsTable.rowControllerAtIndex(selectedIndex) as? FlightRowController {
            animateWithDuration(0.35, animations: { () -> Void in
                controller.updateForCheckIn()
            })
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        selectedIndex = rowIndex
        
        let flight = flights[rowIndex]
        let controllers = ["Flight", "CheckIn"]
        presentControllerWithNames(controllers, contexts: [flight, flight])
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
