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
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = tweet?.name
        usernameLabel.text = tweet?.username
        textLabel.text = tweet?.text

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
