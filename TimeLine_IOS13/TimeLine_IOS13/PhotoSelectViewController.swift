//
//  PhotoSelectViewController.swift
//  TimeLine_IOS13
//
//  Created by Bradley GIlmore on 6/13/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class PhotoSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    //MARK: - IBActions
    
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

}

protocol PhotoSelectViewControllerDelegate: class {
    
    func photoSelectViewControllerSelected(_ image: UIImage)
}
