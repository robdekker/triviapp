//
//  LoginViewController.swift
//  Triviapp
//
//  LoginViewController allows both email/password and Facebook login and provides the appropriate
//  alerts if something goes wrong
//
//  Created by Rob Dekker on 11-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var triviappLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        usersRef = Database.database().reference(withPath: "users")
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
            }
        }
    }
    
    // Dismiss keyboard when touching outside textfields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updateUI() {
        emailTextField.setLeftPaddingPoints(30)
        emailTextField.delegate = self
        passwordTextField.setLeftPaddingPoints(30)
        passwordTextField.delegate = self
        triviappLabel.font = UIFont(name: "HVDComicSerifPro", size: 50)
    }
    
    // Navigate to next textfield when touching return key and
    // Dismiss keyboard when touching return key on last textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Actions
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Login error",
                                              message: "\(error.localizedDescription)",
                                              preferredStyle: .alert)
                
                let okayAction = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Register new account",
                                      message: "Please enter your username, email and password below.",
                                      preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let usernameField = alert.textFields![0]
            let emailField = alert.textFields![1]
            let passwordField = alert.textFields![2]
            
            if usernameField.text!.count < 3 || usernameField.text!.count > 12 {
                let alert = UIAlertController(title: "Please give a valid username",
                                              message: "Your username has to be between 3-12 characters",
                                              preferredStyle: .alert)
                let tryAgain = UIAlertAction(title: "Try again", style: .cancel)
                alert.addAction(tryAgain)
                self.present(alert, animated: true, completion: nil)
                
            } else if !self.isValidEmail(email: emailField.text!) {
                let alert = UIAlertController(title: "Please give a valid email",
                                              message: "Like: this@example.com",
                                              preferredStyle: .alert)
                
                let tryAgain = UIAlertAction(title: "Try again", style: .cancel)
                alert.addAction(tryAgain)
                self.present(alert, animated: true, completion: nil)

            } else if passwordField.text!.characters.count < 6 {
                let alert = UIAlertController(title: "Please fill in a valid password",
                                              message: "Your password must be at least 6 characters.",
                                              preferredStyle: .alert)
                
                let tryAgain = UIAlertAction(title: "Try again", style: .cancel)
                alert.addAction(tryAgain)
                self.present(alert, animated: true, completion: nil)

            } else {

                Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
                    if error == nil {
                        if let username = usernameField.text {
                            self.usersRef.child(user!.uid).setValue([
                                "username": username,
                                "level": 1,
                                "daily_points": 0,
                                "weekly_points": 0,
                                "total_points": 100,
                                "imageURL": "default_profile",
                                "lastTimeAnswered": ""
                                ])
                        }
                        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!)
                    }
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addTextField { textUsername in
            textUsername.placeholder = "Username"
        }
        alert.addTextField { textEmail in
            textEmail.placeholder = "Email"
            textEmail.keyboardType = .emailAddress
        }

        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Password"
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)

        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
            guard let accessToken = FBSDKAccessToken.current() else { return }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                let userID = Auth.auth().currentUser?.uid
                
                self.usersRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
                    guard !snapshot.exists() else { return }

                    let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, picture.type(large)"])
                    let _ = request?.start(completionHandler: { (connection, result, error) in
                        guard let userInfo = result as? [String: Any] else { return }
                            
                        // Get user info current facebook user
                        if let username = userInfo["name"] as? String,
                            let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                
                            // Create new entry in Firebase when Facebook user logs in for the first time
                            self.usersRef.child(userID!).setValue([
                                "username": username,
                                "level": 1,
                                "daily_points": 0,
                                "weekly_points": 0,
                                "total_points": 100,
                                "imageURL": "\(imageURL)",
                                "lastTimeAnswered": ""
                                ])
                        }
                    })
                })
                
                // Present the main view
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    // Properties
    var user: User!
    var usersRef: DatabaseReference!
    var previousViewController: String!
    
    // Check if email is valid, used example from stackoverflow
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

}

// Use left padding to placeholder and input text, used example from stackoverflow
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
