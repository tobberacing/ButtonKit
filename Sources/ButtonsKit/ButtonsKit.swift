import UIKit

public struct ButtonsKit {
    var text = "Hello, World!"
    var text2 = "Yooooo worlds"
    var text3 = "Yooooo worldsdfs"
    var text4 = "Yooooo worldsdfs"
}


public struct CanYouSeeThisStruct {
    var text = "Can You?"
    var text2 = "Can You??"
}

public struct ButtonsKitTest {
    var text = "Yo"
}


public class Button: UIView {

    
    
    convenience init(frame: CGRect, text: String) {
    
        self.init()
        self.frame = frame
        
        print("frame: \(frame) text: \(text)")
    
    }

}
