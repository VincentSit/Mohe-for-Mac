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
        let urlString = "http://wowbox.duowan.com/wowplugin/AddonsUpdater.json"
        var url: NSURL = NSURL(string: urlString)!
        
        var data = NSData(contentsOfURL: url)
        
        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
        
        var pluginListAddr: String = json?.objectForKey("plugjsonaddr") as String
        
        var pluginListData = NSData(contentsOfURL: NSURL(string: pluginListAddr)!)
        
        var crc32: NSDictionary = NSJSONSerialization.JSONObjectWithData(pluginListData!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        
        var list: NSArray = crc32["Crc32"] as NSArray
        
        for item in list{
            var fileslist: NSArray = item["files"] as NSArray
            for file in fileslist{
                println(file["file"])
            }
        }
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

