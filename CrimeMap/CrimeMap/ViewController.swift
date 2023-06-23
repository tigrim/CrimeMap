//
//  ViewController.swift
//  CrimeMap
//

import MapKit

final class ViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    @IBOutlet private weak var filterButton: UIButton! {
        didSet {
            filterButton.layer.cornerRadius = 25
        }
    }

    // Geographical center of Ukraine
    private let region = (center: CLLocationCoordinate2D(latitude: 49.0139, longitude: 31.2858), delta: 0.1)
    
    private var descriptionPanelView: DescriptionPanelView!
    private var resultCount: Int = 0

    private lazy var manager: ClusterManager = { [unowned self] in
        let manager = ClusterManager()
        manager.delegate = self
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 3
        manager.clusterPosition = .nearCenter
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.add(MeAnnotation(coordinate: region.center))
        let annotations = AnnotationService.shared.getAnotations()
        resultCount = annotations.count
        if !annotations.isEmpty {
            manager.add(annotations)
            manager.reload(mapView: mapView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.mapView.fitAll(annotations)
            }
        }
        setupDescriptionPanel()
        descriptionPanelView.configure(count: annotations.count)
    }

    private func setupDescriptionPanel() {
        descriptionPanelView = .initFromNib()
        descriptionPanelView.clipsToBounds = true
        descriptionPanelView.layer.cornerRadius = 12
        descriptionPanelView.onSearchAction = { [weak self, weak descriptionPanelView] from, till in
            guard let self else {
                return
            }
            let annotations = AnnotationService.shared.getAnnotation(fromDate: from, tillDate: till)
            resultCount = annotations.count
            descriptionPanelView?.updateResult(count: self.resultCount)
            manager.removeAll()
            if !annotations.isEmpty {
                manager.add(annotations)
                manager.reload(mapView: self.mapView) { [weak mapView] _ in
                    mapView?.fitAll(annotations)
                }
            } else {
                manager.reload(mapView: mapView)
            }
        }
        descriptionPanelView.onClearAction = { [weak self, weak descriptionPanelView] in
            guard let self else {
                return
            }
            let annotations = AnnotationService.shared.getAllPreparedAnnotations()
            resultCount = annotations.count
            descriptionPanelView?.updateResult(count: self.resultCount)
            if !annotations.isEmpty {
                manager.removeAll()
                manager.add(annotations)
                manager.reload(mapView: self.mapView)
            }
        }
        descriptionPanelView.onCloseAction = { [weak self] in
            self?.showDescriptionPannelView(false)
        }
        view.addSubview(descriptionPanelView)
        descriptionPanelView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            descriptionPanelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            descriptionPanelView.heightAnchor.constraint(equalToConstant: 500),
            descriptionPanelView.widthAnchor.constraint(equalToConstant: 320)
        ])
        descriptionPanelView.alpha = 0
    }

    private func showDescriptionPannelView(_ show: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.descriptionPanelView?.alpha = show ? 1 : 0
            self.filterButton.alpha = show ? 0 : 1
        })
    }

    @IBAction private func onFilterButtonTap(_ sender: UIButton? = nil) {
        showDescriptionPannelView(true)
    }
}

extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ClusterAnnotation {
            let identifier = "Cluster\(0)"
            let selection = Selection(rawValue: 0)!
            return mapView.annotationView(selection: selection, annotation: annotation, reuseIdentifier: identifier)
        } else if let annotation = annotation as? MeAnnotation {
            let identifier = "Me"
            let annotationView = mapView.annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            annotationView.image = .me
            return annotationView
        } else {
            let identifier = "Pin"
            let annotationView = mapView.annotationView(of: MKPinAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            annotationView.animatesDrop = true
            annotationView.pinTintColor = .red
            return annotationView
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        manager.reload(mapView: mapView)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }

        if let cluster = annotation as? ClusterAnnotation {
            var zoomRect = MKMapRect.null
            for annotation in cluster.annotations {
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                if zoomRect.isNull {
                    zoomRect = pointRect
                } else {
                    zoomRect = zoomRect.union(pointRect)
                }
            }
            mapView.setVisibleMapRect(zoomRect, animated: true)
        } else if let pin = annotation as? Annotation {
            descriptionPanelView.update(item: pin.crime, count: resultCount)
            if descriptionPanelView.alpha == 0 {
                showDescriptionPannelView(true)
            }
        }
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            views.forEach { $0.alpha = 1 }
        }, completion: nil)
    }

}

extension ViewController: ClusterManagerDelegate {

    func cellSize(for zoomLevel: Double) -> Double? {
        return nil
    }

    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        return !(annotation is MeAnnotation)
    }

}

extension ViewController {
    enum Selection: Int {
        case count, imageCount, image
    }
}

extension MKMapView {
    func annotationView(selection: ViewController.Selection, annotation: MKAnnotation?, reuseIdentifier: String) -> MKAnnotationView {
        switch selection {
        case .count:
            let annotationView = annotationView(of: CountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.backgroundColor = .red
            return annotationView
        case .imageCount:
            let annotationView = annotationView(of: ImageCountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.textColor = .red
            annotationView.image = .pin2
            return annotationView
        case .image:
            let annotationView = annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.image = .pin
            return annotationView
        }
    }
}

final class MeAnnotation: Annotation {}
