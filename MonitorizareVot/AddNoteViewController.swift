//  Created by Code4Romania

import Foundation
import UIKit
import Photos

protocol AddNoteViewControllerDelegate: class {
    func attach(note: MVNote)
}

class AddNoteViewController: RootViewController, UITextViewDelegate, MVUITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - iVars
    var sectionInfo: MVSectionInfo?
    var noteContainer: NoteContainer? {
        didSet {
            noteSaver.noteContainer = noteContainer
        }
    }
    var note: MVNote?
    var questionID: Int16?
    private var noteSaver = NoteSaver()
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var cameraPicker: UIImagePickerController?
    @IBOutlet weak var bottomButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomRightButton: UIButton!
    @IBOutlet weak var bottomLeftLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyTextView: MVUITextView!
    @IBOutlet weak var textViewBackgroundView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var secondButton: UIButton!
    weak var delegate: AddNoteViewControllerDelegate?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyTextView.customDelegate = self
        bodyTextView.placeholder = "Wpisz tutaj..."
        if let sectionInfo = self.sectionInfo, note == nil {
            note = MVNote(sectionInfo: sectionInfo)
        }
        note?.questionID = questionID
        layout()
        outlets()
        setTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(AddNoteViewController.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddNoteViewController.keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Utils
    func keyboardDidShow(notification: Notification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
            bottomConstraint.constant = frame.size.height - bottomButtonHeight.constant
            performKeyboardAnimation()
        }
    }
    
    func keyboardDidHide(notification: Notification) {
        keyboardIsHidden()
    }
    
    func keyboardIsHidden() {
        bottomConstraint?.constant = 0
        performKeyboardAnimation()
        bodyTextView.resignFirstResponder()
    }
    
    private func layout() {
        textViewBackgroundView.layer.defaultCornerRadius(borderColor: MVColors.lightGray.cgColor)
        bottomRightButton.layer.defaultCornerRadius(borderColor: MVColors.lightGray.cgColor)
    }
    
    private func outlets()  {
        if delegate != nil {
            secondButton.setTitle("Dodaj", for: .normal)
        } else {
            secondButton.setTitle("Prześlij", for: .normal)
        }
        if let note = self.note {
            if note.image != nil {
                bottomLeftLabel.text = "Usuń"
                bottomRightButton.setImage(UIImage(named: "trash")!, for: .normal)
            }
            if let body = note.body {
                bodyTextView.savedText = body
            }
        }
    }
    
    private func setTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddNoteViewController.keyboardIsHidden))
        self.tapGestureRecognizer = tapGestureRecognizer
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - IBActions
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        bodyTextView.resignFirstResponder()
        if let note = self.note {
            if delegate == nil {
                loadingView.isHidden = false
                noteSaver.save(note: note, completion: { (success, tokenExpired) in
                    if tokenExpired {
                        let _ = self.navigationController?.popToRootViewController(animated: false)
                    } else {
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                })
            } else {
                if let note = self.note {
                    delegate?.attach(note: note)
                }
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func bottomRightButtonTapped(_ sender: UIButton) {
        bodyTextView.resignFirstResponder()
        if note?.image == nil {
            switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
            case .authorized, .notDetermined:
                let cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                self.cameraPicker = cameraPicker
                navigationController?.present(cameraPicker, animated: true, completion: nil)
            case .denied, .restricted:
                let appSettings = UIAlertAction(title: "Ustawienia", style: .default) { (action) in
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                }
                let cancel = UIAlertAction(title: "Zamknij", style: .cancel, handler: nil)
                
                let alertController = UIAlertController(title: "Brak dostępu", message: "Przejdź do ustawień i udziel aplikacji uprawnień do dostępu do biblioteki zdjęć.", preferredStyle: .alert)
                alertController.addAction(appSettings)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            note?.image = nil
            bottomLeftLabel.text = "Dodaj zdjęcie"
            bottomRightButton.setImage(UIImage(named: "camera")!, for: .normal)
        }
    }
    
    // MARK: - MVUITextViewDelegate
    func textView(textView: MVUITextView, didChangeText text: String) {
        note?.body = text
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: false, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            note?.image = image
            bottomLeftLabel.text = "Usuń"
            bottomRightButton.setImage(UIImage(named: "trash")!, for: .normal)
        }
    }
    
}
