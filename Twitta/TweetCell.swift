//
//  TweetCell.swift
//  Twitta
//
//  Created by Daniela Gonzalez on 6/28/16.
//  Copyright © 2016 Daniela Gonzalez. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var retweetImage: UIImageView!
    
    var tweet: Tweet?
    var retweeted: Bool?
    var favorited: Bool?
    var newRetweetCount: Int = 0
    var newFavoriteCount: Int = 0
    let client = TwitterClient.sharedInstance
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        if(favorited == nil) {
            favorited = tweet?.favorited
        }
        if(favorited == false) {
            newFavoriteCount = Int(favoriteCountLabel.text!)! + 1
            client.favorite(tweet!.id!, success: { (favorite: NSDictionary) in
            }) { (error: NSError) in
                print("\(error.localizedDescription)")
            }
            self.favoriteImage.image = UIImage(imageLiteral: "like-red")
            favorited = true
        } else {
            newFavoriteCount = Int(favoriteCountLabel.text!)! - 1
            client.unfavorite(tweet!.id!, success: { (favorite: NSDictionary) in
            }) { (error: NSError) in
                print("\(error.localizedDescription)")
            }
            self.favoriteImage.image = UIImage(imageLiteral: "favorite")
            favorited = false
        }
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        if(retweeted == nil) {
            retweeted = tweet?.retweeted
        }
        if(retweeted == false) {
            newRetweetCount = Int(retweetCountLabel.text!)! + 1
            client.retweet(tweet!.id!, success: { (retweet: NSDictionary) in
            }) { (error: NSError) in
                print("\(error.localizedDescription)")
            }
            self.retweetImage.image = UIImage(imageLiteral: "retweet-green")
            retweeted = true
        } else {
            newRetweetCount = Int(retweetCountLabel.text!)! - 1
            client.unretweet(tweet!.id!, success: { (retweet: NSDictionary) in
            }) { (error: NSError) in
                print("\(error.localizedDescription)")
            }
            self.retweetImage.image = UIImage(imageLiteral: "retweet-large")
            retweeted = false
        }
    }
}
