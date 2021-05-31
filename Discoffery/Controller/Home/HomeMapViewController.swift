//
//  HomeMapViewController.swift
//  Discoffery
//
//  Created by Pei Pei on 2021/5/12.
//

import UIKit
import MapKit

class HomeMapViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet var mapView: MKMapView!
  
  @IBOutlet weak var selecetedShopContainerView: UIView!

  // MARK: - Properties
  var homeViewModel: HomeViewModel?
  
  var userCurrentCoordinate = CLLocationCoordinate2D()
  
  var shopsDataForMap: [CoffeeShop] = []

  var featureDic: [String: [Feature]] = [:]

  var recommendItemsDic: [String: [RecommendItem]] = [:]
  
  var selectedAnnotation: MKPointAnnotation?

  var selectedShop: CoffeeShop?

  var selectedShopVC: SelectedShopViewController?

  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view
    // 1:  When enter we check auth status
    locationManagerDidChangeAuthorization(LocationManager.shared.locationManager)
    
    // 2: Get user's current coordinate for drawing map
    LocationManager.shared.onCurrentCoordinate = { coordinate in
      
      self.userCurrentCoordinate = coordinate
    }
    
    // 3: Fetch shops within distance on Firebase
    self.homeViewModel?.getShopAroundUser()
    
    homeViewModel?.onShopsAnnotations = { [weak self] annotations in

      self?.mapView.showAnnotations(annotations, animated: true)

      if let shopsData = self?.homeViewModel?.shopsData {

        self?.shopsDataForMap = shopsData

        for index in 0..<shopsData.count {

          self?.fetchFeatureForShop(shop: shopsData[index])

          self?.fetchRecommendItemForShop(shop: shopsData[index])

          let distance = self?.calDistanceBetweenTwoLocations(

            location1Lat: self!.userCurrentCoordinate.latitude,

            location1Lon: self!.userCurrentCoordinate.longitude,

            location2Lat: shopsData[index].latitude,

            location2Lon: shopsData[index].longitude
          )

          // 把distance給一個沒用到的Double屬性
          self?.shopsDataForMap[index].cheap = distance!
        }
      }
    }
    selecetedShopContainerView.isHidden = true
  }

  // MARK: - Functions
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if let destinationVC = segue.destination as? SelectedShopViewController {

      selectedShopVC = destinationVC
    }
  }

  // MARK: TODO這兩個是否能夠寫到HomeViewModel去～現在趕時間ＴＡＴ
  func fetchFeatureForShop(shop: CoffeeShop) {

    FeatureManager.shared.fetchFeatureForShop(shop: shop) { [weak self] result in

      switch result {

      case .success(let getFeature):

        self?.featureDic[shop.id] = getFeature

      case .failure(let error):

        print("fetchFeatureForShop: \(error)")
      }
    }
  }

  func fetchRecommendItemForShop(shop: CoffeeShop) {

    RecommendItemManager.shared.fetchRecommendItemForShop(shop: shop) { result in

      switch result {

      case .success(let getItems):

        self.recommendItemsDic[shop.id] = getItems

      case .failure(let error):

        print("fetchFeatureForShop: \(error)")
      }
    }

  }

  func calDistanceBetweenTwoLocations(location1Lat: Double, location1Lon: Double, location2Lat: Double, location2Lon: Double) -> Double {

    // Use Haversine Formula to calculate the distance in meter between two locations
    // φ is latitude, λ is longitude, R is earth’s radius (mean radius = 6,371km)
    let lat1 = location1Lat

    let lat2 = location2Lat

    let lon1 = location1Lon

    let lon2 = location2Lon

    let earthRadius = 6371000.0

    // swiftlint:disable identifier_name
    let φ1 = lat1 * Double.pi / 180 // φ, λ in radians

    let φ2 = lat2 * Double.pi / 180

    let Δφ = (lat2 - lat1) * Double.pi / 180

    let Δλ = (lon2 - lon1) * Double.pi / 180

    let parameterA = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)

    let parameterC = 2 * atan2(sqrt(parameterA), sqrt(1 - parameterA))

    let distance = earthRadius * parameterC

    return distance
  }

}

// MARK: - CLLocationManagerDelegate
extension HomeMapViewController: CLLocationManagerDelegate {
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    
    // Tells the delegate when the app creates the location manager and when the authorization status changes
    
    manager.delegate = self
    
    switch manager.authorizationStatus {
    
    case .restricted:
      
      print("Location access was restricted.")
      
    case .denied:
      
      print("User denied access to location.")
      
    case .notDetermined:
      
      print("Location status not determined.")
      
      manager.requestWhenInUseAuthorization()
      
    case .authorizedAlways, .authorizedWhenInUse:
      
      print("Location authorization is confirmed.")
      
      homeViewModel?.getShopAroundUser()
      
      setUpMapView()
      
    default:
      
      print("Unknown Error")
    }
  }
}

// MARK: - HomeMapViewModelDelegate
extension HomeMapViewController: HomeViewModelDelegate {
  
  func setUpMapView() {
    
    homeViewModel?.delegate = self
    
    mapView.delegate = self
    
    mapView.showsUserLocation = true
    
    mapView.userTrackingMode = .follow
    
    mapView.region = MKCoordinateRegion(
      center: userCurrentCoordinate,
      latitudinalMeters: 500,
      longitudinalMeters: 500
    )
  }
}

// MARK: - MKMapViewDelegate
extension HomeMapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
    selectedAnnotation = view.annotation as? MKPointAnnotation

    for shop in shopsDataForMap {

      if shop.name == selectedAnnotation?.title {

        let selectedShopRecommendItem = recommendItemsDic[shop.id]

        let selectedsShopFeature = featureDic[shop.id]

        selectedShopVC?.setUpSelectedShopVC(
          shop: shop,

          feature: selectedsShopFeature![0],

          recommendItem: selectedShopRecommendItem![0]
        )

        selecetedShopContainerView.isHidden = false
      }
    }
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    let identifier = "MyMarker"
    
    if annotation.isKind(of: MKUserLocation.self) { return nil }
    
    var annotationView: MKMarkerAnnotationView? =
      mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
    
    if annotationView == nil {
      annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    }
    
    annotationView?.markerTintColor = UIColor.init(named: "B1")
    
    return annotationView
  }
}
