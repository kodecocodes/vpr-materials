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

class CreateAcronymTableViewController: UITableViewController {

  @IBOutlet weak var acronymShortTextField: UITextField!
  @IBOutlet weak var acronymLongTextField: UITextField!
  var acronym: Acronym?

  override func viewDidLoad() {
    super.viewDidLoad()
    acronymShortTextField.becomeFirstResponder()
    if let acronym = acronym {
      acronymShortTextField.text = acronym.short
      acronymLongTextField.text = acronym.long
      navigationItem.title = "Edit Acronym"
    }
  }

  @IBAction func cancel(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func save(_ sender: UIBarButtonItem) {
    guard let shortText = acronymShortTextField.text, !shortText.isEmpty else {
      ErrorPresenter.showError(message: "You must specify an acronym!", on: self)
      return
    }
    guard let longText = acronymLongTextField.text, !longText.isEmpty else {
      ErrorPresenter.showError(message: "You must specify a meaning!", on: self)
      return
    }
    let acronym = Acronym(short: shortText, long: longText, userID: UUID())

    if self.acronym != nil {
      guard let existingID = self.acronym?.id else {
        ErrorPresenter.showError(message: "There was an error updating the acronym", on: self)
        return
      }
      AcronymRequest(acronymID: existingID).update(with: acronym) { result in
        switch result {
        case .failure:
          ErrorPresenter.showError(message: "There was a problem saving the acronym", on: self)
        case .success(let updatedAcronym):
          self.acronym = updatedAcronym
          DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: "UpdateAcronymDetails",
                               sender: nil)
          }
        }
      }
    } else {
      ResourceRequest<Acronym>(resourcePath: "acronyms").save(acronym) { [weak self] result in
        switch result {
        case .failure:
          ErrorPresenter.showError(message: "There was a problem saving the acronym", on: self)
        case .success:
          DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
          }
        }
      }
    }
  }
}
