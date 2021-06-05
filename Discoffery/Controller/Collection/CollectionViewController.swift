//
//  CollectionViewController.swift
//  Discoffery
//
//  Created by Pei Pei on 2021/5/17.
//

import UIKit

class CollectionViewController: UIViewController {

  // MARK: Outlets

  @IBOutlet weak var collectionView: UICollectionView!
  // MARK: Properties
  var addViewModel = AddViewModel()

  // MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    setupNavigation()

    setupCollectionView()
  }

  // MARK: Functions
  func setupNavigation() {

    navigationController?.navigationBar.barTintColor = .G3

    let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.navigateToNextVC))

    addBtn.tintColor = .G1

    navigationItem.rightBarButtonItem = addBtn

    //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.navigateToNextVC))
  }

 @objc func navigateToNextVC() {

    performSegue(withIdentifier: "navigateToAddCategoryVC", sender: self)
  }

  private func setupCollectionView() {

    collectionView.register(UINib(nibName: CategoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)

    collectionView.delegate = self

    collectionView.dataSource = self

    let layout = UICollectionViewFlowLayout()

    layout.scrollDirection = .vertical

    layout.minimumLineSpacing = 8

    layout.minimumInteritemSpacing = 8

    collectionView.setCollectionViewLayout(layout, animated: true)
  }
}

// MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return 5
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell {

      cell.mainImgView.image = UIImage(named: "unsplash_protrait_1")

      cell.layoutCategoryCollectionViewCell(from: "分類")

      return cell
    }
    return CategoryCollectionViewCell()
  }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 16
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let minimumInteritemSpacing = 16

    let sectionInsetLeft = 16

    let sectionInsetRight = 16

    let space = CGFloat(minimumInteritemSpacing + sectionInsetLeft + sectionInsetRight)

    let sizePerItem: CGFloat = (collectionView.frame.size.width - space) / 2.0

    return CGSize(width: sizePerItem, height: sizePerItem + 35)
  }
}

extension CollectionViewController: UICollectionViewDelegate {
}
