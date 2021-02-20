/// Copyright (c) 2019 Razeware LLC
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

class HomeViewController: UIViewController {
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var followButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  private let echo = WebSocket("ws://\(host)/echo-test")
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupEcho()
    title = "HOME"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    hideActivity()
  }
  
  // MARK: Echo
  
  func setupEcho() {
    addEchoButton()
    addEchoListener()
  }
  
  func addEchoButton() {
    let echoButton = UIBarButtonItem(
      title: "Echo",
      style: .plain,
      target: self,
      action: #selector(didPressEchoButton)
    )
    
    navigationItem.leftBarButtonItem = echoButton
  }
  
  func addEchoListener() {
    echo.event.message = { message in
      print("got message: \(message)")
    }
  }
  
  @objc func didPressEchoButton() {
    let message = "sending echo \(Date().timeIntervalSince1970)"
    print("sending \(message)")
    echo.send(message)
  }
  
  // MARK: Show / Hide
  
  func showActivity() {
    shareButton.isHidden = true
    followButton.isHidden = true
    activityIndicator.isHidden = false
    activityIndicator.startAnimating()
  }
  
  func hideActivity() {
    shareButton.isHidden = false
    followButton.isHidden = false
    activityIndicator.isHidden = true
    activityIndicator.stopAnimating()
  }
  
  // MARK: Button Responders
  
  @IBAction func didPressShareButton(_ sender: UIButton) {
    showActivity()
    WebServices.create(
      success: { [weak self] session in
        let share = ShareViewController(session: session)
        self?.navigationController?.pushViewController(share, animated: true)
      },
      failure: { [weak self] error in
        self?.alert(title: "Failed", message: "\(error)", then: {})
        self?.hideActivity()
      }
    )
  }
  
  @IBAction func didPressFollowButton(_ sender: UIButton) {
    let sessionEntryVC = SessionEntryViewController()
    navigationController?.pushViewController(sessionEntryVC, animated: true)
  }
}
