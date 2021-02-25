//
//  ViewController.swift
//  simpleMusicApp
//
//  Created by Kalbek Saduakassov on 22.02.2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    
    
    @IBOutlet weak var mTrackImage: UIImageView!
    @IBOutlet weak var mTrackName: UILabel!
    @IBOutlet weak var mDuration: UILabel!
    @IBOutlet weak var mArtistName: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var trackPlayerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playerBlur: UIView!
    @IBOutlet weak var playPauseButton:UIButton!
    
    var topTrack = [TopTrack]()
    var audioPlayer:AVPlayer?
    var myTimer:Timer!
    var sectionHeaders = ["All Music","English Category","Russian Category"]
    var tracks = [Tracks]()
    var isPlaying = true
    var tempObj: TopTrack?
    var tempArr = [TopTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func initialSetup(){
        customNavbar()
        let nib =  UINib(nibName: "MusicCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        trackPlayerView.isHidden = true
        loadJSON()
        addBlurToPlayer()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (displayPlayer))
        trackPlayerView.addGestureRecognizer(gesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer?.pause()
    }
    
    
    
    func customNavbar(){
        self.title = "MusicPlay"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont(name: "Verdana-Bold", size: 15)!]
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = .red
        let menuButton =  UIBarButtonItem(image: UIImage(systemName: "heart")!, style: .done, target: self, action: #selector(goToFav))
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    func loadJSON(){
        let path = Bundle.main.url(forResource: "music", withExtension: "json")
        do{
            let jsonData = try Data(contentsOf: path!, options: Data.ReadingOptions.mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
            
            let items = jsonResult?["tracks"] as! NSArray
            
            for k in 0..<sectionHeaders.count {
                let otk = Tracks()
                otk.headerTitle = sectionHeaders[k]
                
                for i in items {
                    let data =  i as? [String:AnyObject]
                    
                    let object =  TopTrack()
                    object.previewURL = data?["preview_url"] as? String
                    object.trackName = data?["name"] as? String
                    let artists = data?["artists"] as? NSArray
                    object.artistName = (artists?.firstObject as? [String:AnyObject])?["name"] as? String
                    let albums =  data?["album"] as? [String:AnyObject]
                    let artWorkArray = albums?["images"] as! NSArray
                    let trackArtWork = artWorkArray.firstObject as! NSDictionary
                    object.artWork =  trackArtWork.value(forKey: "url") as? String
                    self.topTrack.append(object)
                    
                }
                if k == 0 {
                    self.tracks.append(Tracks(sectionHeaders[k], self.topTrack))
                    print(self.tracks.count)
                }
                 else if k == 1 {
                    for j in 0..<(self.topTrack.count) {
                        if isLatin(string: (self.topTrack[j].trackName!)) {
                            self.tempArr.append(self.topTrack[j])
                        }
                    }
                    self.tracks.append(Tracks(sectionHeaders[k], self.tempArr))
                    print(self.tracks.count)

                }
                  if k == 2 {
                    for j in 0..<(self.topTrack.count) {
                        if !isLatin(string: (self.topTrack[j].trackName!)) {
                            self.tempArr.append(self.topTrack[j])
                        }
                    }
                        self.tracks.append(Tracks(sectionHeaders[k], self.tempArr))
                        print(self.tracks.count)

                    print(self.tracks.count)

                }

                self.topTrack.removeAll()
                self.tempArr.removeAll()
            }
            
            
            self.tableView.reloadData()
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    func playTrack(track:TopTrack){
        
        tableView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: playerBlur.frame.height, right: 0)
        trackPlayerView.isHidden = false
        let musicURL = URL(string:track.previewURL!)

        self.audioPlayer =  AVPlayer(url: musicURL!)
        self.audioPlayer?.play()
        playPauseButton.setImage(UIImage(named:"pause"), for: .normal)
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        mTrackName.text = track.trackName!
        mArtistName.text = track.artistName!
    }
    
    @objc func displayPlayer() {
        let vc = storyboard?.instantiateViewController(identifier: "playerVC") as! PlayerViewController
        
        vc.setTrack(tempObj!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func updateProgressBar(){
        let t1 =  self.audioPlayer?.currentTime()
        let t2 =  self.audioPlayer?.currentItem?.asset.duration
        let current = CMTimeGetSeconds(t1!)
        let total =  CMTimeGetSeconds(t2!)
        
        if Int(current) != Int(total){
            let min = Int(current) / 60
            let sec =  Int(current) % 60
            mDuration.text = String(format: "%02d:%02d", min,sec)
            let percent = (current/total)
            self.progressBar.setProgress(Float(percent), animated: true)
        }else{
            audioPlayer?.pause()
            print("paused")
            audioPlayer = nil
            myTimer.invalidate()
            myTimer = nil
        }
        
    }
    
    @IBAction func didTapOnPause(_ sender: Any) {
        if !isPlaying {
            isPlaying = true
            audioPlayer?.play()
            playPauseButton.setImage(UIImage(named:"pause"), for: .normal)
            print(topTrack)
        }else{
            isPlaying = false
            audioPlayer?.pause()
            playPauseButton.setImage(UIImage(named:"play"), for: .normal)
        }
        
    }
    
    @objc func goToFav() {
        let vc = storyboard?.instantiateViewController(identifier: "favVC") as! FavouritesViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MusicCell
        if indexPath.row == 0{
            cell.cellBg.backgroundColor = .red
            cell.sectionHeader.textColor = UIColor.white
            cell.sectionHeader.text = sectionHeaders[0]
            
        }else{
            cell.sectionHeader.text = sectionHeaders[indexPath.row]
            cell.cellBg.backgroundColor = UIColor.white
            cell.sectionHeader.textColor = UIColor.black
            
        }
        let obj =  self.tracks[indexPath.row]
        cell.setCollectionViewDataSourceDelegate(index: indexPath,tracks:obj.tracks!)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 245
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TableView:\(indexPath)")
    }
    func addBlurToPlayer(){
        let blur =  UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = playerBlur.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerBlur.addSubview(blurView)
    }
    
    
}

extension ViewController: MusicCellProtocol {
    
    func didTapSeeAll(cell: MusicCell, indexPath: IndexPath) {
        
    }
    
    func didTapOnTrack(cell: MusicCell, indexPath: IndexPath) {
        
        let k = tableView.indexPath(for: cell)
        //        self.tracks[k!.row].tracks?[indexPath.row]
        playTrack(track: (self.tracks[k!.row].tracks?[indexPath.row])!)
        tempObj = ((self.tracks[k!.row].tracks?[indexPath.row])!)
//        print(tempObj)
        let obj = self.tracks[k!.row].tracks?[indexPath.row]
        DispatchQueue.global().async { [] in
            if let data = try? Data(contentsOf: NSURL(string:(obj!.artWork)!)! as URL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.mTrackImage.image = image
                    }
                }
            }
        }
        print("Location:\(k!.row) \(indexPath.row)")
    }
    
    
    fileprivate func isLatin(string: String) -> Bool {
        let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lower = "abcdefghijklmnopqrstuvwxyz"
            let characters = Array(string)
                if !upper.contains(characters[0]) && !lower.contains(characters[0]) {
                    return false
                }
            return true
        }
}




