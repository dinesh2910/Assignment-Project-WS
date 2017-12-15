//
//  ViewController.swift
//  WaresafeProject
//
//  Created by dinesh danda on 11/25/17.
//  Copyright © 2017 dinesh danda. All rights reserved.
//

import UIKit

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}

class ViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    
    var dataArray = [[String: String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.borderWidth = 3.0
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.borderWidth = 3.0
        setTextViewToDefault()
        getAllMessagesFromPlist()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTextViewToDefault()
    {
        messageTextView.textColor = UIColor.black
        messageTextView.text = "Enter Text Here...!"
        countLabel.text = "0"
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        if let textString = textView.text
        {
            if textString == "Enter Text Here...!"
            {
                textView.text = ""
                messageTextView.textColor = UIColor.black
                
            }
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.characters.count + (text.characters.count - range.length) > 0{
            self.saveButton.isEnabled = true
        }
        else {
            self.saveButton.isEnabled = false
        }
        let charactersCount = textView.text.characters.count + (text.characters.count - range.length)
        if (charactersCount <= 140)
        {
            countLabel.text = "\(charactersCount)"
            
        }
        return charactersCount <= 140
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        if let message = messageTextView.text
        {
            saveMessageToPlist(message: message)
            
        }
        setTextViewToDefault()
        messageTextView.resignFirstResponder()
        
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        setTextViewToDefault()
        messageTextView.resignFirstResponder()
    }
    
    func saveMessageToPlist(message: String)
    {
        let regex = try! NSRegularExpression(pattern: "[<>/:&+%;\"]|\\.\\w{2,4}", options: [.caseInsensitive])
        
        let range = NSRange(location: 0, length: message.characters.count)
        
        let htmlLessString: String = regex.stringByReplacingMatches(in: message, options: NSRegularExpression.MatchingOptions(), range:range, withTemplate: "")
        
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        
        var tempDictionary = [String: String]()
        
        tempDictionary["Time"] = timestamp
        tempDictionary["Message"] = htmlLessString
        dataArray.append(tempDictionary)
        
        let cocoaArray : NSArray = dataArray as NSArray
        cocoaArray.write(toFile: getPlistFilePath(), atomically: true)
        messageTableView.reloadData()
    }
    
    func getAllMessagesFromPlist()
    {
        if let cocoaArray: NSArray = NSArray.init(contentsOfFile: getPlistFilePath())
        {
            dataArray = cocoaArray as! [[String: String]]
        }
    }
    
    func getPlistFilePath() -> String{
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = paths.stringByAppendingPathComponent(path: "MyData.plist")
        return path
    }
    
    func deleteMessageAtIndex(index: Int){
        dataArray.remove(at: index)
        let cocoaArray : NSArray = dataArray as NSArray
        cocoaArray.write(toFile: getPlistFilePath(), atomically: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataArray.count
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        let dictionary = dataArray[indexPath.row]
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.text = dictionary["Message"]
        cell.detailTextLabel?.text = dictionary["Time"]
        cell.detailTextLabel?.textColor = UIColor.blue
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            deleteMessageAtIndex(index: indexPath.row)
            messageTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}

