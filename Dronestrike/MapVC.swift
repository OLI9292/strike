///
/// MapVC.swift
///

import CoreLocation
import GoogleMaps
import UIKit

class MapViewController: UIViewController {
    
    var mapView: GMSMapView?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let camera = GMSCameraPosition.camera(withLatitude: 33.94, longitude: 67.71, zoom: 5)
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        
        do {
            if let styleURL = Bundle.main.url(forResource: "mapStyles", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find mapStyles.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        guard let mapView = mapView else { return }
        view.insertSubview(mapView, at: 0)
        
        let layerView = UIView.init(frame: mapView.frame)
        view.addSubview(layerView)
        
        let location = CLLocation(latitude: 35.94, longitude: 69.71).coordinate
        let locationOnScreen = mapView.projection.point(for: location)
        
        let circle = circleLayer(at: locationOnScreen)
        let animated = shrink(shape: circle, origin: locationOnScreen)

        layerView.addSubview(mapImage)
        layerView.layer.addSublayer(animated)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
}


extension MapViewController {
    
    func shrink(shape: CAShapeLayer, origin: CGPoint) -> CAShapeLayer {
        let animation = CABasicAnimation(keyPath: "transform")
        var tr = CATransform3DIdentity
        tr = CATransform3DTranslate(tr, origin.x, origin.y, 0);
        tr = CATransform3DScale(tr, 3, 3, 1)
        tr = CATransform3DTranslate(tr, -origin.x, -origin.y, 0);
        animation.toValue = NSValue(caTransform3D: tr)
        animation.duration = 2.5
        shape.add(animation, forKey: "scale")
        return shape
    }
    
    func circleLayer(at origin: CGPoint) -> CAShapeLayer {
        let circlePath = UIBezierPath(
            arcCenter: origin,
            radius: CGFloat(3),
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true
        )
        let shape = CAShapeLayer()
        shape.path = circlePath.cgPath
        shape.fillColor = UIColor.yellow.cgColor
        return shape
    }
}
