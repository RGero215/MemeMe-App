//
//  ViewController.swift
//  MemeMe App
//
//  Created by Ramon Geronimo on 11/16/16.
//  Copyright © 2016 Ramon Geronimo. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // TextField
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    // Image
    @IBOutlet weak var imagePickerView: UIImageView!
    
    // Top Bar
    @IBOutlet weak var navigationBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    // Buttom Bar
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    var meme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let existingMeme = meme {
            // Existing meme. Use self.meme
            setupTextField(string: existingMeme.top, textField: topTextField)
            setupTextField(string: existingMeme.bottom, textField: bottomTextField)
            imagePickerView.image = existingMeme.image
            shareButton.isEnabled = true
        } else {
            // New meme. self.meme is not used
            setupTextField(string: "TOP", textField: topTextField)
            setupTextField(string: "BOTTOM", textField: bottomTextField)
            shareButton.isEnabled = false
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    @IBAction func btnShare(_ sender: UIBarButtonItem) {
        let memedImage = generateImage()
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activity.completionWithItemsHandler = {(activityType: UIActivityType?, completed:Bool, returnedItems:[Any]?, error: Error?) in       
            if completed {
                self.save(memedImage)
                activity.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activity, animated: true, completion: nil)
    }
        

    
    @IBAction func pickAnImage(_ sender: AnyObject) {
        imageOfType(.photoLibrary)

    }
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        setupTextField(string: "TOP", textField: topTextField)
        setupTextField(string: "BOTTOM", textField: bottomTextField)
        imagePickerView.image = nil
        shareButton.isEnabled = false
        let destination = storyboard!.instantiateViewController(withIdentifier: "SentMemesControllers")
        let memeEditorVC = destination as! UITabBarController
        
        present(memeEditorVC, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: AnyObject) {
        imageOfType(.camera)
    }
    
    
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
            shareButton.isEnabled = true
        }

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Setup Text
    func setupTextField(string: String, textField: UITextField) {
        let textFieldAtributes : [String : Any] = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3
        ]
        
        textField.text = string
        textField.defaultTextAttributes = textFieldAtributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    //Keyboard notification
    func subscribeToKeyboardNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y =  0 
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // TextField Delegate
    
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.text = ""
            
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    
    
    //Present image picker 
    func imageOfType(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func toolBarVisible(_ visible:Bool) {
        toolBar.isHidden = !visible
        navigationBar.isHidden = !visible
    }
    
    func generateImage() -> UIImage {
        toolBarVisible(false)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBarVisible(true)
        
        return memedImage
    }
    
    // Save Meme
    func save(_ memedImage: UIImage) {
        if var existingMeme = meme {
            existingMeme.top = topTextField.text!
            existingMeme.bottom = bottomTextField.text!
            existingMeme.image = imagePickerView.image!
            existingMeme.memedImage = memedImage
        } else {
            let meme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imagePickerView.image!, memedImage: memedImage)
            //MemeManager.sharedInstance.appendMeme(meme)
            
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
        }
        
        
    }
    
    
}

extension UIImagePickerController {
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.landscape, .portrait]
    }
    
}


