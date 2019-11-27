//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
   
    var titleLabel: UILabel = {
        
        return UILabel(frame: CGRect(x: 150, y: 200, width: 200, height: 20))
    }()
    
    override func loadView() {
        
        let view = UIView()
        view.backgroundColor = .white

        titleLabel.text = "Hello World!"
        print(titleLabel)

        titleLabel.textColor = UIColor.white
        print(titleLabel)

        titleLabel.backgroundColor = UIColor.red
        
        print(titleLabel)
        view.addSubview(titleLabel)
        print(titleLabel)

        
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
