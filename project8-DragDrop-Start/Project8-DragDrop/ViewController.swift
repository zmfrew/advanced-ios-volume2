//
//  ViewController.swift
//  Project8-DragDrop
//
//  Created by Paul Hudson on 24/06/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    // create a selection of the usual meaningless names paint manufacturers choose
    let shadeNames = [
        ["Frosted %@", "Pale %@", "Soft %@"],
        ["%@ Breeze", "Gentle %@", "%@ Glow"],
        ["Warm %@", "Wild %@", "%@ Crush"],
        ["Sumptuous %@", "%@ Ripple", "%@ Tension"],
        ["Deep %@", "Rich %@", "%@ Delight"],
        ["%@ Shadows", "Intense %@", "Alpine %@"]
    ]

    // map color groups to their hues
    let colors: [String: CGFloat] = ["Blue": 0.6, "Brown": 0.05, "Green": 0.4, "Purple": 0.8, "Red": 0]

    // create an array of all the color group names – blue, brown, etc
    var colorNames = [String]()

    // this stores all color shades in all hues
    var colorBlends = [String: [(name: String, color: UIColor)]]()

    // this stores the user's favorite colors
    var favoriteBlends = [(name: String, color: UIColor)]()

    // this holes an example for each color group
    var colorPreviews = [String: UIColor]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dropDelegate = self
        
        title = "Hues"
        tableView.rowHeight = 100
        tableView.separatorInset = .zero

        // generate a range of shades for each color
        for (colorIndex, baseColor) in colors.keys.sorted().enumerated() {
            guard let colorHue = colors[baseColor] else { continue }
            var blends = [(name: String, color: UIColor)]()

            for (index, name) in shadeNames.enumerated() {
                // make the colors get darker and more saturated
                let brightness = 1 - (CGFloat(index) / 8)
                let saturation = (CGFloat(index) / 6) + 0.1
                let color = UIColor(hue: colorHue, saturation: saturation, brightness: brightness, alpha: 1)

                // pick a random silly name, then insert our color group in place of the %@
                let baseName = name[colorIndex % name.count]
                let parsedName = baseName.replacingOccurrences(of: "%@", with: baseColor)
                blends.append((name: parsedName, color: color))
            }

            colorBlends[baseColor] = blends
        }

        // store all the base color groups (blue, brown, etc)
        colorNames = colors.keys.sorted()

        // create a sample color for each color group
        for (colorName, blends) in colorBlends {
            colorPreviews[colorName] = blends[2].color
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // favorites, then everything else
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return colorBlends.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24, weight: .light)

        // this is a template image; we can tint it based on our example color for this group
        cell.imageView?.image = UIImage(named: "star")

        if indexPath.section == 0 {
            cell.textLabel?.text = "Favorites"
            cell.imageView?.tintColor = UIColor(white: 0.9, alpha: 1)
        } else {
            let colorName = colorNames[indexPath.row]
            cell.textLabel?.text = "\(colorName)s"
            cell.imageView?.tintColor = colorPreviews[colorName]
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navController = splitViewController?.viewControllers[1] as? UINavigationController else { return }
        guard let shadesController = navController.topViewController as? ShadesViewController else { return }

        if indexPath.section == 0 {
            shadesController.blends = favoriteBlends
        } else {
            let colorName = colorNames[indexPath.row]
            guard let blends = colorBlends[colorName] else { return }

            shadesController.blends = blends
        }
    }
}

extension ViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        for item in coordinator.items {
            if let color = item.dragItem.localObject as? (String, UIColor) {
                favoriteBlends.append(color)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if destinationIndexPath?.section == 0 {
            return UITableViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
        } else {
            return UITableViewDropProposal(operation: .forbidden)
        }
    }
}
