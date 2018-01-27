//
//  FinallyViewController.swift
//  PlayFile
//
//  Created by BlakeWu on 2018/1/20.
//  Copyright © 2018年 Syed Haris Ali. All rights reserved.
//

import UIKit

class FinallyViewController: UIViewController {
    
    @IBOutlet weak var allTimeLabel: UILabel!
    @IBOutlet weak var currentTimePosLabel: UILabel!
    @IBOutlet weak var currentLargestVolLabel: UILabel!
    @IBOutlet weak var currentHighestFLabel: UILabel!
    @IBOutlet weak var currentLowestFLabel: UILabel!
    @IBOutlet weak var secondSlider: UISlider!
    
    var myInt:Int = 0
    
    var myBigFloat:[Float] = [0]
    override func viewDidLoad() {
        super.viewDidLoad()
        var app:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        print(myBigFloat.count)
        // Do any additional setup after loading the view.
        self.secondSlider.maximumValue = Float(myBigFloat.count)/44100;
        let acBigCount = Int(Float(myBigFloat.count)/44100)
        self.secondSlider.minimumValue = 0;
        self.secondSlider.addObserver(self, forKeyPath: "value", options: .new, context: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        let sInt:Int = self.myBigFloat.count/44100 + 1
        self.allTimeLabel.text = String(format: "%ds", arguments: [sInt])
        self.secondSlider.setValue(0, animated: true)
        self.updateAndReCalculate(newValue: 0.0);
    }
    deinit {
        self.secondSlider.removeObserver(self, forKeyPath: "value")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object is UISlider){
            if (keyPath == "value"){
                updateAndReCalculate(newValue: self.secondSlider.value)
            }
        }
    }
    
    func updateAndReCalculate(newValue:Float){
        self.myInt = Int(newValue)
        // 0.0~0.99 就是0
        // 假如说是一个3.75秒的就是3.00~3.75归为3的。计算上也不太一样。
        let startGroupIndex:Int = self.myInt
        let endGroupIndex:Int = self.myInt + 1
        let startIndex:Int = 44100*startGroupIndex
        let endIndex:Int = ((44100*endGroupIndex) > (myBigFloat.count)) ? (myBigFloat.count) : (44100*endGroupIndex)
        
        
        
        
        var tmpLargest:Float = 0
        
        
        // pos
        
        var avg:Float = 0
        // 其实int的话即使是44100的采样频率，也够用13个小时以上。
        var flag:Bool = true // 正在找正的最大的
        var tmp:Float = 0
        var tmpIndex:Int = 0
        var resultIndexArr:[Int] = []
        var resultArr:[Float] = []
        
        for i in startIndex..<endIndex{
            avg += abs(self.myBigFloat[i])
            let itemV = self.myBigFloat[i]
        }
        avg /= Float(1 + endIndex - startIndex)
        let criticalValue:Float = avg * 0.01
        for i in startIndex..<endIndex{
//            avg += self.myBigFloat[i]
            let itemV = self.myBigFloat[i]
            if (itemV < criticalValue && itemV > -criticalValue){
                continue
            }
            if (tmp == itemV){
                continue
            }
            if (tmpIndex == i){
                continue
            }
            if (flag){
                if (itemV < 0){
                    resultIndexArr.append(tmpIndex)
                    resultArr.append(tmp)
                    flag = !flag
                }else if (itemV > tmp){
                    tmp = itemV
                    tmpIndex = i
                }
            }
            else {
                if (itemV > 0){
                    resultIndexArr.append(tmpIndex)
                    resultArr.append(tmp)
                    flag = !flag
                }else if (itemV < tmp){
                    tmp = itemV
                    tmpIndex = i
                }
            }
        }
        var resultLR:Int = -1
        var resultSR:Int = Int.max
        
        if (resultIndexArr.count > 2){
            for tmpIndex in 0..<(resultIndexArr.count-1){
                // 算这一秒内最高频率和最低频率的
                // 一秒44100
                let minus:Int = resultIndexArr[tmpIndex+1] - resultIndexArr[tmpIndex]
                if (minus > 44100/60 || minus < 44100/2000){
                    continue
                }
                if minus < resultSR{
                    resultSR = minus
                }
                if minus > resultLR {
                    resultLR = minus
                }
                let bTmp:Float = abs(resultArr[tmpIndex])<abs(resultArr[tmpIndex+1]) ? resultArr[tmpIndex] : resultArr[tmpIndex+1]
                if (bTmp > tmpLargest){
                    tmpLargest = bTmp
                }
            }
        }
//        avg /= Float(endIndex-startIndex)
        var resultHF:Float = 0
        var resultLF:Float = 0
        if (resultLR != -1){
            // 长带j米，中带k米，求k
            // 长带占n个短带长度，中带占m个短带长度
            // 长带占多少个中带 = 长带长度 / 中带长度
            resultLF = 44100.0/Float(resultLR)
        }
        if (resultSR != Int.max){
            resultHF = 44100.0/Float(resultSR)
        }
        self.currentTimePosLabel.text = String(format: "%ds", arguments: [self.myInt])
        self.currentLowestFLabel.text = String(format: "%f", arguments: [resultLF])
        self.currentHighestFLabel.text = String(format: "%f", arguments: [resultHF])
        self.currentLargestVolLabel.text = String(format: "%f", arguments: [tmpLargest/1000])
    }
    
    public func getTayTay(man:[Any]){
        for item in man{
            var tmp:Float = item as!Float
            tmp *= 100000
            myBigFloat.append(tmp)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        let tmp = segue.destination as! FinallyViewController
//        tmp.getTayTay(man: NSArray(array: [1,2,3]))
    }
 

}
