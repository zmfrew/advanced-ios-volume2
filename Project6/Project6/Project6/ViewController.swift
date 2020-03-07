import StoreKit
import UIKit

class ViewController: UIViewController {
    // curl -v -H 'Authorization: Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXVFo4M0ZOUTYifQ.eyJpc3MiOiJQS0s4N1M2Sk5ZIiwiaWF0IjoxNTgzNTk4NDYyLCJleHAiOjE1ODM2NDE2NjJ9.RqGF3Gp8j-Rv-tdSfK0xacIvGUg5fmh20bVXypWzfoZNIx4HOkiva1RiOXoWDTxoOjE4WNALpRKuqcR-w7sJVA' "https://api.music.apple.com/v1/catalog/us/artists/36954"
    let developToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXVFo4M0ZOUTYifQ.eyJpc3MiOiJQS0s4N1M2Sk5ZIiwiaWF0IjoxNTgzNTk4NDYyLCJleHAiOjE1ODM2NDE2NjJ9.RqGF3Gp8j-Rv-tdSfK0xacIvGUg5fmh20bVXypWzfoZNIx4HOkiva1RiOXoWDTxoOjE4WNALpRKuqcR-w7sJVA"
    let urlSession = URLSession(configuration: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let play = UIButton(type: .system)
        view.addSubview(play)
        play.translatesAutoresizingMaskIntoConstraints = false
        play.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        play.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        play.heightAnchor.constraint(equalToConstant: 80).isActive = true
        play.setTitle("Start Game", for: .normal)
        play.addTarget(self, action: #selector(startGame), for: .touchUpInside)
    }
    
    @objc func startGame() {
        switch SKCloudServiceController.authorizationStatus() {
        case .notDetermined:
            SKCloudServiceController.requestAuthorization { [weak self] authorizationStatus in
                DispatchQueue.main.async {
                    self?.startGame()
                }
            }
            
        case .authorized:
            requestCapabilities()
        default:
            showNoGameMessage("We don't have permission to use your Apple Music library.")
        }
    }
    
    func fetchSongs(countryCode: String) {
        var urlRequest = URLRequest(url: URL(string: "https://api.music.apple.com/v1/catalog/\(countryCode)/charts?types=songs")!)
        urlRequest.addValue("Bearer \(developToken)", forHTTPHeaderField: "Authorization")
        
        urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    let musicResult = try decoder.decode(MusicResult.self, from: data)
                    if let songs = musicResult.results.songs.first?.data {
                        let shuffledSongs = songs.shuffled()
                        // show our game controller
                        return
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
                self.showNoGameMessage("Unable to fetch data from Apple Music")
            }
        }.resume()
    }
    
    func requestCapabilities() {
        let controller = SKCloudServiceController()
        controller.requestCapabilities { capabilities, error in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if capabilities.contains(.musicCatalogPlayback) {
                    controller.requestStorefrontCountryCode { country, _ in
                        if let country = country {
                            self.fetchSongs(countryCode: country)
                        } else {
                            self.showNoGameMessage("Unable to determine country code.")
                        }
                    }
                } else if capabilities.contains(.musicCatalogSubscriptionEligible) {
                    let subscribeController = SKCloudServiceSetupViewController()
                    let options: [SKCloudServiceSetupOptionsKey: Any] = [
                        .action: SKCloudServiceSetupAction.subscribe,
                        .messageIdentifier: SKCloudServiceSetupMessageIdentifier.playMusic
                    ]
                    
                    subscribeController.load(options: options) { didSucceedLoading, error in
                        if didSucceedLoading {
                            self.present(subscribeController, animated: true)
                        } else {
                            self.showNoGameMessage(error?.localizedDescription ?? "Unknown error")
                        }
                    }
                } else {
                    self.showNoGameMessage("You aren't eligible to subscribe to Apple Music.")
                }
            }
        }
    }
    
    func showNoGameMessage(_ message: String) {
        let ac = UIAlertController(title: "No game for you", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
