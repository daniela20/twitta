//
//  Tweet.swift
//  Twitta
//
//  Created by Daniela Gonzalez on 6/27/16.
//  Copyright © 2016 Daniela Gonzalez. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var name: String?
    var username: String?
    var profileImageUrl: NSURL?
    var id: String?
    var text: String?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    
    init(dictionary: NSDictionary){
        text = dictionary["text"] as? String
        id = dictionary["id_str"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        if let timestampString = dictionary["created_at"] as? String {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
        }
        
        if let user = dictionary["user"] as? NSDictionary {
            name = user["name"] as? String
            username = user["screen_name"] as? String
            if let urlString = user["profile_image_url_https"] as! String? {
                profileImageUrl = NSURL(string: urlString)
            }
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }

}
