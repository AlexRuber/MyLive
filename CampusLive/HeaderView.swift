//
//  HeaderView.swift
//  CampusLive
//
//  Created by Mihai Ruber on 4/3/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 3.0
        
    }

}
