//
//  ConfigurationViewController.swift
//  DynamicAppResizer
//
//  Created by Marcos Griselli on 08/09/2018.
//

import UIKit

internal class ConfigurationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var orientationSection: UIView!
    @IBOutlet weak var orientationStackView: UIStackView!
    @IBOutlet weak var deviceStackView: UIStackView!
    @IBOutlet weak var textSizeLabel: UILabel!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    /// TODO: - Set default correctly.
    /// Selected orientation for layout
    private var selectedOrientation: Orientation = .portrait {
        didSet {
            update?(selectedOrientation, selectedDevice, selectedTextSize)
        }
    }
    
    /// Selected device for layout
    private var selectedDevice = Device(size: UIScreen.main.bounds.size) ?? .phone4_7inch {
        didSet {
            update?(selectedOrientation, selectedDevice, selectedTextSize)
        }
    }
    
    /// Selected content size for layout
    private var selectedTextSize: UIContentSizeCategory = .large {
        didSet {
            update?(selectedOrientation, selectedDevice, selectedTextSize)
        }
    }
    
    /// TODO: - Select available font sizes.
    /// Devices to be listed on the configuration view
    var supportedDevices: [Device] = Device.allCases {
        didSet {
            set(devices: supportedDevices)
        }
    }
    
    /// Available content size categories
    let textSizes: [UIContentSizeCategory] = [.extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge, .extraExtraExtraLarge, .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge]
    
    /// Update layout closure
    var update: ((Orientation, Device, UIContentSizeCategory) -> Void)?

    /// Takes a Screenshot of the current layout closure
    var takeScreenshot: (() -> Void)?
    
    open override var shouldAutorotate: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    init() {
        super.init(nibName: String(describing: ConfigurationViewController.self),
                   bundle: Bundle(for: ConfigurationViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        /// TODO: - Create UIStyle
        view.layer.cornerRadius = 12.0
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: -2)

        /// Setup
        orientationSection.isHidden = !UIApplication.shared.supportsPortraitAndLandscape
        set(devices: supportedDevices)
    }
    
    /// Set the available devices on screen
    ///
    /// - Parameter devices: devices to be listed
    private func set(devices: [Device]) {
        deviceStackView.removeArrangedSubviews()
        for device in devices {
            let button = Button(style: .normal)
            button.setTitle(device.name, for: .normal)
            button.addTarget(self, action: #selector(deviceSelected(_:)), for: .touchUpInside)
            button.accessibilityIdentifier = device.name
            deviceStackView.addArrangedSubview(button)
        }
    }

    @IBAction func portraitSelected(_ sender: Button) {
        select(button: sender, from: orientationStackView)
        selectedOrientation = .portrait
    }
    
    @IBAction func landscapeSelected(_ sender: Button) {
        select(button: sender, from: orientationStackView)
        selectedOrientation = .landscape
    }
    
    @IBAction func deviceSelected(_ sender: Button) {
        select(button: sender, from: deviceStackView)
        guard let index = deviceStackView.arrangedSubviews.index(of: sender) else {
            return
        }
        selectedDevice = supportedDevices[index]
    }
    
    @IBAction func updateText(_ sender: UISlider) {
        let textSize = textSizes[Int(sender.value)]
        textSizeLabel.text = textSize.rawValue
        selectedTextSize = textSize
    }
    
    @IBAction func takeScreenshot(_ sender: Button) {
        takeScreenshot?()
    }

    private func select(button: Button, from stackView: UIStackView) {
        stackView.arrangedSubviews
            .compactMap { $0 as? Button }
            .forEach { $0.set(style: .normal) }
        button.set(style: .selected)
    }
}
