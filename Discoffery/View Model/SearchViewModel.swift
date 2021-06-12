//
//  SearchViewModel.swift
//  Discoffery
//
//  Created by Pei Pei on 2021/5/31.
//

import Foundation
import CoreLocation

class SearchViewModel {

  // MARK: - Properties
  var onSearchShopsData: (([CoffeeShop]) -> Void)?

  var searchShopsData: [CoffeeShop] = [] {

    didSet {

      onSearchShopsData?(searchShopsData)
    }
  }

  var onUserCurrentCoordinate: ((CLLocationCoordinate2D) -> Void)? // For Search Result VC

  var userCurrentCoordinate: CLLocationCoordinate2D? {

    didSet {

      if let userCurrentCoordinate = userCurrentCoordinate {

        self.onUserCurrentCoordinate?(userCurrentCoordinate)
      }
    }
  }

  // MARK: - Distance between shop & user related functions
  func getShopAroundUser(distance: Double = 2000) {

    LocationManager.shared.trackLocation { latitude, longitude in

      filterShopWithinDistance(latitude: latitude, longitude: longitude, distanceInMeters: distance)

      self.userCurrentCoordinate?.latitude = latitude

      self.userCurrentCoordinate?.longitude = longitude
    }
  }

  func filterShopWithinDistance(latitude: Double, longitude: Double, distanceInMeters: Double = 2000) {

    // Find all shops within input meters within user's current location; default is 2000 m for getting more data to filter
    CoffeeShopManager.shared.fetchShopWithinLatitude(latitude: latitude, distance: distanceInMeters) { [weak self] result in

      switch result {

      case .success(let filteredShops):

        self?.filterShopWithinLongitude(
          shopFilteredByLat: filteredShops,
          latitude: latitude,
          longitude: longitude,
          distance: distanceInMeters)

      case .failure(let error):

        print("filterShopWithinLatitude.failure: \(error)")
      }
    }
  }

  func filterShopWithinLongitude(shopFilteredByLat: [CoffeeShop], latitude: Double, longitude: Double, distance: Double) {

    // The number of meters per degree of lonitude (roughly) 換算 1 degrees 的經度 ~ 110122 m
    let metersPerLonDegree = (Double.pi / 180) * 6371000 * cos(latitude / 180)

    let lowerLon = longitude - (distance / metersPerLonDegree) // 經度下限

    let upperLon = longitude + (distance / metersPerLonDegree) // 經度上限

    searchShopsData = shopFilteredByLat.filter { $0.longitude >= lowerLon && $0.longitude <= upperLon }
  }
}
