//
//  ProductTableViewCell.swift
//  BrunoJaffer
//
//  Created by Bruno Istvan Campos Monteiro on 27/08/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var lbNameProduct: UILabel!
    @IBOutlet weak var lbPriceProduct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
