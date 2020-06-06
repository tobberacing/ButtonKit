# Button kit for Sketch + Swift.

Button Kit by 44 is a flexible and easy-to-use toolbox for both designers and iOS developers. As a designer you get a Sketch document with ready-to-use and code-backed symbols for modern button designs. As a developer you get a Swift Package that lets you implement designs without having to write tedious boiler-plate or reinvent wheels.

The symbols in the Sketch document is designed to be copied into your project and manually edited from there. The Swift code is designed to be used as-is, without changes. It is possible to break off and extend it as your own code, but if so, no future updates will be supported.



# Quick-start guide

## As a Designer 👇

1. Download the Sketch file

2. Start adding the symbols to your Sketch documents

## As a Developer 👇

1. Add the Swift Package dependency through Xcode from https://github.com/tobberacing/ButtonsKit.git

2. Use the Button class either through IB or programmatically




**********************************************************************************************************************************

# Full documentation

## Full documentation along with code examples and illustrations can be found at 👇 

👉  https://www.tobiasrenstrom.com/portfolio/button-kit 


**********************************************************************************************************************************



# How to use

The kit comes in a Swift Package with a single class that supports all variations available from the Sketch designs. Should you and your designer want to extend the code, it is possible to simply copy/paste the whole `Button` class and make it your own. If so, just note that no future updates will be supported. You can also write your own extensions or your own subclasses, just note that those might break - even though updates try to mitigate that. The spirit of this kit is to use the code as-is.

Instantiate a button to your project either by placing a view in Interface Builder and changing its class to `Button`. Or programmatically through either 👇

````
let defaultButton = Button(width: 200, color: nil, style: nil, size: nil)
````

Or the recommendeded, quicker convenience init that also takes a text and selectionBlock👇

````
let defaultButton = Button(width: 200, text: "Done", color: nil, style: nil, size: nil) {

    // code
}
````

Wherever you use the `Button` class programmatically, you need to import the `ButtonKit` module.

````
import ButtonKit
````
Edit the appearance of buttons either directly in Interface Builder or programmatically. The things you can tweak include 👇

* Text (duh)
* Detail text
* Color
* Icon
* Text color
* Border color
* Border width
* Corner radius
* Edge padding (for certain layouts)
* Size - regular or small
* Style - Filled, bordered, plain or destructive
* Layout - Regular, detail in center, detail to the right, icon
* These parameters make the Button class highly customizable.



# Styles

- `primary` 👉 Requries no action in IB, instantiate with `nil` for the style parameter programmatically.

- `secondary` 👉 Set the `isBordered`* property to true in IB or instantiate with the `border` style programmatically.

- `plain` 👉 Set the `isPlain`* property to true in IB or instantiate with the `plain` style programmatically.

- `Destructive` 👉 Set the `isDestructive`* property to true in either IB or programmatically. Destructive is not a style like the others, because a destructive button can be either `primary`, `secondary` or `plain` styled.


*Since @IBInspectable doesn’t support enums, or any type of arrays, the style settings in Interface Builder needs to be boolean values, unfortunately.



# Layouts

REGULAR
The default layout.

DETAIL RIGHT
Set the `detailText` property in either IB or programmatically.

DETAIL CENTER
Set the `detailText` property and the `isCenterred` property to true in either IB or programmatically.

ICON
Specify an icon image with a `UIImage` object. This overrides any `detailText`. Set it in either IB or programmatically.

CIRCLE
Use the convenience init that takes a `diameter`.

SPINNER
Call `startSpinner()` to enter spinner mode. `stopSpinner()` exits.



# Sizes

There are two sizes, `regular` and `small`. To create a small sized button, either use the `Size` value when instantiating programmatically, or use the `isSmallSize` property through Interface Builder.

The default heights are `50` and `40` points. In case your designer wants to change those values, you can make the changes during app loading, for example in your App Delegate, using the `regularHeight` and `smallHeight` settings. All buttons in the project will adjust their frame height.

In order to help keep a coherent and consistent UI across your app, this can not be set per-button. The exception is circle buttons that can have any `diameter` you define.

````
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    Button.regularHeight = 44
    Button.smallHeight = 30
    
    return true
}
````


# Shadows

Shadows can be added to buttons (that has a solid background color) with custom values for `color`, `opacity`, `offset` and `radius`. Work with your designer to find the right values. Some tweaking will be needed as Sketch and iOS renders shadows a little differently. Read more about these differences here. https://medium.com/@nathangitter/why-your-app-looks-better-in-sketch-3a01b22c43d7

````
defaultButton.shadowColor = UIColor.darkGray
defaultButton.shadowOpacity = 0.2
defaultButton.shadowOffset = CGSize(width: 0, height: 6)
defaultButton.shadowRadius = 9
````


# Updating values

The recommended way to update the text, detail text and icon image is to change the values on the `Button` object directly. Avoid accessing the underlying `UILabel` or `UIImageView` objects. Whenever one of the properties stored on the `Button` (`text`, `textColor`, `detailText`...) is changed, a style update is triggered to reflect that update. But since this style update uses values stored on the button itself, any values set directly on the underlying `UILabel` or `UIImageView` will be reverted back again and lost.

Here’s some of the properties you can change directly on the `Button` object. Have a look in the code to see wether more has been added since this part of the documentation was written.

````
public var color: UIColor?
public var text: String
public var detailText: String?
public var iconImage: UIImage?
public var textColor: UIColor?
public var borderColor: UIColor?
public var borderWidth: CGFloat
public var shadowOpacity: Float
public var shadowColor: UIColor
public var shadowOffset: CGSize
public var shadowRadius: CGFloat
public var cornerRadius: CGFloat
public var edgePadding: CGFloat
public var isFeedbackEnabled: Bool
````


# Adding an action

Actions can be implemented either by using the `selectionBlock` or by setting a delegate. Blocks are the recommended easiest way.

````
defaultButton.selectionBlock = {

    // code
}
````

To instead add a delegate for call-backs, set the `selectionDelegate` property on the button and implement the `ButtonSelectionDelegate` protocol. The `selectionDelegate` can also be set through Interface Builder.

````
defaultButton.selectionDelegate = self
````

````
extension ViewController: ButtonSelectionDelegate {

    func didTapButton(_ button: Button) {
        
        // code
    }
}
````


# Gobal Settings

To help keep coherent and consistent UI across your app, a lot of settings can be defined as global defaults through static properties. These affects all buttons, unless another value is set for a specific button. Settings include fonts, destructive color, heights and corner radius. Tweak the values as you guys see fit.

````
static public var defaultColor = UIColor(hex: "293440") // overridable in instances by setting specific color
static public var defaultTextColor: UIColor? // overridable in instances by setting specific textColor

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
````

Set these values somewhere during your app loading, before displaying any views. For example in your App Delegate or similar.

````
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    Button.defaultColor = UIColor.black
    Button.defaultTextColor = UIColor.white
    Button.smallCornerRadius = 1
    Button.regularCornerRadius = 5
    Button.destructiveColor = UIColor.red
    Button.destructiveTextColor = UIColor.white

    return true
}
````
