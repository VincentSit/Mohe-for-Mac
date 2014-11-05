// Playground - noun: a place where people can play

import UIKit

let urlString = "http://wowbox.duowan.com/wowplugin/AddonsUpdater.json"
var url: NSURL = NSURL(string: urlString)!

var data = NSData(contentsOfURL: url)

var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)

var pluginListAddr: String = json?.objectForKey("plugjsonaddr") as String

var pluginListData = NSData(contentsOfURL: NSURL(string: pluginListAddr)!)

var crc32: NSDictionary = NSJSONSerialization.JSONObjectWithData(pluginListData!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary

var list: NSArray = crc32["Crc32"] as NSArray

for item in list{
    var folder: NSString = item["folder"] as NSString
    var fileslist: NSArray = item["files"] as NSArray
    for file in fileslist{
        var path: NSString = file["file"] as NSString
        println("\(folder)/\(path)")
    }
}


// TODO
// convert Chinese from ASC to UTF-8
// decompress 7zip
// crc32




/*var request = NSURLRequest(URL: url)

NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
        (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var result: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            println(result)
    })*/

