// Playground - noun: a place where people can play

import UIKit

let urlString: String = "http://wowbox.duowan.com/wowplugin/AddonsUpdater.json"
var url: NSURL = NSURL(string: urlString)!

var data = NSData(contentsOfURL: url)

var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)

var pluginListAddr: String = json?.objectForKey("pluglistjsonaddr") as String

var pluginListData = NSData(contentsOfURL: NSURL(string: pluginListAddr)!)

// TODO
// convert Chinese from ASC to UTF-8




/*var request = NSURLRequest(URL: url)

NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
        (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var result: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            println(result)
    })*/

