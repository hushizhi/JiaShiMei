//
//  AboutUsController.swift
//  Bike
//
//  Created by Joyo on 2017/7/5.
//  Copyright © 2017年 Joyo. All rights reserved.
//

import UIKit
import SWRevealViewController

class AboutUsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let revealVC = revealViewController() {
            revealVC.rearViewRevealWidth = 280
            navigationItem.leftBarButtonItem?.target = revealVC
            navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
