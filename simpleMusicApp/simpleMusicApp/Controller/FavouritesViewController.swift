//
//  FavouritesViewController.swift
//  simpleMusicApp
//
//  Created by Kalbek Saduakassov on 25.02.2021.
//

import UIKit

class FavouritesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    static var tracks = [TopTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your favourites list"
        let nib =  UINib(nibName: "FavCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        print(FavouritesViewController.tracks.count)
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension FavouritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavouritesViewController.tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavCell
        cell.artistLabel.text = FavouritesViewController.tracks[indexPath.row].artistName
        cell.trackLabel.text = FavouritesViewController.tracks[indexPath.row].trackName
        DispatchQueue.global().async { [] in
            if let data = try? Data(contentsOf: NSURL(string:(FavouritesViewController.tracks[indexPath.row].artWork!))! as URL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async { [] in
                        cell.artImage.image = image
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "playerVC") as! PlayerViewController
        vc.setTrack(FavouritesViewController.tracks[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }


}
