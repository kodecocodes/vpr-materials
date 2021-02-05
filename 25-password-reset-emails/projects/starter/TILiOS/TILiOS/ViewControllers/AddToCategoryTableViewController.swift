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

class AddToCategoryTableViewController: UITableViewController {

  var categories: [Category] = []
  var selectedCategories: [Category]!
  var acronym: Acronym!

  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }

  func loadData() {
    let categoriesRequest = ResourceRequest<Category>(resourcePath: "categories")
    categoriesRequest.getAll { [weak self] result in
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was an error getting the categories", on: self) { _ in
          self?.navigationController?.popViewController(animated: true)
        }
      case .success(let categories):
        self?.categories = categories
        DispatchQueue.main.async { [weak self] in
          self?.tableView.reloadData()
        }
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension AddToCategoryTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    let category =  categories[indexPath.row]
    cell.textLabel?.text = category.name
    let isSelected = selectedCategories.contains { element in
      element.name == category.name
    }
    if isSelected {
      cell.accessoryType = .checkmark
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categories[indexPath.row]
    guard let acronymID = acronym.id else {
      let message = """
      There was an error adding the acronym
      to the category - the acronym has no ID
      """
      ErrorPresenter.showError(message: message, on: self)
      return
    }
    let acronymRequest = AcronymRequest(acronymID: acronymID)
    acronymRequest.add(category: category) { [weak self] result in
      switch result {
      case .success:
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?.popViewController(animated: true)
        }
      case .failure:
        let message = """
        There was an error adding the acronym
        to the category
        """
        ErrorPresenter.showError(message: message, on: self)
      }
    }
  }
}
