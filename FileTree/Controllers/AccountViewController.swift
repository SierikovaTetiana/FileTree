//
//  AccountViewController.swift
//  FileTree
//
//  Created by Tetiana Sierikova on 15.06.2022.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class AccountViewController: UIViewController {
    
    private enum SignGoogle: String, CaseIterable {
        case signIn
        case signOut
        
        var message: String {
            switch self {
            case .signIn: return "Please, SignIn to your Google account for add new data, delete data or access private sheet"
            case .signOut: return "You have successfully signed in Google"
            }
        }
    }
    
    private lazy var treeImage: UIImageView = {
        let treeImage = UIImageView()
        treeImage.image = UIImage(named: "tree")
        treeImage.contentMode = .scaleAspectFit
        treeImage.clipsToBounds = true
        treeImage.translatesAutoresizingMaskIntoConstraints = false
        return treeImage
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = SignGoogle.signIn.message
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sheetIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter spreadsheet ID or leave this field empty to access test public sheet"
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sheetID: UITextField = {
        let textField = UITextField()
        textField.placeholder = " Enter spreadsheet ID"
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var googleSignIn: GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(tapGoogleSignIn), for: .touchUpInside)
        button.style = .wide
        button.isHidden = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var googleSignOut: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("Sign Out", for: .normal)
        button.isHidden = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.addTarget(self, action: #selector(tapGoogleSignOut), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var submit: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray5
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(tapSubmit), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signInConfig = Secrets().signInConfig
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    private let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets"]
    private let service = GTLRSheetsService()
    private var currentUser: GIDGoogleUser? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(treeImage)
        view.addSubview(messageLabel)
        view.addSubview(sheetIDLabel)
        view.addSubview(sheetID)
        view.addSubview(googleSignIn)
        view.addSubview(submit)
        view.addSubview(googleSignOut)
        navigationController?.delegate = self
        hideKeyboardWhenTappedAround()
        checkForGoogleSignIn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            treeImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            treeImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            treeImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            messageLabel.topAnchor.constraint(equalTo: treeImage.bottomAnchor, constant: 0),
            messageLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            googleSignIn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            googleSignIn.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            
            googleSignOut.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            googleSignOut.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            googleSignOut.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            
            sheetIDLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            sheetIDLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            sheetIDLabel.topAnchor.constraint(equalTo: googleSignIn.bottomAnchor, constant: 50),
            sheetIDLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            sheetID.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            sheetID.topAnchor.constraint(equalTo: sheetIDLabel.bottomAnchor, constant: 20),
            sheetID.heightAnchor.constraint(equalToConstant: 30),
            sheetID.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            submit.topAnchor.constraint(equalTo: sheetID.bottomAnchor, constant: 20),
            submit.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
        ])
    }
    
    private func checkForGoogleSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn {user, error in
            if error != nil || user == nil {
                self.googleSignIn.isHidden = false
                self.googleSignOut.isHidden = true
            } else {
                self.googleSignIn.isHidden = true
                self.googleSignOut.isHidden = false
                self.messageLabel.text = SignGoogle.signOut.message
                
                self.currentUser = user
            }
        }
    }
    
    @objc func tapGoogleSignIn() {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            GIDSignIn.sharedInstance.addScopes(self.additionalScopes, presenting: self) { user, error in
                guard error == nil else { return }
                guard let user = user else { return }
                
                user.authentication.do { authentication, error in
                    guard error == nil else { return }
                    guard let authentication = authentication else { return }
                    self.service.authorizer = authentication.fetcherAuthorizer()

                    self.googleSignIn.isHidden = true
                    self.googleSignOut.isHidden = false
                    self.messageLabel.text = SignGoogle.signOut.message

                    self.currentUser = user
                }
            }
        }
    }
    
    @objc func tapGoogleSignOut() {
        GIDSignIn.sharedInstance.signOut()
        googleSignIn.isHidden = false
        googleSignOut.isHidden = true
        self.messageLabel.text = SignGoogle.signIn.message
    }
    
    @objc func tapSubmit() {
        if sheetID.text != nil {
            let viewController = MainViewController()
            viewController.spreadsheetId = sheetID.text!
            viewController.user = currentUser
            viewController.isRedifineSheet = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        sheetID.endEditing(true)
    }
}

extension AccountViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? MainViewController)?.user = currentUser
    }
}
