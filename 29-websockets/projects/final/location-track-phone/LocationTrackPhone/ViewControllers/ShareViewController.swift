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
import MapKit

class ShareViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  // MARK: Variables
  
  let session: TrackingSession
  let locationManager = CLLocationManager()
  
  // MARK: View Attributes
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var sessionButton: UIButton!
  
  // MARK: Initializers
  
  init(session: TrackingSession) {
    self.session = session
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "SHARING"
    sessionButton.setTitle(session.id, for: .normal)
    
    let close = UIBarButtonItem(
      title: "Close",
      style: .plain,
      target: self,
      action: #selector(didPressCloseButton(_:))
    )
    navigationItem.leftBarButtonItem = close
    
    mapView.delegate = self
    locationManager.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkLocationAuthorizationStatus()
  }
  
  // MARK: Tracking
  
  func startTracking() {
    mapView.showsUserLocation = true
    mapView.setUserTrackingMode(.follow, animated: true)
  }
  
  // MARK: Button Responders
  
  @IBAction func didPressSessionButton(_ sender: UIButton) {
    let activityViewController = UIActivityViewController(
      activityItems: [
        "I'd like to share my location: \n\n \(session.id)"
      ],
      applicationActivities: nil
    )
    present(activityViewController, animated: true, completion: nil)
  }
  
  
  @objc func didPressCloseButton(_ sender: UIButton) {
    WebServices.close(session) { [weak self] success in
      print("Closed session")
      self?.navigationController?.popToRootViewController(animated: true)
    }
  }
  
  // MARK: MKMapViewDelegate
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    let latitude = userLocation.coordinate.latitude
    let longitude = userLocation.coordinate.longitude
    let location = Location(latitude: latitude, longitude: longitude)
    WebServices.update(location, for: session) { success in
      if success {
        print("... updated location")
      } else {
        print("... location update FAILED")
      }
    }
  }
  
  // MARK: CLLocationManagerDelegate
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    checkLocationAuthorizationStatus()
  }
  
  // MARK: Location Authorization
  
  func checkLocationAuthorizationStatus() {
    let status = CLLocationManager.authorizationStatus()
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      startTracking()
    } else if status == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    } else {
      locationFail()
    }
  }
  
  func locationFail() {
    alert(
      title: "Location Required",
      message: "We don't have location permissions, reinstall app, or update in settings.",
      then: { [weak self] in
        self?.navigationController?.popToRootViewController(animated: true)
      }
    )
  }
}
