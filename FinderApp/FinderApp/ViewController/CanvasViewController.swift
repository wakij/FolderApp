//
//  canvasController.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import PencilKit
import UIKit

class CanvasViewController: UIViewController {
    
    let image: UIImage
    private var imageView: UIImageView
    private var canvas: PKCanvasView
    
    init(image: UIImage) {
        self.image = image
        self.imageView = UIImageView(image: image)
        self.canvas = PKCanvasView()
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
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imageView)
        
        self.canvas = PKCanvasView()
        canvas.isOpaque = false
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        canvas.tool = PKInkingTool(.pen, color: .black, width: 30)
        
        if let window = UIApplication.shared.windows.first {
            if let toolPicker = PKToolPicker.shared(for: window) {
                toolPicker.addObserver(canvas)
                toolPicker.setVisible(true, forFirstResponder: canvas)
                canvas.becomeFirstResponder()
                
            }
        }
        
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(canvas)
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .lightGray
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints  = false
        view.addSubview(closeButton)
        
        let aspectRatio = image.size.width / image.size.height
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio).withPriority(.defaultHigh),
            closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            canvas.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            canvas.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            canvas.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            canvas.heightAnchor.constraint(equalTo: imageView.heightAnchor),
        ])
    }
    
    @objc func closeModal() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
        // 以前のキャンバスサイズを取得
        let previousSize = canvas.bounds.size
        
        coordinator.animate(alongsideTransition: { _ in
            let newSize = self.canvas.bounds.size
            let scale = newSize.width / previousSize.width
            self.canvas.drawing = self.canvas.drawing.transformed(using: CGAffineTransform(scaleX: scale, y: scale))

        }, completion: nil)
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

extension PKDrawing {
}
