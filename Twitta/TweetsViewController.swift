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
            /*for tweet in tweets {
             print(tweet.text)
             }*/
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
        cell.tweet = tweet
        cell.tweetLabel.text = tweet.text
        cell.nameLabel.text = tweet.name
        cell.usernameLabel.text = "@" + tweet.username!
        cell.profilePicture.setImageWithURL(tweet.profileImageUrl!)
        
        if(tweet.retweetCount < cell.newCount && cell.retweetable == true) {
            cell.retweetCountLabel.text = String(tweet.retweetCount + 1)
            cell.retweetable = false
        } else {
            cell.retweetCountLabel.text = String(tweet.retweetCount)
        }
        
        cell.favoriteCountLabel.text = String(tweet.favoriteCount)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d HH:mm y"
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
