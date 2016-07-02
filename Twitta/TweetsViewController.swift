//
//  TweetsViewController.swift
//  Twitta
//
//  Created by Daniela Gonzalez on 6/28/16.
//  Copyright © 2016 Daniela Gonzalez. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet]!
    var feedSize: Int = 20
    var reloading: Bool = false
    var isMoreDataLoading = false
    
    @IBAction func onComposeClick(sender: AnyObject) {
        self.performSegueWithIdentifier("composeSegue", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadTweets()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        // Do any additional setup after loading the view.
    }
    
    func loadTweets() {
        let client = TwitterClient.sharedInstance
        print("passing in feedSize \(feedSize)")
        client.homeTimeline(feedSize, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            self.isMoreDataLoading = false
        }) { (error: NSError) in
            print("\(error.localizedDescription)")
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        reloading = true;
        loadTweets()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        reloading = false;
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
        
        if(reloading == false && oldTweet != nil && oldTweet!.id == tweet.id) {
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
        
        cell.timestampLabel.text = tweet.timeString
        
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "detailSegue"){
            let cell = sender as! TweetCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets[indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.retweeted = cell.retweeted
            detailViewController.favorited = cell.favorited
            detailViewController.favoriteCount = Int(cell.favoriteCountLabel.text!)
            detailViewController.retweetCount = Int(cell.retweetCountLabel.text!)
            detailViewController.tweet = tweet
        } else if(segue.identifier == "profileSegue"){
            let cell = sender!.superview!!.superview as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets[indexPath!.row]
            
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = tweet.user!
        }
    }
    
    func loadMoreData() {
        if(feedSize < 200){
            feedSize += 5
        }
        loadTweets()
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                loadMoreData()
            }
        }
    }


}
