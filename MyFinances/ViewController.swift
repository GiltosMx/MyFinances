//
//  ViewController.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 09/03/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let dbPath = paths[0] + "/myDB.db"
        
        let BD = FMDatabase(path: dbPath)
        
        if !BD!.open()
        {
            print("Error al abrir la BD")
            return
        }
        else{
            print("si se abrio")
            return
        }
        
    }

   

}

