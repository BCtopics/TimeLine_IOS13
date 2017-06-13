//
//  AddPostTableViewController.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var image: UIImage?
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var captionTextField: UITextField!
    
    //MARK: - IBActions
    
    @IBAction func cancelButonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addPostButtonTapped(_ sender: Any) {
        
        if let photo = image, let caption = captionTextField.text, !caption.isEmpty {
            
            PostController.shared.createPostWith(image: photo, caption: caption)
            navigationController?.popViewController(animated: true)
            
        } else {
            let alertController = UIAlertController(title: "Try Again", message: "Please make sure you've filled out all fields, then try again", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
            }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "embedPhotoSelect" {
            
            let embedViewController = segue.destination as? PhotoSelectViewController
            embedViewController?.delegate = self
        }
    }
    
}

extension AddPostTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelected(_ image: UIImage) {
        
        self.image = image
    }
}
