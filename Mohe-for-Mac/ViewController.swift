//
//  ViewController.swift
//  Mohe-for-Mac
//
//  Created by Secbone on 10/31/14.
//  Copyright (c) 2014 Secbone. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBAction func getJson(sender: AnyObject){
        let urlString: String = "http://wowbox.duowan.com/wowplugin/AddonsUpdater.json"
        var url = NSURL(string: urlString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func press(){
        println("press")
    }

}

