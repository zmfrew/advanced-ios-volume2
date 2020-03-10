import MediaPlayer
import UIKit

final class PlayViewController: UIViewController {
    var currentSong = ""
    let musicPlayerController: MPMusicPlayerController = .systemMusicPlayer
    var player1: PlayerView!
    var player2: PlayerView!
    let score1Label = UILabel()
    let score2Label = UILabel()
    var score1 = 0 {
        didSet {
            score1Label.text = "RED: \(score1)"
        }
    }
    var score2 = 0 {
        didSet {
            score2Label.text = "RED: \(score2)"
        }
    }
    var songs = [Song]()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePlayerViews()
        configureScoreLabels()
    }
    
    func configurePlayerViews() {
        player1 = PlayerView(color: .red, songs: songs, delegate: self)
        player2 = PlayerView(color: .blue, songs: songs, delegate: self)
        
        player1.backgroundColor = .red
        player2.backgroundColor = .blue
        
        for case let playerView? in [player1, player2] {
            playerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(playerView)
            
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5, constant: -25).isActive = true
        }
        
        player1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        player1.transform = CGAffineTransform(rotationAngle: .pi)
        player2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func configureScoreLabels() {
        for score in [score1Label, score2Label] {
            score.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(score)
            
            score.textAlignment = .center
            score.textColor = .white
            score.font = UIFont.boldSystemFont(ofSize: 18)
            score.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            score.heightAnchor.constraint(equalToConstant: 50).isActive = true
            score.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        }
        
        score1Label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        score1Label.backgroundColor = .red
        score1Label.transform = CGAffineTransform(rotationAngle: .pi)
        
        score2Label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        score2Label.backgroundColor = .blue
        
        score1 = 0
        score2 = 0
    }
    
    func playSong() {
        if let song = songs.popLast() {
            currentSong = song.attributes.name
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: [song.id])
            musicPlayerController.setQueue(with: descriptor)
            musicPlayerController.play()
        } else {
            musicPlayerController.stop()
            let ac = UIAlertController(title: "Game over!", message: "Player 1: \(score1)\nPlayer 2: \(score2)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true)
        }
    }
    
    func selectTapped(player: UIColor, answer: String) {
        if answer == currentSong {
            if player == .red {
                score1 += 1
            } else {
                score2 += 1
            }
            
            playSong()
        }
    }
}
