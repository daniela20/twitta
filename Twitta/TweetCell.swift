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
    
    var tweet: Tweet?
    var retweetable: Bool = true
    var newCount: Int = 0
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
        client.favorite(tweet!.id!, success: { (favorite: NSDictionary) in
        }) { (error: NSError) in
            print("\(error.localizedDescription)")
        }
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        if(retweetable == true) {
            newCount = tweet!.retweetCount + 1
            client.retweet(tweet!.id!, success: { (retweet: NSDictionary) in
            }) { (error: NSError) in
                print("\(error.localizedDescription)")
            }
        } else {
            print("already retweeted")
        }
    }

}
