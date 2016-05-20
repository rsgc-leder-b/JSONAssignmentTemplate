//
//  ViewController.swift
//  Mars Curiosity Browser
//
//  Created by Brendan Leder on 2016-05-20.
//  Copyright © 2016 Brendan Leder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Views that need to be accessible to all methods
    var sol = 37 // to 1341
    var isUpdate : Bool = true
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var getData: UIButton!
    @IBOutlet weak var jsonResult: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var textSol: UITextField!

    // If data is successfully retrieved from the server, we can parse it here
    func parseMyJSON(theData : NSData) {
        var myImage = UIImage(named: " ")
        var scaledImage = UIImage(named: " ")
        
        // Print the provided data
        /*
         print("")
         print("====== the data provided to parseMyJSON is as follows ======")
         print(theData)
         */
        
        // De-serializing JSON can throw errors, so should be inside a do-catch structure
        do {
            
            // Do the initial de-serialization
            // Source JSON is here:
            // http://www.learnswiftonline.com/Samples/subway.json
            //
            let jsonData = try NSJSONSerialization.JSONObjectWithData(theData, options: NSJSONReadingOptions.AllowFragments)
            
            // Print retrieved JSON
            /*
             print("")
             print("====== the retrieved JSON is as follows ======")
             print(jsonData)
             
             // Now we can parse this...
             print("")
             print("Now, add your parsing code here...")
             */
            
            
            if let names = jsonData as? [String : AnyObject] {
                //  print("Data Retrieved: \n \(names)")
                
                if let stations = names["photos"] as? [AnyObject] {
                    for station in stations {
                        //        print(station)
                        var urlValue = "ERROR"
                        urlValue = String(station["img_src"])
                        let range = urlValue.startIndex.advancedBy(9)..<urlValue.endIndex.advancedBy(-1)
                        let substringURL = urlValue[range]
                        //      print(substringURL)
                        if let url = NSURL(string: substringURL) {
                            if let data = NSData(contentsOfURL: url) {
                                myImage = UIImage(data: data)
                                let size = CGSizeApplyAffineTransform(myImage!.size, CGAffineTransformMakeScale(0.37, 0.5))
                                let hasAlpha = false
                                let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
                                
                                UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                                myImage!.drawInRect(CGRect(origin: CGPointZero, size: size))
                                
                                scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                                UIGraphicsEndImageContext()
                                
                            }
                        }
                    }
                } else {
                    print("Error")
                }
                
                //            for name in names {
                //                print(name)
                //                if let asDict = name as? [String : String] {
                //                    asDict
                //                    for (a, b) in asDict {
                //                        print(a + ":" + b)
                //                    }
                //                }
                //            }
            }
            
            
            
            // Now we can update the UI
            // (must be done asynchronously)
            dispatch_async(dispatch_get_main_queue()) {
                
                self.imageDisplay.image = myImage
                self.jsonResult.text = "Current Sol: \(self.sol-36)"
                self.isUpdate = true
            }
            
        } catch let error as NSError {
            print ("Failed to load: \(error.localizedDescription)")
        }
        
        
    }
    
    // Set up and begin an asynchronous request for JSON data
    func getMyJSON() {
        
        // Define a completion handler
        // The completion handler is what gets called when this **asynchronous** network request is completed.
        // This is where we'd process the JSON retrieved
        let myCompletionHandler : (NSData?, NSURLResponse?, NSError?) -> Void = {
            
            (data, response, error) in
            
            // This is the code run when the network request completes
            // When the request completes:
            //
            // data - contains the data from the request
            // response - contains the HTTP response code(s)
            // error - contains any error messages, if applicable
            
            // Cast the NSURLResponse object into an NSHTTPURLResponse objecct
            if let r = response as? NSHTTPURLResponse {
                
                // If the request was successful, parse the given data
                if r.statusCode == 200 {
                    
                    // Show debug information (if a request was completed successfully)
                    /*
                     print("")
                     print("====== data from the request follows ======")
                     print(data)
                     print("")
                     print("====== response codes from the request follows ======")
                     print(response)
                     print("")
                     print("====== errors from the request follows ======")
                     print(error)
                     */
                    if let d = data {
                        
                        // Parse the retrieved data
                        self.parseMyJSON(d)
                        
                    }
                    
                }
                
            }
            
        }
        
        // Define a URL to retrieve a JSON file from
        var address : String = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol="
        address += String(sol)
        address += "&camera=fhaz&page=1&api_key=geXGSU2AeU5dzwzEK9lsbWqNab0mNIQVWUlMf5zt"
        //https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=37&camera=fhaz&page=1&api_key=geXGSU2AeU5dzwzEK9lsbWqNab0mNIQVWUlMf5zt
        
        if let url = NSURL(string: address) {
            
            // We have an valid URL to work with
            //print(url)
            
            // Now we create a URL request object
            let urlRequest = NSURLRequest(URL: url)
            
            // Now we need to create an NSURLSession object to send the request to the server
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            // Now we create the data task and specify the completion handler
            let task = session.dataTaskWithRequest(urlRequest, completionHandler: myCompletionHandler)
            
            // Finally, we tell the task to start (despite the fact that the method is named "resume")
            task.resume()
            
        } else {
            
            // The NSURL object could not be created
            print("Error: Cannot create the NSURL object.")
            
        }
        
    }
    
    func addSol() {
        if (isUpdate) {
            isUpdate = false
            if (sol < 1341) {
                sol++
                getMyJSON()
            } else {
                self.jsonResult.text = "Sol cannot go above 1305"
            }
        } else {
            self.jsonResult.text = "Wait for picture update"
        }
    }
    
    func textConvert() {
        if self.textSol.text?.isEmpty == false {
            let solVal : Int = Int(self.textSol.text!)! + 36
            if solVal > 36 && solVal < 1342 {
                sol = solVal
                getMyJSON()
            }
        }
    }
    
    func subSol() {
        if (isUpdate) {
            isUpdate = false
            if (sol > 37) {
                sol--
                getMyJSON()
            } else {
                self.jsonResult.text = "Sol cannot go below 1"
            }
        } else {
            self.jsonResult.text = "Wait for picture update"
        }
    }
    
    // This is the method that will run as soon as the view controller is created
    override func viewDidLoad() {
        
        // Sub-classes of UIViewController must invoke the superclass method viewDidLoad in their
        // own version of viewDidLoad()
        super.viewDidLoad()
        
        // Make the view's background be gray
        view.backgroundColor = UIColor.lightGrayColor()
        
        /*
         * Further define label that will show JSON data
         */
        
        // Set the label text and appearance
        jsonResult.text = "..."
        jsonResult.font = UIFont.systemFontOfSize(12)
        jsonResult.numberOfLines = 0   // makes number of lines dynamic
        // e.g.: multiple lines will show up
        jsonResult.textAlignment = NSTextAlignment.Center
        
        // Required to autolayout this label
        //jsonResult.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the superview
        //view.addSubview(jsonResult)
        
        /*
         * Add a button
         */
        imageDisplay.frame = CGRect(x: 10, y: 150, width: 100, height: 100)
        imageDisplay.contentMode = .ScaleAspectFit
        imageDisplay.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageDisplay)
        
        
        minusButton.addTarget(self, action: #selector(ViewController.subSol), forControlEvents: UIControlEvents.TouchUpInside)
        minusButton.setTitle("Remove Sol", forState: UIControlState.Normal)
        //minusButton.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(minusButton)
        
        textSol.borderStyle = UITextBorderStyle.RoundedRect
        textSol.font = UIFont.systemFontOfSize(15)
        textSol.placeholder = "                "
        textSol.backgroundColor = UIColor.whiteColor()
        textSol.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        //textSol.translatesAutoresizingMaskIntoConstraints = false
        textSol.addTarget(self, action: #selector(ViewController.textConvert), forControlEvents: .EditingChanged)
        //view.addSubview(textSol)
        
        
        
        
        // Make the button, when touched, run the calculate method
        getData.addTarget(self, action: #selector(ViewController.addSol), forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set the button's title
        getData.setTitle("Add Sol", forState: UIControlState.Normal)
        
        // Required to auto layout this button
        //getData.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the button into the super view
        //view.addSubview(getData)
        
        /*
         * Layout all the interface elements
         */
        
        // This is required to lay out the interface elements
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create an empty list of constraints
        var allConstraints = [NSLayoutConstraint]()
        
        // Create a dictionary of views that will be used in the layout constraints defined below
        let viewsDictionary : [String : AnyObject] = [
            //"title": jsonResult,
            //"getData": getData,
            //"minBut": minusButton,
            //"textIn": textSol,
            "image": imageDisplay]
        
        // Define the vertical constraints
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-25-[image]",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        
        // Add the vertical constraints to the list of constraints
        allConstraints += verticalConstraints
        
        // Activate all defined constraints
        NSLayoutConstraint.activateConstraints(allConstraints)
 
        getMyJSON()
    }
    
}

