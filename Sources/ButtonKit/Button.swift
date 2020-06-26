//
//  Button.swift
//  
//
//  Created by Tobbe on 2020-05-24.
//

import Foundation
import UIKit


/** Implement the `ButtonSelectionDelegate` and set a `selectionDelegate` in order to receive call-backs when a button is tapped. This is *not* the recommended way though. The recommended way is to use `selectionBlock` and pass a code block to run on taps. */
@available(iOS 12.0, *)
@objc public protocol ButtonSelectionDelegate: class {

    func didTapButton(_ button: Button)
}


@available(iOS 12.0, *)
public class Button: UIView {

    /** The main title label. Display the `text` value. */
    public var label = UILabel()
    /** The secondary detail label. */
    public var detailLabel = UILabel()
    /** The `UIimageView` displaying icon image.*/
    public var imageView = UIImageView()
    /** The code block that runs on tapping the button. */
    public var selectionBlock: ((_ button: Button) -> Void)?
    
    private var target: AnyObject?
    private var selector: Selector?
    
    private var tapRecognizer: UITapGestureRecognizer!
    private var defaultTransform: CGAffineTransform?
    private var isDisplayingFeedback: Bool = false
    private var feedbackColorView: UIView?
    
    /** The delegate that receives call-backs on button taps. */
    @IBOutlet public weak var selectionDelegate: ButtonSelectionDelegate?
    
    private var debugMode: Bool = false
    
    public var spinner: Spinner!
    
    
    // MARK: - Global Settings (affects all buttons in project)
    
    /** Global setting. The color of your defualt buttons. Overridable on instances by setting specific color. */
    static public var defaultColor = UIColor(hex: "293440")
    /** Global setting. The color of your defualt button texts. Overridable on instances by setting specific color. */
    static public var defaultTextColor: UIColor?
    
    /** Global setting. The color of your destructive buttons. Overridable on instances by setting specific color. */
    static public var destructiveColor = UIColor(hex: "FB0002")
    /** Global setting. The color of your destructive button texts. Overridable on instances by setting specific color. */
    static public var destructiveTextColor = UIColor(hex: "FFFFFF")
    
    /** Global setting. The font you are using for regular sized buttons. */
    static public var regularFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
    /** Global setting. The font you are using for small sized buttons. */
    static public var smallFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
    
    /** Global setting. The font you are using for detail text on regular sized button with the regular right aligned layout. */
    static public var regularDetailFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
    /** Global setting. The font you are using for detail text on small sized button with the regular right aligned layout. */
    static public var smallDetailFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    /** Global setting. The font you are using for detail text on regular sized button with the centerred layout. */
    static public var regularCenterredDetailFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
    /** Global setting. The font you are using for detail text on small sized button with the centerred layout. */
    static public var smallCenterredDetailFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
    
    /** Global setting. The size you are using for icons from your designer. */
    static public var defaultIconSize = CGSize(width: 30, height: 30)
    
    /** Global setting. The corner radius for regular sized buttons. */
    static public var regularCornerRadius: CGFloat = 5.0
    /** Global setting. The corner radius for small sized buttons. */
    static public var smallCornerRadius: CGFloat = 3.0
    
    /** Global setting. The edge padding for left/right aligned layouts. */
    static public var defaultEdgePadding: CGFloat = 20.0
    /** Global setting. The thickness of borders for `border` styled buttons. */
    static public var defaultBorderWidth: CGFloat = 2.0
    
    /** Global setting. The height of regular sized buttons. */
    static public var regularHeight: CGFloat = 50.0
    /** Global setting. The height of small sized buttons. */
    static public var smallHeight: CGFloat = 40.0
    
    
    // MARK: - Style Settings
    
    
    /** The color of the background for `filled` styled buttons, or the border and text for `border`  styled buttons.*/
    @IBInspectable public var color: UIColor? { didSet { updateViews() } }
    
    /** The text displayed on the main `label`.*/
    @IBInspectable public var text: String = "..." { didSet { updateViews() } }
    /** Set the `detailText` to create a button with a detail label.*/
    @IBInspectable public var detailText: String? { didSet { updateViews() } }
    
    /** Set the `iconImage` to create a button with an icon.*/
    @IBInspectable public var iconImage: UIImage? { didSet { updateViews() } }
    
    /** The color of text. If this is `nil`and the style is `border`, the `color`or static `defaultColor`will be used instead.*/
    @IBInspectable public var textColor: UIColor? { didSet { updateViews() } }
    /** The color of the border. If this is `nil`the `color`or static `defaultColor`will be used instead.*/
    @IBInspectable public var borderColor: UIColor? { didSet { updateViews() } }
    /** The thickness of borders. Overrides any default values.*/
    @IBInspectable public var borderWidth: CGFloat = -1.0 { didSet { updateViews() } } // @IBInspectable doesn't support optional CGFloat. Negative means not set.
    
    /** The strength of the shadow.*/
    @IBInspectable public var shadowOpacity: Float = 0.0 { didSet { updateViews() } }
    /** The color of the shadow.*/
    @IBInspectable public var shadowColor: UIColor = UIColor.black { didSet { updateViews() } }
    /** The horizontal and vertical offset of the shadow.*/
    @IBInspectable public var shadowOffset = CGSize(width: 0, height: 4) { didSet { updateViews() } }
    /** The radius of the shadow.*/
    @IBInspectable public var shadowRadius: CGFloat = 8.0 { didSet { updateViews() } }
    
    /** The corner radius of edges. Overrides any default values.*/
    @IBInspectable public var cornerRadius: CGFloat = -1.0 { didSet { updateViews() } } // @IBInspectable doesn't support optional CGFloat. Negative means not set.
    /** The left/right edge padding for labels and icons. Overrides any default values.*/
    @IBInspectable public var edgePadding: CGFloat = -1.0 { didSet { updateViews() } } // @IBInspectable doesn't support optional CGFloat. Negative means not set.
    
    /** The size of the icon image. If nil, the default icon size will be used instead.*/
    public var iconSize: CGSize?
    
    /** Set `isFeedbackEnabled` to `false` to prevent scale and color animations on tap.*/
    @IBInspectable public var isFeedbackEnabled: Bool = true { didSet { updateViews() } }
    
    
    // MARK: - Only for Interface Builder (@IBInspectable doesn't support enums :-/)
    
    
    @IBInspectable public var isDestructive: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isSmallSize: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isBordered: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isPlain: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isCenterred: Bool = false { didSet { updateViews() } }
    @IBInspectable public var isCircle: Bool = false { didSet { updateViews() } }
    
    
    // MARK: - Enums
    
    
    /**
    There are two sizes, regular and small. To create a small sized button, either use the `Size` value when instantiating programmatically, or use the `isSmallSize` property through Interface Builder. The default heights are `50` and `40` points. In case your designer wants to change those values, you can make the changes during app loading, for example in your App Delegate, using the `regularHeight` and `smallHeight` settings. All buttons in the project will adjust their frame height.
     
    In order to help keep a coherent and consistent UI across your app, this can not be set per-button. The exception is circle buttons that can have any `diameter` you define.
            
        Button.regularHeight = 44
        Button.smallHeight = 30
        
    */
    public enum Size: CGFloat {
    
        /// Regular size.
        case regular
        /// Small size.
        case small
    }
    
    /**
    Buttons come in four main styles. A primary filled version, a secondary bordered, a plain (text only) and a destructive one.
    */
    public enum Style {
    
        /// Solid background color.
        case filled
        /// Displays border line around edges and no background color. Color of text is the same as the border, unless otherwise specified.
        case border
        /// No background color or border, only text.
        case plain
        /// Communicates a button with an action that is destructive to data or similar.
        case destructive
    }
    
    public enum Layout {
    
        /// Displays just the text label in the middle.
        case regular
        /// Displays a the text label to the top, and the detail text label to the bottom.
        case detailCenter
        /// Displays a the text label to the left, and the detail text label to the right.
        case detailRight
        /// A circle shaped button with an icon image in the center.
        case circle
        /// A rectangle shaped button with an icon image in the center or to the right.
        case icon
    }
    
    
    // MARK: - Init
    
    
    /**
     Creates a button with defined width, color, style and size.
     -
     - parameter width: The width of the buttons frame. Can be changed or animated afterwards too. It will however revert back to this value if the button style is updated.
     - parameter color: The color of either the background, for a `filled` style, or the border and text for a `border` or `plain` style. `Destructive` buttons ignore this value.
     - parameter style: Set wether you want a `filled`, `border`, `plain` or `destructive` button style.
     - parameter size: Leave nil for a regular sized button. Use `small` for a small sized button.
        
     */
    public convenience init(width: CGFloat, color: UIColor?, style: Button.Style?, size: Button.Size?) {
    
        self.init()
        
        self.didInit(width: width, text: nil, color: color, style: style, size: size, block: nil)
    }
    
    /**
    Creates a button with defined width, text, color, style and size and selection block.
    -
    - parameter width: The width of the buttons frame. Can be changed or animated afterwards too. It will however revert back to this value if the button style is updated.
    - parameter text: The title text displayed on the button.
    - parameter color: The color of either the background, for a `filled` style, or the border and text for a `border` or `plain` style. `Destructive` buttons ignore this value.
    - parameter style: Set wether you want a `filled`, `border`, `plain` or `destructive` button style.
    - parameter size: Leave nil for a regular sized button. Use `small` for a small sized button.
    - parameter block: The selection block that will be called when the user taps the button.
       
    */
    public convenience init(width: CGFloat, text: String?, color: UIColor?, style: Button.Style?, size: Button.Size?, block: ((_ button: Button) -> Void)?) {
    
        self.init()
        
        self.didInit(width: width, text: text, color: color, style: style, size: size, block: block)
    }
    
    /**
    Creates a circle shaped button with defined diameter, icon image, color and style. The diameter can be whatever value you want.
    -
    - parameter diameter: Will be used as the width of the buttons frame.
    - parameter iconImage: The icon image will be displayed centerred in the circle.
    - parameter color: The color of either the background, for a `filled` style, or the border and text for a `border` or `plain` style. `Destructive` buttons ignore this value.
    - parameter style: Set wether you want a `filled`, `border`, `plain` or `destructive` button style.
    - parameter block: The selection block that will be called when the user taps the button.
       
    */
    public convenience init(diameter: CGFloat, iconImage: UIImage?, color: UIColor?, style: Button.Style?, block: ((_ button: Button) -> Void)?) {
    
        self.init()
        
        self.isCircle = true
        self.iconImage = iconImage
        self.cornerRadius = diameter/2
        self.isCenterred = true
        
        self.didInit(width: diameter, text: nil, color: color, style: style, size: nil, block: block)
    }
    
    private func didInit(width: CGFloat, text: String?, color: UIColor?, style: Button.Style?, size: Button.Size?, block: ((_ button: Button) -> Void)?) {
    
        self.text = text ?? ""
        
        if style == .border { self.isBordered = true }
        if style == .plain { self.isPlain = true }
        if style == .destructive { self.isDestructive = true }
        
        if size == .small { self.isSmallSize = true }
        
        self.color = color ?? Button.defaultColor
        self.backgroundColor = color
        
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
    
        self.backgroundColor = updatedFillColor
        self.frame.size.height = height
        self.layer.borderColor = updatedBorderColor.cgColor
        self.layer.borderWidth = borderWidth > 0 ? borderWidth : Button.defaultBorderWidth
        self.layer.cornerRadius = updatedCornerRadius
        self.layer.masksToBounds = false
    }
    
    private func initLabel() {
    
        self.label.isHidden = isLabelHidden
        self.label.frame = labelFrame
        self.label.autoresizingMask = labelRezising
        self.label.textAlignment = labelAlignment
        self.label.textColor = updatedTextColor
        self.label.font = font
        self.label.text = text
        
        addSubview(label)
    }
    
    private func initDetailLabel() {
    
        guard layout != .circle else {
        
            self.detailLabel.isHidden = true; return
        }
        
        self.detailLabel.isHidden = false
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
    
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = self.style == .filled ? shadowOpacity : 0.0
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: updatedCornerRadius).cgPath
    }
    
    
    // MARK: - Touch Overrides
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesBegan(touches, with: event); self.tapBegan()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesCancelled(touches, with: event); tapEnded()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event); tapEnded()
    }
    
    
    // MARK: - Deinit
    
    
    deinit {
    
        self.selectionDelegate = nil
        self.selectionBlock = nil
    
    }

}



// MARK: - Label Layout


@available(iOS 12.0, *) extension Button {

    private var labelFrame: CGRect {

        if layout == .icon { return CGRect(x: updatedEdgePadding, y: 0, width: bounds.midX, height: bounds.height) }
        if layout == .detailRight { return CGRect(x: updatedEdgePadding, y: 0, width: bounds.midX, height: bounds.height) }
        if layout == .detailCenter { return CGRect(x: updatedEdgePadding, y: 0, width: bounds.width - updatedEdgePadding*2, height: bounds.height * 0.7) }
        
        return self.bounds.insetBy(dx: updatedEdgePadding, dy: 0)
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
    
    var updatedEdgePadding: CGFloat {
    
        return edgePadding >= 0 ? edgePadding : Button.defaultEdgePadding
    }
    
    private var isLabelHidden: Bool {
    
        return layout == .circle || layout == .icon
    }
}


// MARK: - Detail Label Layout


@available(iOS 12.0, *) extension Button {

    private var detailFrame: CGRect {

        if layout == .detailCenter { return CGRect(x: updatedEdgePadding, y: bounds.height * 0.36, width: bounds.width - updatedEdgePadding*2, height: bounds.height * 0.64) }
        
        let padding = size == .small ? updatedEdgePadding/1.50 : updatedEdgePadding
        
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


@available(iOS 12.0, *) extension Button {

    private var imageFrame: CGRect {
    
        let padding = size == .small ? updatedEdgePadding/2 : updatedEdgePadding
        let iconSize = self.iconSize ?? Button.defaultIconSize
        let adjustedIconSize = size == .small ? CGSize(width: iconSize.width * 0.8, height: iconSize.height * 0.8) : iconSize
        
        guard !isCenterred else {
        
            return CGRect(origin: CGPoint(x: bounds.midX - adjustedIconSize.width/2, y: bounds.midY - adjustedIconSize.height/2), size: adjustedIconSize)
        }
        
        return CGRect(x: bounds.width - adjustedIconSize.width - padding, y: (bounds.height - adjustedIconSize.height)/2, width: adjustedIconSize.width, height: adjustedIconSize.height)
    }

    private var imageRezising: AutoresizingMask {
    
        if isCenterred { return [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin] }
        
        return [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }

    private var isImageHidden: Bool {
    
        return iconImage == nil
    }
}


// MARK: - Colors


@available(iOS 12.0, *) extension Button {

    private var updatedTextColor: UIColor {

        guard !isDestructive else {
        
            if style == .border { return Button.destructiveColor }
            if style == .plain { return Button.destructiveColor }
            
            return Button.destructiveTextColor
        }
        
        guard ![Button.Style.border, .plain].contains(style) else {
            
            if let textColor = self.textColor { return textColor }
            if let color = self.color { return color }
            
            return Button.defaultColor
        }
        
        if let textColor = textColor { return textColor }
        if let textColor = Button.defaultTextColor { return textColor }
        if let color = color { return color.contrast(intensity: 1.0) }
        
        return Button.defaultColor.contrast(intensity: 1.0)
    }

    private var updatedBorderColor: UIColor {

        guard style == .border else { return UIColor.clear }
        
        return borderColor ?? updatedTextColor
    }

    private var updatedFillColor: UIColor {

        if style == .border { return UIColor.clear }
        if style == .plain { return UIColor.clear }
        
        if self.isDestructive { return Button.destructiveColor }
        
        return color ?? Button.defaultColor
    }

    var backdropColor: UIColor? {

        if let backdropColor = superview?.backgroundColor, backdropColor != UIColor.clear { return backdropColor }
        
        return nil
    }
}


// MARK: - Size


@available(iOS 12.0, *) extension Button {

    private var size: Button.Size {

        if isSmallSize { return .small }
        
        return .regular
    }
    
    private var height: CGFloat {
    
        if layout == .circle { return frame.width }
        if size == .small { return Button.smallHeight }
        
        return Button.regularHeight
    }
}


// MARK: - Style


@available(iOS 12.0, *) extension Button {

    private var style: Button.Style {
    
        if self.isBordered { return .border }
        if self.isPlain { return .plain }
        
        return .filled
    }
}


// MARK: - Layout


@available(iOS 12.0, *) extension Button {

    private var layout: Button.Layout {

        if isCircle { return .circle }
        if let _ = iconImage { return .icon }
        if !isDetailHidden, isCenterred { return .detailCenter }
        if !isDetailHidden { return .detailRight }
        
        return .regular
    }
}


// MARK: - Font


@available(iOS 12.0, *) extension Button {

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


@available(iOS 12.0, *) extension Button {

    private var updatedCornerRadius: CGFloat {

        if cornerRadius >= 0 { return cornerRadius }
        
        return size == .small ? Button.smallCornerRadius : Button.regularCornerRadius
    }
}


// MARK: - Selections


@available(iOS 12.0, *) extension Button {

    @objc private func didTap() {

        guard !self.spinner.isAnimating else { stopSpinner(); return }
        
        selectionDelegate?.didTapButton(self)
        selectionBlock?(self)
        
        guard let target = target, let selector = selector else { return }
        
        let _ = target.perform(selector)

    }
    
    public func addTarget(_ target: AnyObject, selector: Selector) {
    
        self.target = target
        self.selector = selector
    
    }

    public func simulateTap() {

        guard !self.spinner.isAnimating else { stopSpinner(); return }
        
        self.tapBegan()
        
        selectionBlock?(self)
        startSpinner()
        
        Dispatch.main(after: 0.100) {
            self.tapEnded()
        }

    }
}


// MARK: - Spinner


@available(iOS 12.0, *) extension Button {

    /** Call to enter spinner state. */
    public func startSpinner() {

        self.label.isHidden = true
        self.detailLabel.isHidden = true
        self.imageView.isHidden = true
        self.spinner.color = self.updatedTextColor
        self.spinner.startAnimating()

    }

    /** Call to exit spinner state. */
    public func stopSpinner() {

        self.label.isHidden = isLabelHidden
        self.detailLabel.isHidden = isDetailHidden
        self.imageView.isHidden = isImageHidden
        self.spinner.stopAnimating()

    }
}


// MARK: - Touch Feedback


@available(iOS 12.0, *) extension Button {

    private func tapBegan() {

        if style == .plain { colorFeedback(); return }
        
        self.scaleFeedback()
    }

    private func tapEnded() {

        if style == .plain { resetColor(); return }
        
        self.resetScale()
        
    }

    private func scaleFeedback() {

        guard !isDisplayingFeedback else { return }
        
        self.defaultTransform = self.transform
        self.isDisplayingFeedback = true
        
        UIView.animate(withDuration: 0.050, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
        
            self.transform = self.transform.scaledBy(x: 0.99, y: 0.97)
        
        }, completion: nil)
    }

    private func resetScale() {

        self.isDisplayingFeedback = false
        
        UIView.animate(withDuration: 1.000, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
        
            self.transform = self.defaultTransform ?? CGAffineTransform.identity
        
        }, completion: nil)
    }

    private func colorFeedback() {

        guard !isDisplayingFeedback else { return }
        guard self.feedbackColorView == nil else { return }
        
        self.isDisplayingFeedback = true
        
        self.feedbackColorView = UIView(frame: bounds)
        self.feedbackColorView!.layer.cornerRadius = updatedCornerRadius
        self.feedbackColorView!.layer.borderColor = updatedTextColor.cgColor
        self.feedbackColorView!.layer.borderWidth = 2
        self.feedbackColorView!.alpha = 0.15
        
        addSubview(feedbackColorView!)
    }

    private func resetColor() {

        self.isDisplayingFeedback = false
        
        guard let view = feedbackColorView else { return }
        
        feedbackColorView = nil
        
        UIView.animate(withDuration: 1.000, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
        
            view.alpha = 0
        
        }, completion: nil)
    }
}
