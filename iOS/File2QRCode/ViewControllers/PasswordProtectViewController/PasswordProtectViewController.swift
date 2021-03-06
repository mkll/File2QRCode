//
//  PasswordProtectViewController.swift
//  File2QRCode
//
//  Created by Maxime Junger on 12/11/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit
import CryptoSwift

class PasswordProtectViewController: UIViewController {

	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var informationLabel: UILabel!
	@IBOutlet weak var nextButton: ActionButton!
	@IBOutlet weak var cancelButton: ActionButton!

	/// String recovered with Scanner
	private var recoveredString: String!

	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.setUI()
    }

	private func setUI() {

		self.view.backgroundColor = .mainColor

		// Information label
		self.informationLabel.textColor = .black
		self.informationLabel.text = String.localized(withKey: .encryptionDescription)

		// Password text field
		self.passwordTextField.backgroundColor = UIColor.mainColor.darker(by: 5)
		self.passwordTextField.superview?.backgroundColor = self.passwordTextField.backgroundColor
		self.passwordTextField.tintColor = .black
		self.passwordTextField.textColor = .black
		self.passwordTextField.isSecureTextEntry = true
		self.passwordTextField.placeholder = String.localized(withKey: .passwordFieldPlaceholder)
		self.passwordTextField.delegate = self

		// UIView gesture
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		self.view.addGestureRecognizer(tap)

		// Next button
		self.nextButton.isEnabled = false
		self.nextButton.setTitle(String.localized(withKey: .share), for: .normal)
		self.nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)

		// Cancel button
		self.cancelButton.setTitle(String.localized(withKey: .goBackToMenu), for: .normal)
		self.cancelButton.addTarget(self, action: #selector(goBackToMenu), for: .touchUpInside)
		self.cancelButton.lightColors()
	}

	@objc private func dismissKeyboard() {
		self.view.endEditing(true)
	}

	@objc private func nextButtonClicked() {

		// Check if password is set and if the encryption process worked
		guard let password = self.passwordTextField.text,
			let encrypted = Encryptor.encrypt(self.recoveredString, toAESWithPassword: password) else {
			return
		}

		let file = "file2QRCodeAES.txt"
		
		guard let fileURL = ExportFileManager.createFile(named: file, withContent: encrypted) else {
			return
		}

		let controller = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

		controller.excludedActivityTypes = [.postToFacebook, .postToVimeo, .postToFlickr, .postToTwitter, .postToTencentWeibo, .postToWeibo]
		controller.completionWithItemsHandler = { (activityType, completed, items, error) in
			// When user has shared the data, we delete the file
			ExportFileManager.deleteFile(atURL: fileURL)
		}

		self.present(controller, animated: true, completion: nil)
	}

	@objc private func goBackToMenu() {
		if let vc = self.navigationController?.viewControllers.first(where: { $0 is MainViewController }) {
			self.navigationController?.popToViewController(vc, animated: true)
		}
	}
}

extension PasswordProtectViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		self.nextButton.isEnabled = (textField.text?.count ?? 0) > 0
	}
}

extension PasswordProtectViewController {

	/// Build PasswordProtectViewController controller by its nib and sets the recovered string property.
	///
	/// - Parameter recovered: String recovered
	/// - Returns: PasswordProtectViewController
	class func build(withRecoveredString recovered: String) -> PasswordProtectViewController {
		let vc = PasswordProtectViewController(nibName: nil, bundle: nil)
		vc.recoveredString = recovered
		return vc
	}
}
