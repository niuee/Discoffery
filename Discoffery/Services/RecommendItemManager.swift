//
//  RecommendItemManager.swift
//  Discoffery
//
//  Created by Pei Pei on 2021/5/26.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum RecommendItemError: Error {

  case notExistError
}

class RecommendItemManager {

  // MARK: - Properties
  static let shared = RecommendItemManager()

  lazy var database = Firestore.firestore()

  // MARK: - Functions
  func fetchRecommendItem(shop: CoffeeShop, completion: @escaping (Result<[RecommendItem], Error>) -> Void) {

    let docRef = database.collection("shopsTaipeiDemo").document(shop.id).collection("recommendItems")

    docRef.getDocuments() { querySnapshot, error in

      if let error = error {

        print("Error getting documents: \(error)")

      } else {

        var items = [RecommendItem]()

        for document in querySnapshot!.documents {

          do {
            if let item = try document.data(as: RecommendItem.self, decoder: Firestore.Decoder()) {

              items.append(item)
            }

          } catch {

            completion(.failure(error))
          }
        }

        print(items.count)
        completion(.success(items))
      }
    }

  }

  func publishUserRecommendItem(shop: CoffeeShop, item: inout RecommendItem, completion: @escaping (Result<String, Error>) -> Void) {

    let docRef = database.collection("shopsTaipeiDemo").document(shop.id).collection("recommendItems").document()

    item.id = docRef.documentID

    item.parentId = shop.id

    item.count = 1

    docRef.setData(item.toDict) { error in

      if let error = error {

        completion(.failure(error))

      } else {

        completion(.success("Success"))
      }
    }

  }

  func checkIfRecommendItemExist(shop: CoffeeShop, item: RecommendItem, completion: @escaping (Result<RecommendItem, Error>) -> Void) {

    let docRef = database.collection("shopsTaipeiDemo").document(shop.id).collection("recommendItems")

    let queryByItem = docRef.whereField("item", isEqualTo: item.item)

    queryByItem.getDocuments() { querySnapshot, error in

      if let error = error {

        print("Error getting documents: \(error)")

        completion(.failure(error))

      } else {

        if querySnapshot!.documents.isEmpty {

          completion(.failure(RecommendItemError.notExistError))

        } else {

          var didExistItem = RecommendItem()

          for document in querySnapshot!.documents {

            do {
              if let item = try document.data(as: RecommendItem.self, decoder: Firestore.Decoder()) {

                didExistItem = item
              }

            } catch {

              completion(.failure(error))
            }
          }

          completion(.success(didExistItem))
        }
      }
    }

  }

  func updateRecommendItemCount(shop: CoffeeShop, item: RecommendItem) {

    let docRef = database.collection("shopsTaipeiDemo").document(shop.id).collection("recommendItems").document(item.id)

    docRef.updateData([

      "count": FieldValue.increment(Int64(1)),

      // "lastUpdated": FieldValue.serverTimestamp()
    ]) { error in

      if let error = error {

        print("Error updating document: \(error)")

      } else {

        print("Document successfully updated")
      }
    }
  }

}
