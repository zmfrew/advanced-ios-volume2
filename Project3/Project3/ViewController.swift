import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var colorSelection: UICollectionView!
    @IBOutlet weak var postcard: UIImageView!
    
    var colors = [UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorSelection.delegate = self
        colorSelection.dataSource = self
        
        colors += [.black, .gray, .white, .yellow, .orange, .red, .magenta, .purple, .blue, .cyan, .green]

        for i in 0 ... 9 {
            for j in 1 ... 10 {
                let color = UIColor(hue: CGFloat(i) / 10, saturation: CGFloat(j) / 10, brightness: 1, alpha: 1)
                colors.append(color)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
}
