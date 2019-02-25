//
//  TVShowsViewController.swift
//  TVShows
//
//  Created by Hector de Diego on 2/22/19.
//  Copyright © 2019 hector.dd. All rights reserved.
//

import UIKit

@IBDesignable
class TVShowsViewController: UIViewController {
  
  let networkingService = NetworkingService()
  
  // MARK: - Outlets
  @IBOutlet weak var showsTableView: UITableView!
  
  // MARK: - Properties
  enum ScreenState {
    case empty
    case loading
    case error(Error)
    case populated([TVShow])
  }
  var currentTVShows: [TVShow] = []

  public var screenState: ScreenState = ScreenState.empty {
    didSet {
      switch screenState {
      case .populated(let tvShows): currentTVShows = tvShows
      default: currentTVShows = []
      }
      showsTableView.reloadData()
    }
  }
  
  func loadShows() {
    networkingService.fetchTVShows() { [weak self] response in
      guard let strongSelf = self else { return }
      strongSelf.update(response: response)
    }
  }
  
  func update(response: TVShowsModel) {
    if let error = response.error {
      screenState = .error(error)
      return
    }
    
    guard let tvShows = response.tvShows, !tvShows.isEmpty else {
      screenState = .empty
      return
    }
    
    screenState = .populated(tvShows)
  }
  
  // MARK: - Configuration
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func prepareNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "TV Shows"
  }
  
  private func prepareShowsTableView() {
    showsTableView.delegate = self
    showsTableView.dataSource = self
    
    let nib = UINib(nibName: TVShowTableViewCell.nibName, bundle: .main)
    showsTableView.register(
      nib,
      forCellReuseIdentifier: TVShowTableViewCell.reuseIdentifier
    )
  }
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareNavigationBar()
    prepareShowsTableView()
    loadShows()
  }
  
  // MARK: - Navigation
}

// MARK: - Delegates


extension TVShowsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

    if currentTVShows[indexPath.row].isFavorite {
      let unfavoriteAction = UITableViewRowAction(
        style: .normal, title: "Delete") { [weak self] (rowAction, indexPath) in
        if let strongSelf = self {
          strongSelf.currentTVShows[indexPath.row].setFavoriteStatus(favorite: false)
        }
      }
      unfavoriteAction.backgroundColor = .red
      return [unfavoriteAction]

    } else {
      let favoriteAction = UITableViewRowAction(
        style: .normal, title: "Favorite") { [weak self] (rowAction, indexPath) in
        if let strongSelf = self {
          strongSelf.currentTVShows[indexPath.row].setFavoriteStatus(favorite: true)
        }
      }
      favoriteAction.backgroundColor = .green

      return [favoriteAction]
    }
  }
  
//  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//    let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
//      //TODO: edit the row at indexPath here
//    }
//    editAction.backgroundColor = .blue
//
//    let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
//      //TODO: Delete the row at indexPath here
//    }
//    deleteAction.backgroundColor = .red
//
//    return [editAction,deleteAction]
//  }
  
}


extension TVShowsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentTVShows.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let showCell: TVShowTableViewCell = tableView.dequeueReusableCell(
        withIdentifier: TVShowTableViewCell.reuseIdentifier,
        for: indexPath
        ) as? TVShowTableViewCell
      else { return UITableViewCell() }
    showCell.load(tvShow: currentTVShows[indexPath.row])
    return showCell
  }
  
}
