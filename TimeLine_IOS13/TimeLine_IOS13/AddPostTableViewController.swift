//
//  AddPostTableViewController.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/12/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    //MARK: - IBActions
    
    @IBAction func cancelButonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        
        // Create ImagePicker and set the delegate to be self
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // Create AlertController
        let actionSheet = UIAlertController(title: "Select Image", message: "Please select an image", preferredStyle: .actionSheet)
        
        // Create Actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos", style: .default) { (_) in
            imagePicker.sourceType = .savedPhotosAlbum
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        // Add the actions
        actionSheet.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(photoLibraryAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            actionSheet.addAction(savedPhotosAction)
        }
        present(actionSheet, animated: true, completion: nil)

        selectImageButton.setTitle("", for: .normal)
        
    }

    @IBAction func addPostButtonTapped(_ sender: Any) {
        
        
        if let photo = photoImageView.image, let caption = captionTextField.text, !caption.isEmpty {
            
            PostController.shared.createPostWith(image: photo, caption: caption)
            navigationController?.popViewController(animated: true)
            
        } else {
            let alertController = UIAlertController(title: "Try Again", message: "Please make sure you've filled out all fields, then try again", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
            }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            delegate?.photoSelectViewControllerSelected(image)
            selectImageButton.setTitle("", for: UIControlState())
            photoImageView.image = image
        }
    }
    
    // MARK: Properties
    
    weak var delegate: PhotoSelectViewControllerDelegate?
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol PhotoSelectViewControllerDelegate: class {
    
    func photoSelectViewControllerSelected(_ image: UIImage)
}
