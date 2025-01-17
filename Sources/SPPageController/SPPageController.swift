// The MIT License (MIT)
// Copyright © 2021 Ivan Vorobei (hello@ivanvorobei.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

public protocol SPPageControllerDelegate: AnyObject {
    func pageViewControllerDidScroll(_ controller: UIViewController)
}

open class SPPageController: UIViewController, SPPageControllerInterface {
    
    // MARK: - Data
    
    weak open var delegate: SPPageControllerDelegate?
    
    /**
     SPPageController: Manage if can be dissmiss by gester.
     Call for modal screens only.
     */
    open var allowDismissWithGester: Bool = true
    
    /**
     SPPageController: Allow or disable scroll by pages with gester.
     */
    open var allowScroll: Bool {
        get { (containerController as! SPPageControllerInterface).allowScroll }
        set { (containerController as! SPPageControllerInterface).allowScroll = newValue }
    }
    
    /**
     SPPageController: Get Childs.
     */
    open var childControllers: [UIViewController] { storedChildControllers }
    
    // MARK: - Init
    
    public init(childControllers: [UIViewController], navigationOrientation: SPPageControllerNavigationOrientation = .horizontal, system: SPPageControllerSystem) {
        self.storedChildControllers = childControllers
        switch system {
        case .page:
            let orientation: UIPageViewController.NavigationOrientation = navigationOrientation == .horizontal ? .horizontal : .vertical
            containerController = SPPageNativeController(childControllers: storedChildControllers, navigationOrientation: orientation)
        case .scroll:
            let direction: UICollectionView.ScrollDirection = navigationOrientation == .horizontal ? .horizontal: .vertical
            containerController = SPPageCollectionController(childControllers: storedChildControllers, scrollDirection: direction)
        }
        super.init(nibName: nil, bundle: nil)
        
        if let ctrl = containerController as? SPPageNativeController {
            ctrl.output = self
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
        
        addChild(containerController)
        view.addSubview(containerController.view)
        containerController.didMove(toParent: self)
        
        containerController.view.preservesSuperviewLayoutMargins = true
        containerController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerController.view.topAnchor.constraint(equalTo: view.topAnchor),
            containerController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    open func safeScrollTo(index: Int, animated: Bool) {
        (containerController as! SPPageControllerInterface).safeScrollTo(index: index, animated: animated)
    }
    
    // MARK: - Internal
    
    private var containerController: UIViewController
    private var storedChildControllers: [UIViewController]
}

// MARK: - SPPageNativeController Output

extension SPPageController: SPPageNativeControllerOutput {
    
    func pageViewControllerDidScroll(_ controller: UIViewController) {
        delegate?.pageViewControllerDidScroll(controller)
    }
}
