//  Created by Code4Romania

import UIKit
import SafariServices

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = MVColors.black.color
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let guideButton = UIBarButtonItem(image: UIImage(named:"guideIcon"), style: .plain, target: self, action: #selector(RootViewController.pushGuideViewController))
        let callButton = UIBarButtonItem(image: UIImage(named:"callIcon"), style: .plain, target: self, action: #selector(RootViewController.performCall))
        self.navigationItem.rightBarButtonItems = [callButton, guideButton]
    }
    
    func pushGuideViewController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GuideViewController") as! GuideViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func performCall() {
        let phoneCallPath = "telprompt://048606234807"
        if let phoneCallURL = NSURL(string: phoneCallPath) {
            UIApplication.shared.openURL(phoneCallURL as URL)
        }
    }

}
