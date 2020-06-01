//
//  Button.swift
//  
//
//  Created by Tobbe on 2020-05-24.
//

import Foundation
import UIKit


@available(iOS 12.0, *)
@objc public protocol ButtonSelectionDelegate: class {

    func didTapButton(_ button: Button)
}


@available(iOS 12.0, *)
public class Button: UIView {

    public var label = UILabel()
    public var detailLabel = UILabel()
    public var imageView = UIImageView()
    
    public var selectionBlock: (() -> Void)?
    
    private var tapRecognizer: UITapGestureRecognizer!
    private var defaultTransform: CGAffineTransform?
    private var isDisplayingFeedback: Bool = false
    private var feedbackColorView: UIView?
    
    @IBOutlet public weak var selectionDelegate: ButtonSelectionDelegate?
    
    private var debugMode: Bool = false
    
    public var spinner: Spinner!
    
    
    // MARK: - Class Settings (affects all buttons in project)
    
    
    static public var destructiveColor = UIColor(hex: "FB0002")
    static public var destructiveTextColor = UIColor(hex: "FFFFFF")
    
    static public let regularFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
    static public let smallFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
    
    static public let regularDetailFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
    static public let smallDetailFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    static public let regularCenterredDetailFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
    static public let smallCenterredDetailFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
    
    static public let iconSize = CGSize(width: 30, height: 30)
    
    static public var regularCornerRadius: CGFloat?
    static public var smallCornerRadius: CGFloat?
    
    
    // MARK: - Style Settings
    
    
    public var defaultColor = UIColor(hex: "293440") // overridable in instances by setting individual colors
    
    @IBInspectable public var text: String = "..." { didSet { updateViews() } }
    @IBInspectable public var detailText: String? { didSet { updateViews() } }
    
    @IBInspectable public var iconImage: UIImage? { didSet { updateViews() } }
    
    @IBInspectable public var textColor: UIColor? { didSet { updateViews() } }
    @IBInspectable public var borderColor: UIColor? { didSet { updateViews() } }
    @IBInspectable public var borderWidth: CGFloat = 2 { didSet { updateViews() } }
    
    @IBInspectable public var cornerRadius: CGFloat = 5 { didSet { updateViews() } }
    @IBInspectable public var edgePadding: CGFloat = 20.0 { didSet { updateViews() } }
    
    @IBInspectable public var isDestructive: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isFeedbackEnabled: Bool = true { didSet { updateViews() } }
    @IBInspectable public var shadowOpacity: Float = 0.0 { didSet { updateViews() } }
    
    
    // MARK: - Only for Interface Builder (@IBInspectable doesn't support enums :-/)
    
    
    @IBInspectable public var isSmallSize: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isBordered: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isPlain: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isCenterred: Bool = false { didSet { updateViews() } }
    
    
    // MARK: - Enums
    
    
    public enum Size: CGFloat {
    
        case regular = 50.0 // Change to update regular height
        case small = 40.0 // Change to update small height
    }
    
    public enum Style {
    
        case filled
        case border
        case plain
        case destructive
    }
    
    public enum Layout {
    
        case regular
        case detailCenter
        case detailRight
        case icon
    }
    
    
    // MARK: - Init
    
    
    public convenience init(width: CGFloat, color: UIColor?, style: Button.Style?, size: Button.Size?) {
    
        self.init()
        
        self.didInit(width: width, text: nil, color: color, style: style, size: size, block: nil)
    }
    
    public convenience init(width: CGFloat, text: String?, color: UIColor?, style: Button.Style?, size: Button.Size?, block: (() -> Void)?) {
    
        self.init()
        
        self.didInit(width: width, text: text, color: color, style: style, size: size, block: block)
    }
    
    private func didInit(width: CGFloat, text: String?, color: UIColor?, style: Button.Style?, size: Button.Size?, block: (() -> Void)?) {
    
        self.text = text ?? ""
        
        if style == .border { self.isBordered = true }
        if style == .plain { self.isPlain = true }
        if style == .destructive { self.isDestructive = true }
        
        if size == .small { self.isSmallSize = true }
        
        self.defaultColor = color ?? defaultColor
        self.backgroundColor = defaultColor
        
        self.frame.size.width = width
        self.selectionBlock = block
        
        self.updateViews()
    }
    
    public override func awakeFromNib() {
    
        super.awakeFromNib()
        
        self.updateViews()
    }
    
    
    // MARK: - Setup
    
    
    private func updateViews() {
    
        self.initTapRecognizer()
        self.initSpinner()
        self.initBackground()
        self.initLabel()
        self.initDetailLabel()
        self.initImageView()
        self.initShadow()
    }
    
    private func initTapRecognizer() {
    
        guard tapRecognizer == nil else { return }
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapRecognizer)
    }
    
    private func initSpinner() {
    
        guard spinner == nil else { return }
        
        self.spinner = Spinner(color: self.updatedTextColor)
        self.spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
        self.spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        self.addSubview(spinner)
    }
    
    private func initBackground() {
    
        self.backgroundColor = updatedBackgroundColor
        self.frame.size.height = size.rawValue
        self.layer.borderColor = updatedBorderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = updatedCornerRadius
        self.layer.masksToBounds = false
    }
    
    private func initLabel() {
    
        self.label.frame = labelFrame
        self.label.autoresizingMask = labelRezising
        self.label.textAlignment = labelAlignment
        self.label.textColor = updatedTextColor
        self.label.font = font
        self.label.text = text
        
        addSubview(label)
    }
    
    private func initDetailLabel() {
    
        self.detailLabel.frame = detailFrame
        self.detailLabel.autoresizingMask = detailRezising
        self.detailLabel.textAlignment = detailAlignment
        self.detailLabel.textColor = updatedTextColor
        self.detailLabel.font = detailFont
        self.detailLabel.text = detailText
        self.detailLabel.isHidden = isDetailHidden
        
        addSubview(detailLabel)
    }
    
    private func initImageView() {
    
        self.imageView.image = iconImage
        self.imageView.frame = imageFrame
        self.imageView.autoresizingMask = imageRezising
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isHidden = isImageHidden
        
        addSubview(imageView)
    }
    
    private func initShadow() {
    
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = self.style == .filled ? shadowOpacity : 0.0
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    
    // MARK: - Deinit
    
    
    deinit {
    
        self.selectionDelegate = nil
        self.selectionBlock = nil
    
    }

}


// MARK: - Detail Text


extension Button {

    public func setDetailText(_ detailText: String) {
    
        //print("setDetailText: \(detailText)")
    }
}



// MARK: - Label Layout


extension Button {

    private var labelFrame: CGRect {

        if layout == .icon { return CGRect(x: edgePadding, y: 0, width: bounds.midX, height: bounds.height) }
        if layout == .detailRight { return CGRect(x: edgePadding, y: 0, width: bounds.midX, height: bounds.height) }
        if layout == .detailCenter { return CGRect(x: edgePadding, y: 0, width: bounds.width - edgePadding*2, height: bounds.height * 0.7) }
        
        return self.bounds.insetBy(dx: edgePadding, dy: 0)
    }

    private var labelAlignment: NSTextAlignment {

        if layout == .icon { return .left }
        if layout == .detailRight { return .left }
        if layout == .detailCenter { return .center }
        
        return .center
    }

    private var labelRezising: AutoresizingMask {

        if layout == .icon { return [.flexibleWidth, .flexibleHeight, .flexibleRightMargin] }
        if layout == .detailRight { return [.flexibleWidth, .flexibleHeight, .flexibleRightMargin] }
        if layout == .detailCenter { return [.flexibleWidth, .flexibleHeight] }
        
        return [.flexibleWidth, .flexibleHeight]
    }
}


// MARK: - Detail Label Layout


extension Button {

    private var detailFrame: CGRect {

        if layout == .detailCenter { return CGRect(x: edgePadding, y: bounds.height * 0.36, width: bounds.width - edgePadding*2, height: bounds.height * 0.64) }
        
        let padding = size == .small ? edgePadding/1.50 : edgePadding
        
        return CGRect(x: bounds.midX, y: 0, width: bounds.midX - padding, height: bounds.height)
    }

    private var detailAlignment: NSTextAlignment {

        if layout == .detailCenter { return .center }
        
        return .right
    }

    private var detailRezising: AutoresizingMask {

        if layout == .detailCenter { return [.flexibleWidth, .flexibleHeight] }
        
        return [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin]
    }

    private var isDetailHidden: Bool {

        return detailText == nil || !isImageHidden
    }
}


// MARK: - Image Layout


extension Button {

    private var imageFrame: CGRect {

        let padding = size == .small ? edgePadding/2 : edgePadding
        let iconSize = size == .small ? CGSize(width: Button.iconSize.width * 0.8, height: Button.iconSize.height * 0.8) : Button.iconSize
        
        return CGRect(x: bounds.width - iconSize.width - padding, y: (bounds.height - iconSize.height)/2, width: iconSize.width, height: iconSize.height)
    }

    private var imageRezising: AutoresizingMask {

        return [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }

    private var isImageHidden: Bool {

        return iconImage == nil
    }
}


// MARK: - Colors


extension Button {

    private var updatedTextColor: UIColor {

        if self.isDestructive, style == .border { return Button.destructiveColor }
        if self.isDestructive, style == .filled { return Button.destructiveTextColor }
        if self.isDestructive, style == .plain { return Button.destructiveColor }
        
        if let textColor = textColor { return textColor }
        
        if style == .border, let borderColor = borderColor { return borderColor }
        if style == .filled, let backdropColor = backdropColor { return backdropColor }
        if style == .filled { return backgroundColor?.contrast(intensity: 1.0) ?? defaultColor }
        
        if let backdropColor = backdropColor { return backdropColor.contrast(intensity: 1.0) }
        
        return defaultColor
    }

    private var updatedBorderColor: UIColor {

        if self.isDestructive { return Button.destructiveColor }
        
        if style == .border, let borderColor = borderColor { return borderColor }
        if style == .border { return updatedTextColor }
        
        return UIColor.clear
    }

    private var updatedBackgroundColor: UIColor {

        if style == .border { return UIColor.clear }
        if style == .plain { return UIColor.clear }
        
        if self.isDestructive { return Button.destructiveColor }
        
        return backgroundColor ?? UIColor.clear
    }

    var backdropColor: UIColor? {

        return superview?.backgroundColor
    }
}


// MARK: - Size


extension Button {

    private var size: Button.Size {

        if isSmallSize { return .small }
        
        return .regular
    }
}


// MARK: - Style


extension Button {

    private var style: Button.Style {

        if self.isBordered { return .border }
        if self.isPlain { return .plain }
        
        return .filled
    }
}


// MARK: - Layout


extension Button {

    private var layout: Button.Layout {

        if let _ = iconImage { return .icon }
        if !isDetailHidden, isCenterred { return .detailCenter }
        if !isDetailHidden { return .detailRight }
        
        return .regular
    }
}


// MARK: - Font


extension Button {

    private var font: UIFont {

        if self.size == .small { return Button.smallFont }
        
        return Button.regularFont
    }

    private var detailFont: UIFont {

        if self.size == .small, layout == .detailCenter { return Button.smallCenterredDetailFont }
        if self.size == .regular, layout == .detailCenter { return Button.regularCenterredDetailFont }
        if self.size == .small { return Button.smallDetailFont }
        
        return Button.regularDetailFont
    }
}


// MARK: - Corner Radius


extension Button {

    private var updatedCornerRadius: CGFloat {

        if let cornerRadius = Button.regularCornerRadius, size == .regular { return cornerRadius }
        if let cornerRadius = Button.smallCornerRadius, size == .small { return cornerRadius }
        
        return cornerRadius
    }
}


// MARK: - Selections


extension Button {

    @objc private func didTap() {

        guard !self.spinner.isAnimating else { stopSpinner(); return }
        
        selectionDelegate?.didTapButton(self)
        selectionBlock?()
        
        startSpinner()

    }

    public func simulateTap() {

        guard !self.spinner.isAnimating else { stopSpinner(); return }
        
        self.tapBegan()
        
        selectionBlock?()
        startSpinner()
        
        Dispatch.main(after: 0.100) {
            self.tapEnded()
        }

    }
}


// MARK: - Spinner


extension Button {

    public func startSpinner() {

        self.label.isHidden = true
        self.detailLabel.isHidden = true
        self.imageView.isHidden = true
        self.spinner.color = self.updatedTextColor
        self.spinner.startAnimating()

    }

    public func stopSpinner() {

        self.label.isHidden = false
        self.detailLabel.isHidden = isDetailHidden
        self.imageView.isHidden = isImageHidden
        self.spinner.stopAnimating()

    }
}


// MARK: - Touch Feedback


extension Button {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesBegan(touches, with: event); self.tapBegan()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesCancelled(touches, with: event); tapEnded()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event); tapEnded()
    }

    private func tapBegan() {

        if style == .plain { colorFeedback(); return }
        
        self.scaleFeedback()
    }

    private func tapEnded() {

        if style == .plain { resetColor(); return }
        
        self.resetScale()
        
    }

    func scaleFeedback() {

        guard !isDisplayingFeedback else { return }
        
        self.defaultTransform = self.transform
        self.isDisplayingFeedback = true
        
        UIView.animate(withDuration: 0.050, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
        
            self.transform = self.transform.scaledBy(x: 0.99, y: 0.97)
        
        }, completion: nil)
    }

    func resetScale() {

        self.isDisplayingFeedback = false
        
        UIView.animate(withDuration: 1.000, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
        
            self.transform = self.defaultTransform ?? CGAffineTransform.identity
        
        }, completion: nil)
    }

    func colorFeedback() {

        guard !isDisplayingFeedback else { return }
        guard self.feedbackColorView == nil else { return }
        
        self.isDisplayingFeedback = true
        
        self.feedbackColorView = UIView(frame: bounds)
        self.feedbackColorView!.layer.cornerRadius = updatedCornerRadius
        self.feedbackColorView!.layer.borderColor = updatedTextColor.cgColor
        self.feedbackColorView!.layer.borderWidth = 2
        self.feedbackColorView!.alpha = 1.00
        
        addSubview(feedbackColorView!)
    }

    func resetColor() {

        self.isDisplayingFeedback = false
        
        guard let view = feedbackColorView else { return }
        
        feedbackColorView = nil
        
        UIView.animate(withDuration: 1.000, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
        
            view.alpha = 0
        
        }, completion: nil)
    }
}
