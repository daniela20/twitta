//
//  DetailViewController.swift
//  Twitta
//
//  Created by Daniela Gonzalez on 6/30/16.
//  Copyright © 2016 Daniela Gonzalez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var retweetImage: UIImageView!
    @IBOutlet weak var replyImage: UIImageView!
    
    var tweet: Tweet?
    var retweeted: Bool?
    var favorited: Bool?
    let client = TwitterClient.sharedInstance
    var newRetweetCount: Int?
    var newFavoriteCount: Int?
    var favoriteCount: Int!
    var retweetCount: Int!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var boxView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = tweet?.name
        usernameLabel.text = "@" + (tweet?.username)!
        textLabel.text = tweet?.text
        profileImage.setImageWithURL((tweet?.profileImageUrl)!)
        favoriteCountLabel.text = String(favoriteCount)
        retweetCountLabel.text = String(retweetCount)
        timestampLabel.text = tweet?.timeString
        
        boxView.layer.borderColor = UIColor(white: 0.74, alpha: 1.0).CGColor
        boxView.layer.borderWidth = 1
        
        if(favorited == true) {
            favoriteImage.image = UIImage(imageLiteral: "like-red")
        } else {
            favoriteImage.image = UIImage(imageLiteral: "favorite")
        }
        
        if(retweeted == true) {
            retweetImage.image = UIImage(imageLiteral: "retweet-green")
        } else {
            retweetImage.image = UIImage(imageLiteral: "retweet-large")
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        retweetCountLabel.text = String(newRetweetCount!)
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
        favoriteCountLabel.text = String(newFavoriteCount!)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "profileSegue2"){
            
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = tweet!.user
        }
    }
    

}
