//
//  ComposeViewController.swift
//  Twitta
//
//  Created by Daniela Gonzalez on 6/30/16.
//  Copyright © 2016 Daniela Gonzalez. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var charCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        profileImage.setImageWithURL((User.currentUser?.profileImageUrl)!)
        
        buttonView.layer.borderColor = UIColor(white: 0.74, alpha: 1.0).CGColor
        buttonView.layer.borderWidth = 1
        
        tweetButton.layer.cornerRadius = 7

        // Do any additional setup after loading the view.
    }
    
    func textViewDidChange(textView: UITextView) {
        let chars = 140 - textField.text.characters.count
        charCountLabel.text = String(chars)
        if(chars < 11) {
            charCountLabel.textColor = UIColor.redColor()
        } else {
            charCountLabel.textColor = UIColor(white: 0.74, alpha: 1.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTweet(sender: AnyObject) {
        if(textField.text.characters.count > 0) {
            let client = TwitterClient.sharedInstance
            let encodedText = textField.text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            print(encodedText)
            client.tweet(encodedText!, success: { (response: NSDictionary) in
                print("success")
            }) { (error: NSError) in
                print("\(error.localizedDescription)")
            }
            self.dismissViewControllerAnimated(true) {
            }
        }
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
