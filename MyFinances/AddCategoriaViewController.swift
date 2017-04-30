//
//  AddCategoriaViewController.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 30/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB

class AddCategoriaViewController: UIViewController {
    
    var BD: FMDatabase!

    @IBOutlet weak var categoriaTextFiel: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createOrOpenDB()
    }

    func createOrOpenDB(){
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    
    let dbPath = paths[0] + "/myDB.db"
    
    BD = FMDatabase(path: dbPath)
    
    if !BD.open(){
    print("Error al abrir la BD")
    return
    }
    else{
    print("si se abrio")
    return
    }
    
    }
    
    @IBAction func agregarGuia(_ sender: Any) {
        
        let alert = UIAlertController(title: "Insertar Venta", message: "¿Estas seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            do{
                try self.BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: [self.categoriaTextFiel.text!])
            }catch{
                print("Registro repetido")
            }
        
        }
        let cancelButton = UIAlertAction(title: "Cancelar",
                                         style: .destructive)
        { (UIAlertAction) in
            
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
        
        
    }

    @IBAction func regresar(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
