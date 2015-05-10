//
//  MemeEditorViewController.swift
//  mmTest
//
//  Created by William Song on 4/27/15.
//  Copyright (c) 2015 Bill Song. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var memes = [Meme]()
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSStrokeWidthAttributeName : NSNumber(float: -4.0),
        
    ]
    
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.enabled = false
        cancelButton.enabled = false
        textFieldDefalults(topTextField)
        textFieldDefalults(bottomTextField)
        
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
    }
    
    func textFieldDefalults(textField: UITextField) {
        //set textfield defualts
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
        textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
    }
    
    @IBAction func canelImage(sender: AnyObject) {
        confirm()
    }
    
    func confirm() {
        
        //initiate object and load data
        let object = UIApplication.sharedApplication().delegate as! AppDelegate
        let appDelegate = object as AppDelegate
        
        memes = appDelegate.memes
       
        if memes.count > 0 {
            
            //send to sent meme view
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            
            //no sent meme yet, create new meme
            let alertController = UIAlertController(title: "Warning", message: "You haven't sent any memes yet", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Create Meme", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
          
        }
        
    }

    @IBAction func shareImage(sender: AnyObject) {
        
        //calling stock function with activityview controller, save selection image and sent user to sent meme view
        let textToShare = "Swift is awesome!  Check out this awesome picture attached!"
        let mmImage = generateMemedImage()
        let objectsToShare = [textToShare,  mmImage]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = {
            activivity, completed, returnd, error in
            
            if completed {
                
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }

        }
        
        self.presentViewController(activityVC, animated: true, completion: nil)

        directToSentMeme()
        
    }
    @IBAction func chooseFromAlbum(sender: AnyObject) {
        var imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true,completion: nil)
    }
    
    
    @IBAction func chooseFromCamera(sender: AnyObject) {
        var imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true,completion: nil)
        
    }
    //calling imagepickcontroller, select image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
            shareButton.enabled = true
            cancelButton.enabled = true
        }
    }
    
    //keyboard management routines
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:") , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.editing{
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.editing {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        //get keybord height
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        if bottomTextField.editing{
            return keyboardSize.CGRectValue().height
        }
        else{
            return 0
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //return textfield
        textField.resignFirstResponder()
        return true
    }
    
    func directToSentMeme() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("TableView") as! UIViewController!

        presentViewController(vc, animated: true, completion: nil)
    }
    
    func save() {
        //Create the meme
        var meme = Meme(topText: topTextField.text,  bottomText: topTextField.text,
            orginalImage: imageView.image!, memedImage: generateMemedImage())
        
        // Add it to the memes array in the Application Delegate
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        topBar.hidden = true
        bottomBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //  Show toolbar and navbar
        topBar.hidden = false
        bottomBar.hidden = false
        
        return memedImage
    }

}

