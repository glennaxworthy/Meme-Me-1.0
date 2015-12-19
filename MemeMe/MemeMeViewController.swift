//
//  MemeMeViewController.swift
//  MemeMe
//
//  Created by Glenn Axworthy on 12/2/15.
//  Copyright © 2015 Glenn Axworthy. All rights reserved.
//

import UIKit

class MemeMeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var imagePicker: UIImagePickerController! = nil

    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var captionBottom: UITextField!
    @IBOutlet weak var captionTop: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var memeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCaption(captionTop)
        setupCaption(captionBottom)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imageView.backgroundColor = UIColor.lightGrayColor() // contrast
        imageView.contentMode = .ScaleAspectFit
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // subscribe to keyboard show/hide notifications
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)

        setupButtons()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribe from keyboard show/hide notifications
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func activityCompletionHandler(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) {
        if completed {
            // compose meme and save components
            let memeImage = composeMemeImage()
            let memeData = MemeMeData(meme: memeImage, image: imageView.image!, captionTop: captionTop.text!, captionBottom: captionBottom.text!)
            MemeMeData.memes.append(memeData)
        }
    }

    func composeMemeImage() -> UIImage {
        resignEditing()

        UIGraphicsBeginImageContext(memeView.bounds.size)
        memeView.drawViewHierarchyInRect(memeView.bounds, afterScreenUpdates: true)
        let memeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return memeImage
    }

    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }

    func keyboardWillShow(notification: NSNotification) {
        if captionBottom.editing {
            // slide view up to edit bottom caption
            let userInfo = notification.userInfo!
            let stopFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
            view.frame.origin.y -= stopFrame!.size.height // works ONLY for root!
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func resetEditor() {
        captionTop.tag = 0 // unedited
        captionTop.text = "TOP" // localize?
        captionTop.clearsOnBeginEditing = true
        captionBottom.tag = 0 // unedited
        captionBottom.text = "BOTTOM" // localize?
        captionBottom.clearsOnBeginEditing = true
        imageView.image = nil
    }

    func resignEditing() {
        captionTop.resignFirstResponder()
        captionBottom.resignFirstResponder()
    }

    func setupButtons() {
        actionButton.enabled = imageView.image != nil
        albumButton.enabled = true // always enabled
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        cancelButton.enabled = imageView.image != nil || captionTop.tag != 0 || captionBottom.tag != 0
    }
    
    func setupCaption(caption: UITextField) {
        caption.delegate = self
        caption.defaultTextAttributes = [
            NSFontAttributeName : UIFont(name: "Verdana-Bold", size: 36)!,
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSStrokeWidthAttributeName : -5]
        
        caption.textAlignment = .Center // IB setting is ignored
    }
    
    @IBAction func touchedActionButton(sender: UIBarButtonItem) {
        resignEditing()

        let memeImage = composeMemeImage()
        let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = activityCompletionHandler
        presentViewController(activityController, animated: true, completion: nil)
    }

    @IBAction func touchedAlbumButton(sender: UIBarButtonItem) {
        resignEditing()

        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func touchedCameraButton(sender: UIBarButtonItem) {
        resignEditing()

        imagePicker.sourceType = .Camera // throws if not available - simulator
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func touchedCancelButton(sender: UIBarButtonItem) {
        resignEditing()
        resetEditor()
        setupButtons()
    }

    // UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        actionButton.enabled = true
        cancelButton.enabled = true
        dismissViewControllerAnimated(true, completion: nil)
    }

    // UITextFieldDelegate

    func textFieldDidEndEditing(textField: UITextField) {
        setupCaption(textField) // re-apply lost attributes
        textField.clearsOnBeginEditing = false
        textField.tag = 1 // modified
        cancelButton.enabled = true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
