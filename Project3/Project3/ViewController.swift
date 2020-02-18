import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    @IBOutlet weak var colorSelection: UICollectionView!
    @IBOutlet weak var postcard: UIImageView!
    
    var colors = [UIColor]()
    var image: UIImage?
    var topText = "Visit London"
    var topFontName = "Helvetica Neue"
    var topColor = UIColor.white
    var bottomText = "Home of Sherlock Holmes, Paddington Bear, and James Bond"
    var bottomFontName = "Helvetica Neue"
    var bottomColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorSelection.delegate = self
        colorSelection.dataSource = self
        colorSelection.dragDelegate = self
        
        postcard.isUserInteractionEnabled = true
        let dropInteraction = UIDropInteraction(delegate: self)
        postcard.addInteraction(dropInteraction)
        
        let dragInteraction = UIDragInteraction(delegate: self)
        postcard.addInteraction(dragInteraction)
        
        colors += [.black, .gray, .white, .yellow, .orange, .red, .magenta, .purple, .blue, .cyan, .green]

        for i in 0 ... 9 {
            for j in 1 ... 10 {
                let color = UIColor(hue: CGFloat(i) / 10, saturation: CGFloat(j) / 10, brightness: 1, alpha: 1)
                colors.append(color)
            }
        }

        title = "Edit Postcard"
        splitViewController?.view.backgroundColor = .lightGray
        
        renderPostcard()
    }
    
    @IBAction func changeText(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: postcard)
        let changeTop: Bool
        
        if location.y < postcard.bounds.midY {
            changeTop = true
        } else {
            changeTop = false
        }
        
        let ac = UIAlertController(title: "Change text", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Write what you want to say"
            
            if changeTop {
                textField.text = self.topText
            } else {
                textField.text = self.bottomText
            }
        }
        
        ac.addAction(UIAlertAction(title: "Change", style: .default) { _ in
            guard let text = ac.textFields?[0].text else { return }
            
            if changeTop {
                self.topText = text
            } else {
                self.bottomText = text
            }
            
            self.renderPostcard()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true)
    }
    
    func renderPostcard() {
        let drawRect = CGRect(x: 0, y: 0, width: 3000, height: 2400)
        let topTextRect = CGRect(x: 250, y: 200, width: 2500, height: 800)
        let bottomTextRect = CGRect(x: 250, y: 1800, width: 2500, height: 600)
        
        let topFont = UIFont(name: topFontName, size: 350) ?? UIFont.systemFont(ofSize: 250)
        let bottomFont = UIFont(name: bottomFontName, size: 150) ?? UIFont.systemFont(ofSize: 100)
        
        let centered = NSMutableParagraphStyle()
        centered.alignment = .center
        
        let topTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: topColor, .font: topFont, .paragraphStyle: centered]
        let bottomTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: bottomColor, .font: bottomFont, .paragraphStyle: centered]
        
        let renderer = UIGraphicsImageRenderer(size: drawRect.size)
        
        postcard.image = renderer.image { context in
            UIColor.gray.set()
            context.fill(drawRect)
            
            image?.draw(at: CGPoint(x: 0, y: 0))
            
            topText.draw(in: topTextRect, withAttributes: topTextAttributes)
            bottomText.draw(in: bottomTextRect, withAttributes: bottomTextAttributes)
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

extension ViewController: UICollectionViewDelegate { }

extension ViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let color = colors[indexPath.item]
        let provider = NSItemProvider(object: color)
        let item = UIDragItem(itemProvider: provider)
        
        return [item]
    }
}

extension ViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let location = session.location(in: postcard)
        
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]) {
            session.loadObjects(ofClass: NSString.self) { items in
                guard let string = items.first as? String else { return }
                
                if location.y < self.postcard.bounds.midY {
                    self.topFontName = string
                } else {
                    self.bottomFontName = string
                }
                
                self.renderPostcard()
            }
        } else if session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) {
            session.loadObjects(ofClass: UIImage.self) { items in
                guard let draggedImage = items.first as? UIImage else { return }
                
                self.image = draggedImage
                self.renderPostcard()
            }
        } else {
            session.loadObjects(ofClass: UIColor.self) { items in
                guard let color = items.first as? UIColor else { return }
                
                if location.y < self.postcard.bounds.midY {
                    self.topColor = color
                } else {
                    self.bottomColor = color
                }
                
                self.renderPostcard()
            }
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        UIDropProposal(operation: .copy)
    }
}

extension ViewController: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = postcard.image else { return [] }
        
        let provider =  NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }
}
