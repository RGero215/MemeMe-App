//
//  MemeTableViewController .swift
//  MemeMe App
//
//  Created by Ramon Geronimo on 1/9/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var memes = [Meme]()
    
    @IBOutlet weak var memeTableView: UITableView!
    var currentIndexPath: NSIndexPath!
    var selectedMemes = [NSIndexPath]()
    var editingMode = false
    var editButton: UIBarButtonItem!
    var addDeleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memeTableView.allowsMultipleSelectionDuringEditing = true
        memeTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: memeTableView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        navigationItem.leftBarButtonItem?.isEnabled = memes.count > 0
        memeTableView.reloadData()
        setDefaultUIState()
    }
    
    
    
    
    @IBAction func addMeme(_ sender: Any) {
        let destination = storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController")
        let memeEditorVC = destination as! MemeEditorViewController
        
        present(memeEditorVC, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! CustomTableViewCell
        
        let meme = memes[indexPath.row].memedImage
        let cellText = memes[indexPath.row].top + " " + memes[indexPath.row].bottom
        cell.tableImageView?.image = meme
        cell.tableLabel?.text = cellText
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 3
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedCell : [Int] = []
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! CustomTableViewCell
        if !memeTableView.isEditing {
            self.currentIndexPath = indexPath as NSIndexPath!
            self.performSegue(withIdentifier: "memeDetailView", sender: self)
            selectedCell.append(indexPath.row)
            
        } else {
            
            cell.isSelected = true
            addDeleteButton.isEnabled = true
            
        
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        
        if memeTableView.indexPathsForSelectedRows == nil {
            if !cell.isSelected {
                addDeleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.alertBeforeDeleting(sender:)))
                navigationItem.rightBarButtonItem = addDeleteButton
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "memeDetailView" {
            if let activityController = segue.destination as? MemeDetailView {
                activityController.memeImage = memes[currentIndexPath.row].memedImage
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        memeTableView.setEditing(editing, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
           
            // delete data and row
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes.remove(at: indexPath.row)
            memes = appDelegate.memes
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            
            
        }
    }
    
    
    func deleteSelectedMemes(sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let indexPaths = memeTableView.indexPathsForSelectedRows! as [IndexPath]
        var selectedMemes = [Meme]()
        // Create temporary array of selected items.
        for indexPath in indexPaths{
            selectedMemes.append(appDelegate.memes[indexPath.row])
        }
        
        // Find objects from temporary array in data source and delete them.
        appDelegate.memes = appDelegate.memes.filter { !selectedMemes.contains($0) }
        setDefaultUIState()
        memes = appDelegate.memes
        memeTableView.reloadData()
        
    }

    
    func setDefaultUIState () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //  Initialize and add the edit/add buttons
        
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.didTapEdit(sender:)))
        addDeleteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.launchEditor(sender:)))
        
        navigationItem.rightBarButtonItem = addDeleteButton
        navigationItem.leftBarButtonItem = editButton
        setEditing(false, animated: true)
        navigationItem.leftBarButtonItem?.isEnabled = appDelegate.memes.count > 0
        
        
        // Remove all items from the selected Memes array and reset layout
        selectedMemes.removeAll()
        memeTableView.reloadData()
        
        editingMode = false
    
    }
    
    
    func didTapEdit(sender: UIBarButtonItem?) {
        editingMode = !editingMode
        
        // If editing, change edit button to done and add button to trash
        if editingMode {
            setEditing(true, animated: true)
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
    
    func alertBeforeDeleting(sender: AnyObject) {
        let ac = UIAlertController(title: "Delete Selected Memes", message: "Are you SURE that you want to delete the selected Memes?", preferredStyle: .alert)
        
        // Configure the alert actions
        let deleteAction = UIAlertAction(title: "Delete!", style: .destructive, handler: {
            action in self.deleteSelectedMemes(sender: sender)
            print(self.selectedMemes.count)
        })
        
        let stopAction = UIAlertAction(title: "Keep Them", style: .default, handler: {
            action in self.setDefaultUIState()
        })
        
        // Add actions then present alert 
        ac.addAction(deleteAction)
        ac.addAction(stopAction)
        present(ac, animated: true, completion: nil)
    }
    
    func launchEditor(sender: AnyObject){
        let object: AnyObject = storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController")
        let editMemeVC = object as! MemeEditorViewController
        
        present(editMemeVC, animated: true, completion: {
        
        })
    }
}

class CustomTableViewCell : UITableViewCell {
    
    @IBOutlet weak var tableImageView: UIImageView!
    
    @IBOutlet weak var tableLabel: UILabel!

    
}

extension Meme: Equatable {
    static func == (lhs: Meme, rhs: Meme) -> Bool {
        return lhs.bottom == rhs.bottom && lhs.image == rhs.image && lhs.memedImage == rhs.memedImage && lhs.top == rhs.top
    }
}


// 3D touch
extension MemeTableViewController: UIViewControllerPreviewingDelegate {
    // Peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = memeTableView.indexPathForRow(at: location),  let cell = memeTableView.cellForRow(at: indexPath) as? CustomTableViewCell else {
            return nil
        }
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "memeDetailView") as? MemeDetailView else { return nil }
        
        detailVC.memeImage = cell.tableImageView.image
        previewingContext.sourceRect = cell.frame

        return detailVC
    }
    // Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
    
    
}









