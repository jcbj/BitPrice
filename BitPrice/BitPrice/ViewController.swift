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
        
        self.buildHistoryLabels(self.getLastFiveDayPrice())
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
    
    /*
    http://api.coindesk.com/v1/bpi/historical/close.json?start=2015-07-15&end=2015-07-24&currency=CNY
    
    {
    "bpi": {
    "2015-07-15": 1756.5732,
    "2015-07-16": 1719.6188,
    "2015-07-17": 1723.7974,
    "2015-07-18": 1698.9991,
    "2015-07-19": 1686.3934,
    "2015-07-20": 1723.3102,
    "2015-07-21": 1702.5693,
    "2015-07-22": 1710.3503
    },
    "disclaimer": "This data was produced from the CoinDesk Bitcoin Price Index. BPI value data returned as CNY.",
    "time": {
    "updated": "Jul 23, 2015 09:53:17 UTC",
    "updatedISO": "2015-07-23T09:53:17+00:00"
    }
    }

    */
    
    func getLastFiveDayPrice() -> Array<(String, String)> {
        let curDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let startDate = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: -6, toDate: curDate, options: NSCalendarOptions.init(rawValue: 0))
        let endDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: curDate, options: NSCalendarOptions.init(rawValue: 0))
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let url = "http://api.coindesk.com/v1/bpi/historical/close.json?start=\(formatter.stringFromDate(startDate!))&end=\(formatter.stringFromDate(endDate!))&currency=CNY"
        
        var result = Array<(String,String)>()
        if let jsonData = NSData(contentsOfURL: NSURL(string: url)!) {
            let json = JSON(data: jsonData)
            let bpiDict:JSON = json["bpi"]
            for (key,val) in bpiDict {
                result.append((key,val.stringValue))
            }
        }
        
        return result
    }
    
    func buildHistoryLabels (priceList: Array<(String, String)>) {
        var count = 0.0
        
        let labelTitle = UILabel(frame: CGRectMake(CGFloat(30.0),CGFloat(250.0),CGFloat(200),CGFloat(30)))
        labelTitle.text = "历史价格"
        self.view.addSubview(labelTitle)
        
        for (date, price) in priceList {
            let labelHistory = UILabel(frame: CGRectMake(CGFloat(30.0),CGFloat(280 + count * 40),CGFloat(200.0),CGFloat(30.0)))
            labelHistory.text = "\(date) \(price)"
            self.view.addSubview(labelHistory)
            
            count++
        }
    }


}

