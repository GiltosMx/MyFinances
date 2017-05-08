//
//  TableViewCell.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 05/05/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var lblDescripcion: UILabel!
    
    
    //MARK: - Metodos de TableCell
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
