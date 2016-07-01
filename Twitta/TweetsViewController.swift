//
//  TweetsViewController.swift
//  Twitta
//
//  Created by Daniela Gonzalez on 6/28/16.
//  Copyright © 2016 Daniela Gonzalez. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet]!
    var feedSize: Int = 20
    
    @IBAction func onImageClick(sender: AnyObject) {
        
    }
    
    @IBAction func onComposeClick(sender: AnyObject) {
        self.performSegueWithIdentifier("composeSegue", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        loadTweets()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        // Do any additional setup after loading the view.
    }
    
    func loadTweets() {
        let client = TwitterClient.sharedInstance
        client.homeTimeline({ (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }) { (error: NSError) in
            print("\(error.localizedDescription)")
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadTweets()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
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
        //print("loading tweets")
        loadTweets()
        tableView.reloadData()
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        //print("loading tweets")
        loadTweets()
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "detailSegue"){
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets[indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.tweet = tweet
        } else if(segue.identifier == "profileSegue"){
            let cell = sender!.superview!!.superview as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets[indexPath!.row]
            
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = tweet.user!
        }
    }

}
