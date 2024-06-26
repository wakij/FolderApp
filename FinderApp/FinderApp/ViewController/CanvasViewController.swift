//
//  canvasController.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import PencilKit
import UIKit

class CanvasViewController: UIViewController, UIScrollViewDelegate, PKCanvasViewDelegate {
    
    let image: UIImage
    private var imageView: UIImageView
    private lazy var canvas: PKCanvasView = {
        return PKCanvasView(frame: CGRect(origin: .zero, size: self.view.bounds.size))
    }()
    
    private var toolPicker = PKToolPicker()
    
    init(image: UIImage) {
        self.image = image
        self.imageView = UIImageView(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        canvas.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.imageView.contentMode = .scaleAspectFit
        canvas.delegate = self
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.backgroundColor = .clear
        canvas.contentSize = imageView.bounds.size
        canvas.minimumZoomScale = 0.5
        canvas.maximumZoomScale = 5
        
        view.addSubview(canvas)
        canvas.subviews[0].addSubview(self.imageView)
        canvas.subviews[0].sendSubviewToBack(self.imageView)
        canvas.tool = PKInkingTool(.pen, color: .black, width: 30)
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .lightGray
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints  = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: self.view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            canvas.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        setUpZoomScale()
        updateContentInset()
    }
    
    @objc func closeModal() {
        toolPicker.addObserver(canvas)
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
    }
    
    func scrollViewDidZoom(_ canvas: UIScrollView) {
        updateContentInset()
    }
    
    private func updateZoomScale() {
        let widthScale = canvas.bounds.width / image.size.width
        let heightScale = canvas.bounds.height / image.size.height
        let scale = min(widthScale, heightScale)

        canvas.minimumZoomScale = scale
        canvas.maximumZoomScale = scale * 5

        // After setting minimumZoomScale, maximumZoomScale and delegate.
        canvas.zoomScale = max(canvas.minimumZoomScale, canvas.zoomScale)
    }
    
    private func setUpZoomScale() {
        let widthScale = canvas.bounds.width / image.size.width
        let heightScale = canvas.bounds.height / image.size.height
        let scale = min(widthScale, heightScale)

        canvas.minimumZoomScale = scale
        canvas.maximumZoomScale = scale * 5

        // After setting minimumZoomScale, maximumZoomScale and delegate.
        canvas.zoomScale = canvas.minimumZoomScale
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateZoomScale()
        updateContentInset()
    }
    
    func updateContentInset() {
        let widthInset = max((canvas.frame.width - imageView.frame.width * canvas.zoomScale) / 2, 0)
        let heightInset = max((canvas.frame.height - imageView.frame.height * canvas.zoomScale) / 2, 0)
        canvas.contentInset = .init(top: heightInset,
                                        left: widthInset,
                                        bottom: heightInset,
                                        right: widthInset)
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
