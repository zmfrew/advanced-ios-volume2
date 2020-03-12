import AVKit
import UIKit

class ResultsViewController: UITableViewController {
    var movieURL: URL!
    var predictions: [(time: CMTime, prediction: String)]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        predictions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let prediction = predictions[indexPath.row]
        cell.textLabel?.text = prediction.prediction
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = AVPlayer(url: movieURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        let prediction = predictions[indexPath.row]
        player.seek(to: prediction.time)
        present(playerViewController, animated: true)
    }
}
