//
//  ViewController.swift
//  tipCaculator
//
//  Created by Yihan Xing on 3/7/16.
//  Copyright © 2016 yx. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController,UINavigationControllerDelegate {
var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var submitTR: UIButton!
    @IBOutlet weak var signOnBtn: UIButton!
    @IBOutlet weak var tipRate: UITextField!
    @IBOutlet weak var billAmt: UITextField!
    @IBOutlet weak var totalAmt: UILabel!
    @IBOutlet weak var tipAmt: UILabel!
    let defaults = NSUserDefaults.standardUserDefaults()
    @IBAction func onEndEditingBill(sender: AnyObject) {
        if var ba = billAmt.text, let tr=tipRate.text {
            ba=ba.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
            )
            if ba == "" {
                ba = "0"
                billAmt.text = ba;
            }
            tipAmt.text="\(Double(ba)! * Double(tr)!/100)";
            totalAmt.text="\(Double(ba)! * (1+Double(tr)!/100))";
        }
        else{
            //show alert
        }
    }
    
    
    @IBAction func onClickSignon(sender: AnyObject) {
        let authenticationContext = LAContext()
        var error:NSError?
        
        if !authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error){
             showAlertWithTitleAndMsg("Error", message: "This device does not have a TouchID sensor.")
        }
        authenticationContext.evaluatePolicy(
            .DeviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Please signon with touch id",
            reply: { [unowned self] (success, error) -> Void in
                
                if( success ) {
                    
                    // Fingerprint recognized
                    // Go to view controller
                    let delaytime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(delaytime,dispatch_get_main_queue()){
                    self.tipAmt.hidden=false
                    self.totalAmt.hidden=false
                    self.scanButton.hidden=false
                    self.signOnBtn.hidden=true
                    self.billAmt.enabled = true
                    self.tipRate.enabled = true
                    self.submitTR.hidden=false
                    }
                    self.showAlertWithTitleAndMsg("Congrats", message: "You are signed in and please enjoy the app")
                    
                }else {
                    
                    // Check if there is an error
                    if let error = error {
                        self.showAlertWithTitleAndMsg("Error", message: "\(error.localizedDescription) - Ahtentication failed - please try again!")
                        
                        
                    }
                    
                }
                
            })
    }
    
    @IBAction func onEndEditingTipRate(sender: AnyObject) {
        if let ba = billAmt.text, var tr=tipRate.text {
            let trimmedBa=ba.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
            )
            if tr == "" {
                tr = "0"
                tipRate.text = tr
            }
            tipAmt.text=calculateTips(Double(trimmedBa)!, tipRate: Double(tr)!)
            totalAmt.text=calculateTotal(Double(trimmedBa)!, tipRate: Double(tr)!)
        }
        else{
            //show alert
        }
        
    }
    @IBAction func onPressedButton(button: UIButton) {
        var tr:Double = 0.0;
        if button.tag == 0 {
            tr=15
            
        }else if button.tag == 1{
            tr=18
            
        }else{
            tr=20
        }
        tipRate.text="\(tr)";
        if let ba = billAmt.text{
            let trimmedBa=ba.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
            )
            tipAmt.text=calculateTips(Double(trimmedBa)!,tipRate: tr);
            totalAmt.text=calculateTotal(Double(trimmedBa)!, tipRate:tr);
        }
        else{
            //show alert
        }
        
    }
 
    @IBAction func scanReceipt(sender: AnyObject) {
        view.endEditing(true)
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
            message: nil, preferredStyle: .ActionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        let libraryButton = UIAlertAction(title: "Choose Existing",
            style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker,
                    animated: true,
                    completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        let cancelButton = UIAlertAction(title: "Cancel",
            style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        presentViewController(imagePickerActionSheet, animated: true,
            completion: nil)         }
    func calculateTips(bill: Double, tipRate: Double) -> String{
        let ta="\(bill * tipRate/100)";
        return ta;
    }
    func calculateTotal(bill: Double, tipRate: Double) -> String{
        let toa="\(bill * (1+tipRate/100))";
        return toa;
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tipAmt.hidden=true
        totalAmt.hidden=true
        scanButton.hidden=true
        billAmt.enabled = false;
        tipRate.enabled = false;
        submitTR.hidden=true;
          self.addDoneButtonOnKeyboard()
        if let avgTR = defaults.stringForKey("avgTR") {
           tipRate.text=avgTR
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlertWithTitleAndMsg( title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertVC.addAction(okAction)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.presentViewController(alertVC, animated: true, completion: nil)
            
        }
        
    }
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract()
        tesseract.language = "eng+fra"
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.charWhitelist = "01234567890"
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        billAmt.text = keepOnlyNumFromString(tesseract.recognizedText)
        removeActivityIndicator()
        onEndEditingBill(ViewController)
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        var items = [AnyObject]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items as! [UIBarButtonItem]
        doneToolbar.sizeToFit()
        
        self.billAmt.inputAccessoryView = doneToolbar
        self.tipRate.inputAccessoryView = doneToolbar
        
    }
    
    @IBAction func onSubmitTR(sender: AnyObject) {
        if billAmt.text == "0" {
           self.showAlertWithTitleAndMsg("O bill amount detected", message: "Please submit a real bill for tracking your tipping habbit")
            return
        }
        let uuid:String = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let dataPost :String="userid=\(uuid)&tr=\(tipRate.text!)"
        let endPoint : String =  "http://localhost:8080/user/addTR"
        request(dataPost, endpoint: endPoint, successHandler: {
            (response) in
            if response != "error"{
            //self.tipRate.text = response;
             self.defaults.setObject(response, forKey: "avgTR")
                if let avgTR = self.defaults.stringForKey("avgTR")
                {
                    let delaytime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    
                    dispatch_after(delaytime,dispatch_get_main_queue()){
                        self.tipRate.text = avgTR
                    }
                }
                
            }
            else{
                //TODO
            }
        });
    }
    func doneButtonAction()
    {
        self.billAmt.resignFirstResponder()
        self.tipRate.resignFirstResponder()
    }
    func request(data : String, endpoint : String, successHandler: (response: String) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: endpoint as String)!)
        request.HTTPMethod = "POST"
        let postString = data
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                self.showAlertWithTitleAndMsg("sorry", message: "error=\(error!.localizedDescription)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            //self.result = responseString as String!
            successHandler(response:responseString as String!);
            return
            
        }
        
        task.resume()
        
    }
    func keepOnlyNumFromString(text: String) -> String {
        let okayChars : Set<Character> =
        Set("1234567890.".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }

}
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
            let selectedPhoto = scaleImage(image, maxDimension: 640)
            
            addActivityIndicator()
        
            dismissViewControllerAnimated(true, completion: {
                self.performImageRecognition(selectedPhoto)
            })
    }
}

