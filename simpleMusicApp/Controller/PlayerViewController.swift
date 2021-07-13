//
//  ViewController.swift
//  MyMusic
//
//  Created by Kalbek Saduakassov on 18.02.2021
//




import UIKit
import AVFoundation
import MediaPlayer


extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}


class PlayerViewController: UIViewController, AVAudioPlayerDelegate {
    
    //Choose background here. Between 1 - 7
    let selectedBackground = ""
    
    
    var audioPlayer:AVPlayer! = nil
    var timer:Timer!
    var audioLength = 0.0
    var totalLengthOfAudio = ""
    var track: TopTrack?
    var isPlaying = true
    var flag: Bool?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var lineView : UIView!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet var progressTimerLabel : UILabel!
    @IBOutlet var playerProgressSlider : UISlider!
    @IBOutlet var totalLengthOfAudioLabel : UILabel!
    @IBOutlet var previousButton : UIButton!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var nextButton : UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var favButton: UIButton!
    
    
    
    public func setTrack(_ track: TopTrack) {
        self.track = track
    }

    
    
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEvent.EventType.remoteControl{
            switch event!.subtype{
            case UIEventSubtype.remoteControlPlay:
                play(self)
            case UIEventSubtype.remoteControlPause:
                play(self)
            case UIEventSubtype.remoteControlNextTrack:
                next(self)
            case UIEventSubtype.remoteControlPreviousTrack:
                previous(self)
            default:
                print("There is an issue with the control")
            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //assing background
        backgroundImageView.image = UIImage(named: "background\(selectedBackground)")
        flag = false
        //this sets last listened trach number as current
        prepareAudio()
        updateLabels()
        assingSliderUI()
        retrievePlayerProgressSliderValue()
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        albumArtworkImageView.setRounded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer?.pause()
    }
    
    
    // Prepare audio for playing
    func prepareAudio(){
        let musicURL = URL(string:track!.previewURL!)
        audioPlayer = AVPlayer(url: musicURL!)
        
        //        audioPlayer.delegate = self
        //        audioPlayer
        audioLength = CMTimeGetSeconds((audioPlayer?.currentItem?.asset.duration)!)
        playerProgressSlider.maximumValue = CFloat(audioLength)
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        
        volumeSlider.value = 0.5
        showTotalSongLength()
        updateLabels()
        progressTimerLabel.text = "00:00"
        
        
    }
    
    //MARK:- Player Controls Methods
    func  playAudio(){
        audioPlayer.play()
        startTimer()
        updateLabels()
    }
    
    func pauseAudioPlayer(){
        audioPlayer.pause()
    }
    
    
    //MARK:-
    
    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerViewController.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    func stopTimer(){
        timer.invalidate()
        
    }
    
    
    @objc func update(_ timer: Timer){
        if !isPlaying{
            return
        }
        let time = calculateTimeFromNSTimeInterval(CMTimeGetSeconds(audioPlayer.currentTime()))
        progressTimerLabel.text  = "\(time.minute):\(time.second)"
        playerProgressSlider.value = Float(CMTimeGetSeconds(audioPlayer.currentTime()))
        UserDefaults.standard.set(playerProgressSlider.value , forKey: "playerProgressSliderValue")
        
        
    }
    
    func retrievePlayerProgressSliderValue(){
        let playerProgressSliderValue =  UserDefaults.standard.float(forKey: "playerProgressSliderValue")
        if playerProgressSliderValue != 0 {
            playerProgressSlider.value  = playerProgressSliderValue
            //            audioPlayer.currentTime = TimeInterval(playerProgressSliderValue)
            
            let time = calculateTimeFromNSTimeInterval(CMTimeGetSeconds(audioPlayer.currentTime()))
            progressTimerLabel.text  = "\(time.minute):\(time.second)"
            playerProgressSlider.value = Float(CMTimeGetSeconds(audioPlayer.currentTime()))
            
        }else{
            playerProgressSlider.value = 0.0
            //            audioPlayer.currentTime = 0.0
            progressTimerLabel.text = "00:00:00"
        }
    }
    
    
    
    //This returns song length
    func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
        // let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        // var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    
    
    
    func showTotalSongLength(){
        calculateSongLength()
        totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }
    
    
    
    
    func updateLabels(){
        updateArtistNameLabel()
        updateSongNameLabel()
        updateAlbumArtwork()
    }
    
    
    func updateArtistNameLabel(){
        let artistName = track?.artistName
        artistNameLabel.text = artistName
    }
    
    
    func updateSongNameLabel(){
        let songName = track?.trackName
        songNameLabel.text = songName
    }
    
    func updateAlbumArtwork(){

        DispatchQueue.global().async { [] in
            if let data = try? Data(contentsOf: NSURL(string:(self.track?.artWork)!)! as URL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async { [self] in
                        albumArtworkImageView.image = image
                    }
                }
            }
        }
    }
    
    
    
    
    func assingSliderUI () {
        let minImage = UIImage(named: "slider-track-fill")
        let maxImage = UIImage(named: "slider-track")
        let thumb = UIImage(named: "thumb")
        
        playerProgressSlider.setMinimumTrackImage(minImage, for: UIControl.State())
        playerProgressSlider.setMaximumTrackImage(maxImage, for: UIControl.State())
        playerProgressSlider.setThumbImage(thumb, for: UIControl.State())
        
        
    }
    
    
    
    @IBAction func play(_ sender : AnyObject) {
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        if isPlaying{
            isPlaying = false
            pauseAudioPlayer()
        }else{
            isPlaying = true
            playAudio()
        }
        playButton.setImage(isPlaying ? pause : play, for: UIControl.State())
    }
    
    @IBAction func addToFavourites(_ sender: Any) {
        if flag == false {
        flag = true
        favButton.setImage(UIImage(named: "heart2"), for: .normal)
            FavouritesViewController.tracks.append(track!)
            print(FavouritesViewController.tracks)
            print("appended")
        }
    }
    
    
    @IBAction func next(_ sender : AnyObject) {
    }
    
    
    @IBAction func previous(_ sender : AnyObject) {
    }
    
    
    
    
    @IBAction func changeAudioLocationSlider(_ sender : UISlider) {
        //        audioPlayer.currentTime = TimeInterval(sender.value)
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        audioPlayer!.seek(to: targetTime)
        
    }
    
    @IBAction func changeVolume(_ sender: Any) {
        let value = volumeSlider.value
        audioPlayer?.volume = value
    }
    
    
    
    
    @IBAction func userTapped(_ sender : UITapGestureRecognizer) {
        play(self)
    }
    
    @IBAction func userSwipeLeft(_ sender : UISwipeGestureRecognizer) {
        next(self)
    }
    
    @IBAction func userSwipeRight(_ sender : UISwipeGestureRecognizer) {
        previous(self)
    }
    
    @IBAction func userSwipeUp(_ sender : UISwipeGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    
}

fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
