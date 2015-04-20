//
//  Parser.swift
//  reddift
//
//  Created by sonson on 2015/04/20.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit

class Parser: NSObject {

    class func parseThing(json:[String:AnyObject], depth:Int) -> AnyObject? {
        if let data = json["data"] as? [String:AnyObject], kind = json["kind"] as? String {
            println("----------------------------------------------------------------")
            println(kind)
            
            switch(kind) {
            case "t1":
                // comment
                if let value = data["replies"] as? [String:AnyObject] {
                    parseListing(value, depth:depth)
                }
                break
            case "t2":
                // account
                break
            case "t3":
                // link
                let obj = Link(json:data)
                return obj
            case "t4":
                // mesasge
                break
            case "t5":
                // subreddit
                break
            case "t6":
                // award
                break
            case "t8":
                // promo campaign
                break
            default:
                break
            }
        }
        return nil
    }
    
    class func parseListing(json:[String:AnyObject], depth:Int) -> Listing {
        let listing = Listing()
        
        if let data = json["data"] as? [String:AnyObject] {
            if let children = data["children"] as? [AnyObject] {
                for child in children {
                    if let child = child as? [String:AnyObject] {
                        let obj:AnyObject? = parseJSON(child, depth: depth + 1)
                        if let obj:AnyObject = obj {
                            listing.children.append(obj)
                        }
                    }
                }
            }
            if let after = data["after"] as? String {
                listing.after = after
            }
            if let before = data["before"] as? String {
                listing.before = before
            }
            if let modhash = data["modhash"] as? String {
                listing.modhash = modhash
            }
        }
        return listing
    }
    
    class func parseJSON(json:AnyObject, depth:Int) -> AnyObject? {
        
        let kindDict = [
            "t1":"Comment",
            "t2":"Account",
            "t3":"Link",
            "t4":"Message",
            "t5":"Subreddit",
            "t6":"Award",
            "t8":"PromoCampaign"
        ]
        
        // array
        // json->[AnyObject]
        if let array = json as? [AnyObject] {
            var output:[AnyObject] = []
            for element in array {
                if let element = element as? [String:AnyObject] {
                    let obj:AnyObject? = self.parseJSON(element, depth:depth)
                    if let obj:AnyObject = obj {
                        output.append(obj)
                    }
                }
            }
        }
        // dictionary
        // json->[String:AnyObject]
        else if let json = json as? [String:AnyObject] {
            if let kind = json["kind"] as? String {
                if kind == "Listing" {
                    let listing = parseListing(json, depth:depth)
                }
                else {
                    return parseThing(json, depth:depth)
                }
            }
        }
        return nil
    }
}