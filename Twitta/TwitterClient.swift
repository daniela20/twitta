//
//  TwitterClient.swift
//  Twitta
//
//  Created by Daniela Gonzalez on 6/28/16.
//  Copyright © 2016 Daniela Gonzalez. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")!, consumerKey: "dOo31TWgWtKD4OZXod1nTIjzC", consumerSecret: "kqSX8lRp7VUQFtmyMbJmVwbxZW0BBdwcmB96OpoX5JMMzp5JWO")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func homeTimeline(success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            
            success(tweets)
            
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }
    
    func userTimeline(user: User, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        GET("1.1/statuses/user_timeline.json?screen_name=\(user.username!)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }
    
    func currentAccount(success: (User)->(), failure: (NSError) -> ()) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
            
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }
    
    func bannerImage(user: User, success: (NSDictionary)->(), failure: (NSError) -> ()) {
        if user.username != nil {
            GET("1.1/users/profile_banner.json?screen_name=\(user.username!)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("got banner")
                let bannerDictionary = response as! NSDictionary
                success(bannerDictionary)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            })
        }
    }
    
    func tweet(status: String, success: (NSDictionary)->(), failure: (NSError) -> ()) {
        POST("1.1/statuses/update.json?status=\(status)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let responseDictionary = response as! NSDictionary
            print("tweeted")
            success(responseDictionary)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }
    
    func retweet(id: String, success: (NSDictionary)->(), failure: (NSError) -> ()) {
        POST("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let responseDictionary = response as! NSDictionary
            print("retweeted")
            success(responseDictionary)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }
    
    func unretweet(id: String, success: (NSDictionary)->(), failure: (NSError) -> ()) {
        POST("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let responseDictionary = response as! NSDictionary
            print("unretweeted")
            success(responseDictionary)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func favorite(id: String, success: (NSDictionary)->(), failure: (NSError) -> ()) {
        POST("1.1/favorites/create.json?id=\(id)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let responseDictionary = response as! NSDictionary
            print("favorited")
            success(responseDictionary)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func unfavorite(id: String, success: (NSDictionary)->(), failure: (NSError) -> ()) {
        POST("1.1/favorites/destroy.json?id=\(id)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let responseDictionary = response as! NSDictionary
            print("unfavorited")
            success(responseDictionary)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func login(success: () -> (), failure: (NSError) -> ()) {
        deauthorize()
        loginSuccess = success
        loginFailure = failure
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitta://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(url)
            
        }) { (error: NSError!) -> Void in
            print("\(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func handleOpenUrl(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            self.currentAccount({ (user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
            }, failure:{ (error: NSError) -> () in
                self.loginFailure?(error)
            })
            
        }) { (error: NSError!) -> Void in
            print("\(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(User.notification, object: nil)
    }
    
}
