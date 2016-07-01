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
    @IBOutlet weak var tweetsCountLabel: UILabel!
    
    var tweets: [Tweet]!
    var feedSize: Int = 20
    var user: User?
    
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
        
        print("user: \(user)")
        if(user == nil){
            user = User.currentUser
        }

        self.nameLabel.text = user!.name
        self.usernameLabel.text = "@" + user!.username!
        self.profileImage.setImageWithURL(user!.profileImageUrl!)
        self.bioLabel.text = user!.bio
        self.followerCountLabel.text = String(user!.followerCount)
        self.followingCountLabel.text = String(user!.followingCount)
        self.tweetsCountLabel.text = String(user!.tweetsCount)
        
        self.loadTweets()
        
        client.bannerImage(user!, success: { (bannerDictionary: NSDictionary) in
            if let sizeDictionary = bannerDictionary["sizes"] as? NSDictionary {
                if let mobileDictionary = sizeDictionary["web"] as? NSDictionary {
                    let bannerUrlString = mobileDictionary["url"] as? String
                    if let bannerUrlString = bannerUrlString {
                        let fixedString = bannerUrlString.stringByReplacingOccurrencesOfString("/web", withString: "")
                        let bannerUrl = NSURL(string: fixedString)
                        self.coverImage.setImageWithURL(bannerUrl!)
                    }
                }
            }
            
        }, failure: { (error: NSError) in
            print("\(error.localizedDescription)")
        })
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadTweets()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadTweets() {
        let client = TwitterClient.sharedInstance
        client.userTimeline(user!, success: { (tweets: [Tweet]) in
            self.tweets = tweets
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
        let oldTweet = cell.tweet
        
        cell.tweet = tweet
        cell.tweetLabel.text = tweet.text
        cell.nameLabel.text = tweet.name
        cell.usernameLabel.text = "@" + tweet.username!
        cell.profilePicture.setImageWithURL(tweet.profileImageUrl!)
        
        if(oldTweet == tweet) {
            if(tweet.retweetCount < cell.newRetweetCount){
                cell.retweetCountLabel.text = String(cell.newRetweetCount)
            } else if(tweet.retweetCount - 1 == cell.newRetweetCount) {
                cell.retweetCountLabel.text = String(cell.newRetweetCount)
            } else {
                cell.retweetCountLabel.text = String(tweet.retweetCount)
            }
            
            if(tweet.favoriteCount < cell.newFavoriteCount){
                cell.favoriteCountLabel.text = String(cell.newFavoriteCount)
            } else if(tweet.favoriteCount - 1 == cell.newFavoriteCount) {
                cell.favoriteCountLabel.text = String(cell.newFavoriteCount)
            } else {
                cell.favoriteCountLabel.text = String(tweet.favoriteCount)
            }
            
            if(cell.favorited == true) {
                cell.favoriteImage.image = UIImage(imageLiteral: "like-red")
            } else if(cell.favorited == false) {
                cell.favoriteImage.image = UIImage(imageLiteral: "favorite")
            } else {
                if(tweet.favorited == true) {
                    cell.favoriteImage.image = UIImage(imageLiteral: "like-red")
                } else {
                    cell.favoriteImage.image = UIImage(imageLiteral: "favorite")
                }
            }
            
            if(cell.retweeted == true) {
                cell.retweetImage.image = UIImage(imageLiteral: "retweet-green")
            } else if(cell.retweeted == false) {
                cell.retweetImage.image = UIImage(imageLiteral: "retweet-large")
            } else {
                if(tweet.retweeted == true) {
                    cell.retweetImage.image = UIImage(imageLiteral: "retweet-green")
                } else {
                    cell.retweetImage.image = UIImage(imageLiteral: "retweet-large")
                }
            }
        } else {
            cell.retweetCountLabel.text = String(tweet.retweetCount)
            cell.favoriteCountLabel.text = String(tweet.favoriteCount)
            if(tweet.retweeted == true) {
                cell.retweetImage.image = UIImage(imageLiteral: "retweet-green")
            } else {
                cell.retweetImage.image = UIImage(imageLiteral: "retweet-large")
            }
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d y"
        cell.timestampLabel.text = formatter.stringFromDate(tweet.timestamp!)
        
        return cell
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        loadTweets()
        tableView.reloadData()
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        loadTweets()
        tableView.reloadData()
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "detailSegue2"){
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets[indexPath!.row]
 
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.tweet = tweet
        }
    }

}
