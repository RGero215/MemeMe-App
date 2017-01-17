//
//  MemeCollectionViewController.swift
//  MemeMe App
//
//  Created by Ramon Geronimo on 1/9/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MemeCollectionViewController: UICollectionViewController {
    
    var memes = [Meme]()
    
    var selectedMemes = [NSIndexPath]()
    var editingMode = false
    var editButton: UIBarButtonItem!
    var addDeleteButton: UIBarButtonItem!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBOutlet var memeCollectionView: UICollectionView!
    
    private var currentIndexPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let interSpace: CGFloat = 3.0
        let lineSpace: CGFloat = 3.0
        let widthDimension = (view.frame.size.width - (3 * interSpace)) / 4.0
        let heightDimension = (view.frame.size.height - (5 * interSpace)) / 6.0
        let dimension = min(widthDimension, heightDimension)
        
        flowLayout.minimumInteritemSpacing = interSpace
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
      
        memeCollectionView.allowsMultipleSelection = true
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: memeCollectionView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        memeCollectionView.reloadData()
        setDefaultUIState()
    }
    
    func setDefaultUIState () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //  Initialize and add the edit/add buttons
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.didTapEdit(sender:)))
            addDeleteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.launchEditor(sender:)))
        
        navigationItem.rightBarButtonItem = addDeleteButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.leftBarButtonItem?.isEnabled = appDelegate.memes.count > 0
        
        // Cycle through each cell and index in selectMemes array to deselect and reinitialize
        for index in selectedMemes {
            memeCollectionView.deselectItem(at: index as IndexPath, animated: true)
            let cell = memeCollectionView.cellForItem(at: index as IndexPath) as! MemeCollectionViewCell
            cell.isSelected = false
        }
        
        // Remove all items from the selected Memes array and reset layout
        selectedMemes.removeAll()
        memeCollectionView.reloadData()
        
        editingMode = false
        
        // If there are no saved memes, present the meme creator
        if appDelegate.memes.count == 0 {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
    }
    
    func didTapEdit(sender: UIBarButtonItem?) {
        editingMode = !editingMode
        
        // If editing, change edit button to done and add button to trash
        if editingMode {
            
            editButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.didTapEdit(sender:)))
            navigationItem.leftBarButtonItem = editButton
            
            // Set right bar button item and disable it until an item is selected
            addDeleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.alertBeforeDeleting(sender:)))
            navigationItem.rightBarButtonItem = addDeleteButton
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            // If no longer editing, reitialize UI to base layout
            setDefaultUIState()
        }
    }
    
    // Launch the Meme editor with cancel/share button enabled
    func launchEditor(sender: AnyObject){
        let object: AnyObject = storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController")
        let editMemeVC = object as! MemeEditorViewController
        
        present(editMemeVC, animated: true, completion: {
            
        })
    }
    
    
    func deleteSelectedMemes(sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let indexPaths = memeCollectionView.indexPathsForSelectedItems! as [IndexPath]
        var selectedMemes = [Meme]()
        // Create temporary array of selected items.
        for indexPath in indexPaths{
            selectedMemes.append(appDelegate.memes[indexPath.row])
        }
        
        // Find objects from temporary array in data source and delete them.
        appDelegate.memes = appDelegate.memes.filter { !selectedMemes.contains($0) }
        setDefaultUIState()
        memes = appDelegate.memes
        memeCollectionView.reloadData()
        
        
    }
    
    // Alert the user before deletion, giving the opportunity to cancel
    func alertBeforeDeleting(sender: AnyObject) {
        let ac = UIAlertController(title: "Delete Selected Memes", message: "Are you SURE that you want to delete the selected Memes?", preferredStyle: .alert)
        
        // Configure the alert actions
        let deleteAction = UIAlertAction(title: "Delete!", style: .destructive, handler: {
            action in self.deleteSelectedMemes(sender: sender)
        })
        
        let stopAction = UIAlertAction(title: "Keep Them", style: .default, handler: {
            action in self.setDefaultUIState()
        })
        
        // Add actions then present alert
        ac.addAction(deleteAction)
        ac.addAction(stopAction)
        present(ac, animated: true, completion: nil)
    }

    

    @IBAction func addMeme(_ sender: Any) {
        let destination = storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController")
        let memeEditorVC = destination as! MemeEditorViewController
        
        present(memeEditorVC, animated: true, completion: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
    
        let meme = memes[indexPath.row].memedImage
        cell.memeImageView.image = meme
        
        if !editingMode {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        

    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! MemeCollectionViewCell
        
        if editingMode {
    
            addDeleteButton.isEnabled = true
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.blue.cgColor


        } else {
            
            
            let detailController = storyboard!.instantiateViewController(withIdentifier: "memeDetailView") as! MemeDetailView
            
            detailController.memeImage = memes[indexPath.row].memedImage
            navigationController!.pushViewController(detailController, animated: true)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MemeCollectionViewCell
        if memeCollectionView.indexPathsForSelectedItems?.count == 0 {
            //cell.isSelected = false
            addDeleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.alertBeforeDeleting(sender:)))
            navigationItem.rightBarButtonItem = addDeleteButton
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        cell.layer.borderColor = UIColor.clear.cgColor
        

    }
    
}

// 3D Touch
extension MemeCollectionViewController: UIViewControllerPreviewingDelegate {
    // Peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = memeCollectionView.indexPathForItem(at: location),  let cell = memeCollectionView.cellForItem(at: indexPath) as? MemeCollectionViewCell else {
            return nil
        }
        let identifier = "memeDetailView"
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: identifier) as? MemeDetailView else { return nil }
        
        detailVC.memeImage = cell.memeImageView.image
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    // Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
    }
    
    
    
}



