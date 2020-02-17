import UIKit
import SpriteKit
import ARKit
import CoreLocation

class ViewController: UIViewController, ARSKViewDelegate {
    @IBOutlet var sceneView: ARSKView!
    
    private var headingCount = 0
    private let locationManager = CLLocationManager()
    private var pages = [UUID: String]()
    private var sightsJSON: JSON!
    private var userHeading = 0.0
    private var userLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = AROrientationTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        let labelNode = SKLabelNode(text: pages[anchor.identifier])
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        let size = labelNode.frame.size.applying(CGAffineTransform(scaleX: 1.1, y: 1.4))
        
        let backgroundNode = SKShapeNode(rectOf: size, cornerRadius: 10)
        
        backgroundNode.fillColor = UIColor(hue: CGFloat.random(in: 0...1), saturation: 0.5, brightness: 0.4, alpha: 0.9)
        backgroundNode.strokeColor = backgroundNode.fillColor.withAlphaComponent(1)
        backgroundNode.lineWidth = 2
        
        backgroundNode.addChild(labelNode)
        return backgroundNode
    }
}

extension ViewController {
    func createSights() {
        for page in sightsJSON["query"]["pages"].dictionaryValue.values {
            let locationLat = page["coordinates"][0]["lat"].doubleValue
            let locationLon = page["coordinates"][0]["lon"].doubleValue
            let location = CLLocation(latitude: locationLat, longitude: locationLon)
            let distance = Float(userLocation.distance(from: location))
            
            let azimuthFromUser = direction(from: userLocation, to: location)
            let angle = azimuthFromUser - userHeading
            let angleRadians = deg2rad(angle)
            
            let rotationHorizontal = simd_float4x4(SCNMatrix4MakeRotation(Float(angleRadians), 1, 0, 0))
            let rotationVertical = simd_float4x4(SCNMatrix4MakeRotation(-0.2 + Float(distance / 6000), 0, 1, 0))
            let rotation = simd_mul(rotationHorizontal, rotationVertical)
            
            guard let sceneView = self.view as? ARSKView else { return }
            guard let frame = sceneView.session.currentFrame else { return }
            let rotation2 = simd_mul(frame.camera.transform, rotation)
            
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -(distance / 200)
            let transform = simd_mul(rotation2, translation)
            
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            pages[anchor.identifier] = page["title"].string ?? "Unknown"
        }
    }
    
    func deg2rad(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
    
    func direction(from p1: CLLocation, to p2: CLLocation) -> Double {
        let lat1 = deg2rad(p1.coordinate.latitude)
        let lon1 = deg2rad(p1.coordinate.longitude)

        let lat2 = deg2rad(p2.coordinate.latitude)
        let lon2 = deg2rad(p2.coordinate.longitude)

        let lon_delta = lon2 - lon1;
        let y = sin(lon_delta) * cos(lon2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon_delta)
        let radians = atan2(y, x)
        return rad2deg(radians)
    }
    
    func fetchSights() {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(userLocation.coordinate.latitude)%7C\(userLocation.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        guard let url = URL(string: urlString) else { return }
        
        if let data = try? Data(contentsOf: url) {
            sightsJSON = JSON(data)
            locationManager.startUpdatingHeading()
        }
    }
    
    func rad2deg(_ radians: Double) -> Double {
        radians * 180 / .pi
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.headingCount += 1
            if self.headingCount != 2 { return }
            
            self.userHeading = newHeading.magneticHeading
            self.locationManager.stopUpdatingHeading()
            self.createSights()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        userLocation = location
        
        DispatchQueue.global().async {
            self.fetchSights()
        }
    }
}
