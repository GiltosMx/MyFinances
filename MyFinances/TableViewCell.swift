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
    @IBOutlet weak var lblMonto: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var lblPorcentaje: UILabel!
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    //MARK: - Metodos de TableCell
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.shadowColor = UIColor.gray.cgColor
        cellView.layer.shadowOpacity = 0.60
        cellView.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        cellView.layer.shadowRadius = 2.5
        cellView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

    }

    func setProgress(progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    
}
