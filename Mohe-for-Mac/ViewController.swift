//
//  ViewController.swift
//  Mohe-for-Mac
//
//  Created by Secbone on 10/31/14.
//  Copyright (c) 2014 Secbone. All rights reserved.
//

import Cocoa
//import CryptoSwift

class ViewController: NSViewController {
    
    // test wow plugin path
    var AddOnsPath: NSString = "Interface/AddOns"
    var wowRootPath = "/Applications/World of Warcraft/"
    var wowPath = "/Applications/World of Warcraft/Interface/AddOns"
    var CrcJsonPath = "MoheForMac/Crc32.json"
    let tempPath = NSTemporaryDirectory()
    var pluginDownloadAddr: String = ""
    var isUpdate = false
    
    

    
    @IBOutlet var updatingLabel: NSTextField!
    @IBOutlet var wowPathTextField: NSTextField!
    @IBAction func chooseDirectory(sender: AnyObject) {
        var panel: NSOpenPanel = NSOpenPanel()
        panel.prompt = "Choose"
        panel.showsResizeIndicator = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginWithCompletionHandler({(result) -> Void in
            if result == NSOKButton {
                var selection: NSURL = panel.URLs[0] as NSURL
                var path = selection.path!
                
                NSUserDefaults.setValue(path, forKey: "wowPath")
                self.wowRootPath = path
                self.wowPath = path.stringByAppendingPathComponent(self.AddOnsPath)
                self.wowPathTextField.stringValue = path
            }
        })
        
    }
    
    @IBAction func getJson(sender: AnyObject){
        let urlString = "http://wowbox.duowan.com/wowplugin/AddonsUpdater.json"
        var url: NSURL = NSURL(string: urlString)!
        var data = NSData(contentsOfURL: url)
        
        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
        pluginDownloadAddr = json?.objectForKey("plughttpaddr") as String
        var pluginListAddr: String = json?.objectForKey("plugjsonaddr") as NSString
        var pluginCrc: NSInteger = json?.objectForKey("plugcrc") as NSInteger
        
        if !checkCrcValue(pluginCrc) {
            updataPlugin(pluginListAddr)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDefaultsPath()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func updataPlugin(jsonPath: NSString) -> Void {
        var pluginListData = NSData(contentsOfURL: NSURL(string: jsonPath)!)
        var crc32: NSDictionary = NSJSONSerialization.JSONObjectWithData(pluginListData!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        
        var list: NSArray = crc32["Crc32"] as NSArray
        for item in list{
            var folder: NSString = item["folder"] as NSString
            var fileslist: NSArray = item["files"] as NSArray
            for file in fileslist{
                var path: NSString = file["file"] as NSString
                var crc = file["CrcVal"]
                var filePath = folder.stringByAppendingPathComponent(path)
                self.updatingLabel.stringValue = "Updating \(path)"
                write7zfile(filePath)
            }
        }
        
        self.updatingLabel.stringValue = "Update Done! Enjoy It!"
    }
    
    func loadDefaultsPath() -> Void {
        var path: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("wowPath")
        if path == nil {
            path = "/Applications/World of Warcraft/"
        }
        wowRootPath =  path as NSString
        wowPath = wowRootPath.stringByAppendingPathComponent(AddOnsPath)
        self.wowPathTextField.stringValue = wowRootPath
    }
    
    func checkCrcValue(CrcValue: NSInteger) -> Bool {
        var crcString: String = String(CrcValue)
        var localCrc = NSUserDefaults.standardUserDefaults().objectForKey("crcVal")
        if localCrc == nil {
            localCrc = ""
        }
    
        var localCrcString = localCrc as NSString
        if crcString == localCrcString {
            self.updatingLabel.stringValue = "No Update! Have a Good Time!"
            return true
        }
        NSUserDefaults.standardUserDefaults().setValue(crcString, forKey: "crcVal")
        self.updatingLabel.stringValue = "Updating... Please Wait..."
        return false
    }
    
    func write7zfile(path: NSString) -> Bool? {
        
        var folderPath = replaceChar(path.mutableCopy() as NSMutableString, searchString: "\\", replaceString: "/")
        
        let downloadString = "\(pluginDownloadAddr.stringByAppendingPathComponent(folderPath)).7z" as NSString
        
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

