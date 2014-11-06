//
//  ViewController.swift
//  Mohe-for-Mac
//
//  Created by Secbone on 10/31/14.
//  Copyright (c) 2014 Secbone. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // test wow plugin path
    let wowPath = "/User/secbone/Code/plugin/"
    
    var pluginDownloadAddr: String = ""
    
    @IBAction func getJson(sender: AnyObject){
        let urlString = "http://wowbox.duowan.com/wowplugin/AddonsUpdater.json"
        var url: NSURL = NSURL(string: urlString)!
        
        var data = NSData(contentsOfURL: url)
        
        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
        
        pluginDownloadAddr = json?.objectForKey("plughttpaddr") as String
        
        var pluginListAddr: String = json?.objectForKey("plugjsonaddr") as String
        
        var pluginListData = NSData(contentsOfURL: NSURL(string: pluginListAddr)!)
        
        var crc32: NSDictionary = NSJSONSerialization.JSONObjectWithData(pluginListData!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        
        var list: NSArray = crc32["Crc32"] as NSArray
        
        for item in list{
            var folder: NSString = item["folder"] as NSString
            var fileslist: NSArray = item["files"] as NSArray
            for file in fileslist{
                var path: NSString = file["file"] as NSString
                //println("\(pluginDownloadAddr)\(folder)/\(path)")
                var filePath = "\(folder)\\\(path)"
                println("\(filePath)")
                write7zfile(filePath)
            }
        }
        
        var xml = "http://wowbox.duowan.com/wowplugin/AddOns/Accountant_Classic/Accountant.xml.7z"
        var xmlurl = NSURL(string: xml)
        var xmldata: NSData = NSData(contentsOfURL: xmlurl!)!
        
        //var writePath = @"/Users/secbone/xml.7z"
        var bool = xmldata.writeToFile("/Users/secbone/xml.7z", atomically: true)
        
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
    
    func write7zfile(path: String) -> Bool? {
        var downloadPath: String = "\(pluginDownloadAddr)\(path).7z"
        downloadPath = replaceChar(downloadPath, searchString: "\\", replaceString: "/")
        var pluginURL: NSURL = NSURL(string: downloadPath)!
        var pluginData: NSData = NSData(contentsOfURL: pluginURL)!
        var bool = pluginData.writeToFile("\(wowPath)\(path)", atomically: true)
        return bool
    }
    
    func replaceChar(string: NSString, searchString: String, replaceString: String) -> String {
        var substr: NSRange = string.rangeOfString(searchString)
        while(substr.location != NSNotFound){
            string.replaceCharactersInRange(substr, withString:replaceString);
            substr = string.rangeOfString(searchString)
        }
        return string
    }

}

