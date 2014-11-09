//
//  ViewController.swift
//  Mohe-for-Mac
//
//  Created by Secbone on 10/31/14.
//  Copyright (c) 2014 Secbone. All rights reserved.
//

import Cocoa
import CryptoSwift

class ViewController: NSViewController {
    
    // test wow plugin path
    var wowPath = "/Applications/World of Warcraft/Interface/AddOns/"
    var AddOnsPath = "Interface/AddOns"
    let tempPath = NSTemporaryDirectory()
    
    var pluginDownloadAddr: String = ""
    

    
    @IBOutlet var updatingLabel: NSTextField!
    @IBOutlet var wowPathTextField: NSTextField!
    @IBAction func chooseDirectory(sender: AnyObject) {
        var panel: NSOpenPanel = NSOpenPanel()
        panel.prompt = "Choose"
        panel.showsResizeIndicator = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        //panel.allowsMultipleSelection = false
        panel.beginWithCompletionHandler({(result) -> Void in
            if result == NSOKButton {
                var selection: NSURL = panel.URLs[0] as NSURL
                var path = selection.path!
                self.wowPathTextField.stringValue = path
                self.wowPath = path.stringByAppendingPathComponent(self.AddOnsPath)
            }
        })
        
    }
    
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
                var crc = file["CrcVal"] as NSInteger
                var filePath = folder.stringByAppendingPathComponent(path)
                //println("\(filePath)")
                if !checkCrcValue(wowPath.stringByAppendingPathComponent(filePath), crcvalue: crc) {
                    self.updatingLabel.stringValue = "Updating \(path)"
                    write7zfile(filePath)
                }
            }
        }
        
        self.updatingLabel.stringValue = "Update Done! Enjoy It!"
        
        
        // Test download 7z file
        /*var xml = "http://wowbox.duowan.com/wowplugin/AddOns/Accountant_Classic/Accountant.xml.7z"
        var xmlurl = NSURL(string: xml)
        var xmldata: NSData = NSData(contentsOfURL: xmlurl!)!
        
        //var writePath = @"/Users/secbone/xml.7z"
        var bool = xmldata.writeToFile("/Users/secbone/xml.7z", atomically: true)*/
        
        //Test decompile 7z file
        
        //var srcPath = "/Users/secbone/xml.7z" as NSString
        //var toPath = "/Users/secbone/Public" as NSString
        //var array = decompile7z(srcPath, toPath: toPath)
        //println(array)
        
        
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
    
    func checkCrcValue(path: NSString, crcvalue: NSInteger) -> Bool {
        var fileData = NSData(contentsOfFile: path)
        var fileCrc = fileData?.crc32()
        println("\(fileCrc)======\(crcvalue)")
        return true
    }
    
    func write7zfile(path: NSString) -> Bool? {
        
        var folderPath = replaceChar(path.mutableCopy() as NSMutableString, searchString: "\\", replaceString: "/")
        
        //get download Path
        let downloadString = "\(pluginDownloadAddr.stringByAppendingPathComponent(folderPath)).7z" as NSString
        //var downloadPath: NSMutableString = downloadString.mutableCopy() as NSMutableString
        
        //replace \ to /
        //downloadPath = replaceChar(downloadPath, searchString: "\\", replaceString: "/")
        
        //get file data
        var pluginURL: NSURL = NSURL(string: downloadString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        var pluginData: NSData = NSData(contentsOfURL: pluginURL)!
        
        //get write file
        var pluginWritePathNS = "\(tempPath.stringByAppendingPathComponent(folderPath)).7z" as NSString
        var bool = writeFileWithPath(pluginWritePathNS, fileData: pluginData)
        bool = decompile7z(pluginWritePathNS, toPath: "\(wowPath.stringByAppendingPathComponent(getFilePath(folderPath)))")
        return bool
    }
    
    
    /*************************
    ** Write File With Path **
    **************************/
    func writeFileWithPath(path: NSString, fileData: NSData) -> Bool {
        
        var writePath = path.mutableCopy() as NSMutableString
        
        //replace \ to /
        writePath = replaceChar(writePath, searchString: "\\", replaceString: "/")
        
        //get folder path
        var folderPath = getFilePath(writePath)
        
        //create folder and write file
        var fileManager = NSFileManager()
        var bool = fileManager.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        bool = fileManager.createFileAtPath(writePath, contents: fileData, attributes: nil)
        //println(bool)
        
        
        return bool
    }
    
    func decompile7z(filePath: NSString, toPath: NSString) -> Bool {
        var pathArray: NSArray = LZMAExtractor.extract7zArchive(filePath, tmpDirName: toPath)
        var bool = false
        for tmpPath in pathArray {
            var filedata: NSData = NSData(contentsOfFile: tmpPath as NSString)!
            var fileName = getFileName(tmpPath as NSString)
            var writePath = toPath.stringByAppendingPathComponent(fileName)
            bool = writeFileWithPath(writePath, fileData: filedata)
        }
        return bool
    }
    
    func getFileName(filePath: NSString) -> NSString {
        var fileName = filePath.lastPathComponent
        return fileName
    }
    
    func getFilePath(filePath: NSString) -> NSString {
        var pathArray: NSArray = filePath.pathComponents
        var folderPath = NSString.pathWithComponents(pathArray.subarrayWithRange(NSMakeRange(0, pathArray.count-1)))
        return folderPath
    }
    
    func replaceChar(string: NSMutableString, searchString: String, replaceString: String) -> NSMutableString {
        var substr: NSRange = string.rangeOfString(searchString)
        
        while(substr.location != NSNotFound){
            string.replaceCharactersInRange(substr, withString:replaceString);
            substr = string.rangeOfString(searchString)
        }
        return string
    }

}

