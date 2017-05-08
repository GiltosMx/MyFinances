//
//  AddCategoriaViewController.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 30/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB

class AddCategoriaViewController: UIViewController, UITextFieldDelegate{

    //MARK: - Outlets
    @IBOutlet weak var categoriaTextFiel: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Atributos
    var BD: FMDatabase!
    
    //MARK: - Metodos del ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        categoriaTextFiel.delegate = self
        // Do any additional setup after loading the view.
        createOrOpenDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createOrOpenDB()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        BD.close()
    }
    
    //MARK: - Metodos de la Clase
    func createOrOpenDB(){
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let dbPath = paths[0] + "/myDB.db"
        
        BD = FMDatabase(path: dbPath)
        
        if !BD.open(){
            print("Error al abrir la BD")
        }
    }
    
    @IBAction func agregarCategoria(_ sender: Any) {
        
        let alert = UIAlertController(title: "Agregar Categoría", message: "¿Estás seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
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
    
    //MARK: - Metodos del TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        
        return true
    }
}
