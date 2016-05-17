//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

class ViewController : UIViewController {
    
    // Views that need to be accessible to all methods
    let jsonResult = UILabel()
    var sol = 37 // to 1341
    var imageDisplay = UIImageView(image: nil)
    // If data is successfully retrieved from the server, we can parse it here
    func parseMyJSON(theData : NSData) {
        
        // Print the provided data
        print("")
        print("====== the data provided to parseMyJSON is as follows ======")
        print(theData)
        
        // De-serializing JSON can throw errors, so should be inside a do-catch structure
        do {
            
            // Do the initial de-serialization
            // Source JSON is here:
            // http://www.learnswiftonline.com/Samples/subway.json
            //
            let jsonData = try NSJSONSerialization.JSONObjectWithData(theData, options: NSJSONReadingOptions.AllowFragments)
            
            // Print retrieved JSON
            print("")
            print("====== the retrieved JSON is as follows ======")
            print(jsonData)
            
            // Now we can parse this...
            print("")
            print("Now, add your parsing code here...")
            
            
            
            if let names = jsonData as? [String : AnyObject] {
                print("Data Retrieved: \n \(names)")
                
                if let stations = names["photos"] as? [AnyObject] {
                    for station in stations {
                        print(station)
                        var urlValue = "ERROR"
                        urlValue = String(station["img_src"])
                        let range = urlValue.startIndex.advancedBy(9)..<urlValue.endIndex.advancedBy(-1)
                        let substringURL = urlValue[range]
                        print(substringURL)
                        if let url = NSURL(string: substringURL) {
                            if let data = NSData(contentsOfURL: url) {
                                imageDisplay.image = UIImage(data: data)
                                print("Image updated")
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
                self.jsonResult.text = "parsed JSON should go here"
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
                    print("")
                    print("====== data from the request follows ======")
                    print(data)
                    print("")
                    print("====== response codes from the request follows ======")
                    print(response)
                    print("")
                    print("====== errors from the request follows ======")
                    print(error)
            
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
        
        // Try to make a URL request object
        if let url = NSURL(string: address) {
            
            // We have an valid URL to work with
            print(url)
            
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
        jsonResult.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the superview
        view.addSubview(jsonResult)

        /*
         * Add a button
         */
        imageDisplay.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageDisplay)
        
        let getData = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        
        // Make the button, when touched, run the calculate method
        getData.addTarget(self, action: #selector(ViewController.getMyJSON), forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set the button's title
        getData.setTitle("Get my JSON!", forState: UIControlState.Normal)
        
        // Required to auto layout this button
        getData.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the button into the super view
        view.addSubview(getData)

        /*
         * Layout all the interface elements
         */
        
        // This is required to lay out the interface elements
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create an empty list of constraints
        var allConstraints = [NSLayoutConstraint]()
        
        // Create a dictionary of views that will be used in the layout constraints defined below
        let viewsDictionary : [String : AnyObject] = [
            "title": jsonResult,
            "getData": getData,
            "image": imageDisplay]
        
        // Define the vertical constraints
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-50-[getData]-[title]-[image]",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        
        // Add the vertical constraints to the list of constraints
        allConstraints += verticalConstraints
        
        // Activate all defined constraints
        NSLayoutConstraint.activateConstraints(allConstraints)
        
    }
    
}

// Embed the view controller in the live view for the current playground page
XCPlaygroundPage.currentPage.liveView = ViewController()
// This playground page needs to continue executing until stopped, since network reqeusts are asynchronous
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
