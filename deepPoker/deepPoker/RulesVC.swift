//
//  RulesVC.swift
//  deepPoker
//
//  Created by Waddah Al Drobi on 2019-04-26.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit

class RulesVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            guard let image = UIImage(contentsOfFile: Bundle.main.path(forResource: "rankings", ofType: "jpg")!) else {
                return
            }
        
            imageView.image = image

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
