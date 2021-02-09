/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import AuthenticationServices

class LoginTableViewController: UITableViewController {
  // MARK: - Properties
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet var loginTableView: UITableView!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let siwaCell = loginTableView.cellForRow(at: IndexPath(row: 0, section: 2)) else {
      fatalError("Unable to get Sign in with Apple cell")
    }
    let button = ASAuthorizationAppleIDButton()
    button.addTarget(self, action: #selector(handleSignInWithApple), for: .touchUpInside)
    let x = (siwaCell.frame.width / 2) - 100
    button.frame = CGRect(x: x, y: 3, width: 200, height: 38)
    siwaCell.contentView.addSubview(button)
  }

  @IBAction func loginTapped(_ sender: UIBarButtonItem) {
    guard
      let username = usernameTextField.text,
      !username.isEmpty
    else {
      ErrorPresenter.showError(message: "Please enter your username", on: self)
      return
    }

    guard
      let password = passwordTextField.text,
      !password.isEmpty
    else {
      ErrorPresenter.showError(message: "Please enter your password", on: self)
      return
    }

    Auth().login(username: username, password: password) { result in
      switch result {
      case .success:
        DispatchQueue.main.async {
          let appDelegate = UIApplication.shared.delegate as? AppDelegate
          appDelegate?.window?.rootViewController =
            UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        }
      case .failure:
        let message = "Could not login. Check your credentials and try again"
        ErrorPresenter.showError(message: message, on: self)
      }
    }
  }

  @IBAction func signInWithGoogleButtonTapped(_ sender: UIButton) {
    guard let googleAuthURL = URL(string: "\(apiHostname)/iOS/login-google") else {
      return
    }
    let scheme = "tilapp"
    let session = ASWebAuthenticationSession(url: googleAuthURL, callbackURLScheme: scheme) { callbackURL, error in
      guard
        error == nil,
        let callbackURL = callbackURL
        else {
          return
        }

      let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
      let token = queryItems?.first { $0.name == "token" }?.value
      Auth().token = token
      DispatchQueue.main.async {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController =
          UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
      }
    }
    session.presentationContextProvider = self
    session.start()
  }

  @IBAction func signInWithGithubButtonTapped(_ sender: UIButton) {
    guard let githubAuthURL = URL(string: "\(apiHostname)/iOS/login-github") else {
      return
    }
    let scheme = "tilapp"
    let session = ASWebAuthenticationSession(url: githubAuthURL, callbackURLScheme: scheme) { callbackURL, error in
      guard
        error == nil,
        let callbackURL = callbackURL
        else {
          return
        }

      let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
      let token = queryItems?.first { $0.name == "token" }?.value
      Auth().token = token
      DispatchQueue.main.async {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController =
          UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
      }
    }
    session.presentationContextProvider = self
    session.start()
  }

  @objc func handleSignInWithApple() {
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }
}

extension LoginTableViewController: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    guard let window = view.window else {
      fatalError("No window found in view")
    }
    return window
  }
}

extension LoginTableViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let window = view.window else {
      fatalError("No window found in view")
    }
    return window
  }
}

extension LoginTableViewController: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard 
        let identityToken = credential.identityToken,
        let tokenString = String(data: identityToken, encoding: .utf8)
      else {
        print("Failed to get token from credential")
        return
      }
      let name: String?
      if let nameProvided = credential.fullName {
        name = "\(nameProvided.givenName ?? "") \(nameProvided.familyName ?? "")"
      } else {
        name = nil
      }
      let requestData = SignInWithAppleToken(token: tokenString, name: name)
      do {
        try Auth().login(signInWithAppleInformation: requestData) { result in
          switch result {
          case .success:
            DispatchQueue.main.async {
              let appDelegate = UIApplication.shared.delegate as? AppDelegate
              appDelegate?.window?.rootViewController =
                UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            }
          case .failure:
            let message = "Could not Sign in with Apple."
            ErrorPresenter.showError(message: message, on: self)
          }
        }
      } catch {
        let message = "Could not login - \(error)"
        ErrorPresenter.showError(message: message, on: self)
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("Error signing in with Apple - \(error)")
  }
}
