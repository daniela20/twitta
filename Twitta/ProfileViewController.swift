//
//  ProfileViewController.swift
//  Twitta
//
//  Created by Daniela Gonzalez on 6/29/16.
//  Copyright © 2016 Daniela Gonzalez. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var tweets: [Tweet]!
    var feedSize: Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        tableView.dataSource = self
        tableView.delegate = self
        
        bgView.layer.borderColor = UIColor(white: 0.74, alpha: 1.0).CGColor
        bgView.layer.borderWidth = 1;
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height/5;
        profileImage.layer.masksToBounds = true;
        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage.layer.borderWidth = 3
        
        let client = TwitterClient.sharedInstance
        client.currentAccount({ (user: User) in
            self.nameLabel.text = user.name
            self.usernameLabel.text = "@" + user.username!
            self.profileImage.setImageWithURL(user.profileImageUrl!)
            self.bioLabel.text = user.bio
            self.followerCountLabel.text = String(user.followerCount)
            self.followingCountLabel.text = String(user.followingCount)
            
            self.loadTweets()
            
            client.bannerImage({ (bannerDictionary: NSDictionary) in
                print(bannerDictionary)
                if let sizeDictionary = bannerDictionary["sizes"] as? NSDictionary {
                    if let mobileDictionary = sizeDictionary["web"] as? NSDictionary {
                        let bannerUrlString = mobileDictionary["url"] as? String
                        if let bannerUrlString = bannerUrlString {
                            print("URL: \(bannerUrlString)")
                            let bannerUrl = NSURL(string: bannerUrlString)
                            self.coverImage.setImageWithURL(bannerUrl!)
                        }
                    }
                }
                
            }, failure: { (error: NSError) in
                print("\(error.localizedDescription)")
            })
            
        }, failure: { (error: NSError) in
            print("\(error.localizedDescription)")
        })
        
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    func loadTweets() {
        let client = TwitterClient.sharedInstance
        client.userTimeline({ (tweets: [Tweet]) in
            self.tweets = tweets
            /*for tweet in tweets {
             print(tweet.text)
             }*/
            self.tableView.reloadData()
        }) { (error: NSError) in
            print("\(error.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            if(tweets.count > feedSize){
                print("returning 20")
                return feedSize
            } else {
                print("returning tweets.count")
                return tweets.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet
        cell.tweetLabel.text = tweet.text
        cell.nameLabel.text = tweet.name
        cell.usernameLabel.text = "@" + tweet.username!
        cell.profilePicture.setImageWithURL(tweet.profileImageUrl!)
        cell.retweetCountLabel.text = String(tweet.retweetCount)
        cell.favoriteCountLabel.text = String(tweet.favoriteCount)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d HH:mm y"
        cell.timestampLabel.text = formatter.stringFromDate(tweet.timestamp!)
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
