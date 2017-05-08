//
//  AddCategoriaViewController.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 30/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB

class ModificarCategoriasViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{

    //MARK: - Outlets
    @IBOutlet weak var categoriaTextFiel: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoriaPicker: UIPickerView!
    
    //MARK: - Atributos
    var BD: FMDatabase!
    var categoria: String!
    var categoriasArray: Array<String> = []
    
    //MARK: - Metodos del ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        categoriaTextFiel.delegate = self
        categoriaPicker.delegate = self
        categoriaPicker.dataSource = self
        // Do any additional setup after loading the view.
        createOrOpenDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createOrOpenDB()
        getCategorias()
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
    
    
    func getCategorias(){
        categoriasArray.removeAll()
        do{
            let query = try BD.executeQuery("SELECT Categoria FROM Catalogo_categoria", values: [])
            while query.next()
            {
                categoriasArray.append(query.string(forColumn: "Categoria"))
                
            }
        }catch{

        }
        categoriaPicker.reloadAllComponents()
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
    @IBAction func eliminarCategoria(_ sender: Any) {
        let alert = UIAlertController(title: "Eliminar Categoría", message: "¿Estás seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            do{
                print("Si se borro")
                try self.BD.executeUpdate("Delete from Catalogo_categoria Where Categoria = ?", values: [self.categoria])
            }catch{
                print("No se pudo borrar")
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
    
    
    //MARK: - Metodos del PickerView
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoriasArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoriasArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoria = categoriasArray[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
}
