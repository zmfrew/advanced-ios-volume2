import UIKit

class FilesViewController: UITableViewController {
    let books = [
        "Advanced iOS Volume One",
        "Beyond Code",
        "Hacking with macOS",
        "Hacking with Swift",
        "Hacking with tvOS",
        "Hacking with watchOS",
        "Objective-C for Swift Developers",
        "Practical iOS 11",
        "Pro Swift",
        "Server-Side Swift",
        "Swift Coding Challenges"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Books"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = books[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navController = splitViewController?.viewControllers[1] as? UINavigationController,
            let viewController = navController.viewControllers[0] as? ViewController else { return }
        
        viewController.load(books[indexPath.row])
    }
}
