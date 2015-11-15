//
//  ViewController.swift
//  BitPrice
//
//  Created by jiangchao on 15/11/9.
//  Copyright © 2015年 jiangchao. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var differLabel: UILabel!
    var lastPrice:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.reloadPrice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadPrice () {
        let price = self.getLastPrice()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("reloadPrice"), userInfo: nil, repeats: false)
            
            if let p = price {
                var nsPrice = p as NSString
                nsPrice = nsPrice.stringByReplacingOccurrencesOfString(",", withString: "")
                let doublePrice = nsPrice.doubleValue
                
                let differPrice = doublePrice - self.lastPrice
                self.lastPrice = doublePrice
                self.priceLabel.text = NSString(format: "¥ %.2f", doublePrice) as String
                
                if differPrice > 0 {
                    self.differLabel.textColor = UIColor.redColor()
                    self.priceLabel.textColor = UIColor.redColor()
                    self.differLabel.text = NSString(format: "+%.2f", differPrice) as String
                } else {
                    self.differLabel.textColor = UIColor.greenColor()
                    self.priceLabel.textColor = UIColor.greenColor()
                    self.differLabel.text = NSString(format: "%.2f", differPrice) as String
                }
            }
        })
    }
    
    func getLastPrice () -> String? {
        let url = "http://api.coindesk.com/v1/bpi/currentprice/CNY.json"
        
        if let jsonData = NSData(contentsOfURL: NSURL(string: url)!) {
            let json = JSON(data: jsonData)
            
            return json["bpi"]["CNY"]["rate"].stringValue
        } else {
            return nil;
        }
    }


}

