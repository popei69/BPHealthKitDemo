//
//  ViewController.swift
//  HealthKitDemo
//
//  Created by Benoit PASQUIER on 14/06/2016.
//  Copyright © 2016 Benoit PASQUIER. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // create an object type to request an authorization for a specific category, here is SleepAnalysis
        
        if let sleepType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis) {
            
            let setType = Set<HKSampleType>(arrayLiteral: sleepType)
            healthStore.requestAuthorizationToShareTypes(setType, readTypes: setType, completion: { (success, error) -> Void in
                // here is your code
                
                
            })
        }
    }
    
    @IBAction func readSleepData(sender: AnyObject) {
        
        guard let sleepType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis) else {
            return
        }
        
        // define date to search
        let startDate = NSDate(timeIntervalSinceNow: -60 * 60 * 24 * 7)
        let endDate = NSDate()
        
        // we create a predicate to filter our data
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        // I had a sortDescriptor to get the recent data first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // we create our query with a block completion to execute
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
            
            if error != nil {
                // something happened
                return
                
            }
            
            if let result = tmpResult {
                
                if result.count == 0 {
                    print("No data to read")
                }
                
                // do something with my data
                for item in result {
                    if let sample = item as? HKCategorySample {
                        
                        let value = (sample.value == HKCategoryValueSleepAnalysis.InBed.rawValue) ? "InBed" : "Asleep"
                        
                        print("Healthkit sleep: ", sample.startDate, " ", sample.endDate, " source: ", sample.sourceRevision.source.name, "- value: ", value)
                    }
                }
            }
        }
        
        // finally, we execute our query
        healthStore.executeQuery(query)
    }
    
    @IBAction func writeSleepData(sender: AnyObject) {
        
        guard let sleepType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis) else {
            return
        }
        
        
        let startDate = NSDate(timeIntervalSinceNow: -60 * 60)
        let endDate = NSDate()
        
        // we create our new object we want to push in Health app, defined by last hour
        let object = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.InBed.rawValue, startDate: startDate, endDate: endDate)
        
        // at the end, we save it
        healthStore.saveObject(object, withCompletion: { (success, error) -> Void in
            
            if error != nil {
                
                // something happened
                return
                
            }
            
            if success {
                print("My new data was saved in Healthkit")
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

