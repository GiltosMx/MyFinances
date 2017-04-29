//
//  ViewControllerFormulario.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 29/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB

class ViewControllerFormulario: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var DescripcionTextField: UITextField!
    @IBOutlet weak var montoTextField: UITextField!
    @IBOutlet weak var categoriasPicker: UIPickerView!
    
    var BD: FMDatabase!
    var categoriasArray: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoriasPicker.dataSource = self
        self.categoriasPicker.delegate = self
        createOrOpenDB()
        getCategorias()
        //insertCategorias()
        /*let result = BD!.executeStatements("CREATE TABLE Catalogo_categoria(Categoria text primary key, Icono text, Color text)")
    
                    if !result
                    {
                        print("No se creo la tabla")
                    }
        
                    try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Alimentos"])*/
    }
    func insertCategorias(){
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Transporte"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Entretenimiento"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Educacion"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Hogar"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Otros"])
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
    
    func getCategorias(){
        let query = try! BD.executeQuery("SELECT Categoria FROM Catalogo_categoria", values: [])
        
        while query.next()
        {
            categoriasArray.append(query.string(forColumn: "Categoria"))
        }
        
        
    }
    @IBAction func insertarGastoEnBD(_ sender: Any) {
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoriasArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoriasArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }

}
