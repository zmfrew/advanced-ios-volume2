//
//  ShadesViewController.swift
//  Project8-DragDrop
//
//  Created by Paul Hudson on 24/06/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class ShadesViewController: UICollectionViewController {
    var blends = [(name: String, color: UIColor)]() {
        didSet {
            collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Shades"
        collectionView?.dragDelegate = self
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blends.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ColorCell else { fatalError() }

        let blend = blends[indexPath.row]
        cell.swatch.backgroundColor = blend.color
        cell.textLabel.text = blend.name

        return cell
    }
    
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = collectionView?.cellForItem(at: indexPath) as? ColorCell else { return [] }
        
        let itemProvider = NSItemProvider(object: cell.swatch.backgroundColor!)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = blends[indexPath.item]
        dragItem.previewProvider = {
            let vw = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            vw.backgroundColor = cell.swatch.backgroundColor
            return UIDragPreview(view: vw)
        }
        
        return [dragItem]
    }
}

extension ShadesViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        dragItems(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        dragItems(for: indexPath)
    }
}
