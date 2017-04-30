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
    @IBOutlet weak var presupuestoLabel: UILabel!
    @IBOutlet weak var saldoRestanteLabel: UILabel!
    
    var BD: FMDatabase!
    var categoriasArray: Array<String> = []
    var monto: Float!
    var montoString: String!
    var categoria: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoriasPicker.dataSource = self
        self.categoriasPicker.delegate = self
        createOrOpenDB()
        getCategorias()
        getPresupuesto()
        //createTables()
        //insertCategorias()
    }
    
    func insertDefaultValues(){
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Transporte"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Entretenimiento"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Educacion"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Hogar"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Otros"])
        
        
    }
    
    func createTables(){
        /*let result = BD!.executeStatements("CREATE TABLE Catalogo_categoria(Categoria text primary key, Icono text, Color text)")
        if !result
        {
            print("No se creo la tabla1")
        }*/
        
        let result2 = BD!.executeStatements("CREATE TABLE Usuario(Nombre text, Apellido text, Correo text, Presupuesto integer, Gasto integer, Rango text, Warning integer)")
        if !result2
        {
            print("No se creo la tabla2")
        }
        let result3 = BD!.executeStatements("CREATE TABLE Gastos(Categoria text, Fecha text, Descripcion text, Monto integer)")
        if !result3
        {
            print("No se creo la tabla3")
        }
        let result4 = BD!.executeStatements("CREATE TABLE Presupuesto_detalle(Presupuesto integer, Categoria text)")
        if !result4
        {
            print("No se creo la tabla4")
        }
        
        try! BD!.executeUpdate("insert into Usuario values(?,?,?,?,?,?,?)", values: ["Fulanito","De tal","correoFalso@hotmail.com", 14400.00, 14400.00,"Mensual", 75])

        
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
    
    func getPresupuesto(){
        let queryPresupuesto = try! BD.executeQuery("SELECT Presupuesto, Gasto FROM Usuario", values: [])
        while queryPresupuesto.next()
        {
           presupuestoLabel.text = "$ " + queryPresupuesto.string(forColumn: "Presupuesto")
           saldoRestanteLabel.text = "$ " + queryPresupuesto.string(forColumn: "Gasto")
        }
    }
    
    @IBAction func insertarGastoEnBD(_ sender: Any) {
       
        let alert = UIAlertController(title: "Insertar Venta", message: "¿Estas seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            self.montoString = self.montoTextField.text
            self.monto = Float(self.montoString)
            
            print("descripcion \(self.DescripcionTextField.text)")
            print("Monto \(self.montoTextField.text)")
            print("Categoria \(self.categoria)")
            
            if(self.monto == nil || self.monto < 0 || self.DescripcionTextField.text == "" ){
                print("No es valido")
                let confirm = UIAlertController(title: "Error", message: "Algún campo del formulario no es válido", preferredStyle: .alert)
                let listoButton = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
                confirm.addAction(listoButton)
                self.present(confirm, animated: true, completion: nil)
            }else{
                print("si es valido")
                let date = Date()
                let calendar = Calendar.current
                let fecha = String(calendar.component(.year, from: date)) + "-" + String(calendar.component(.month, from: date)) + "-" + String(calendar.component(.day, from: date)) + " " + String(calendar.component(.minute, from: date)) + "-" + String(calendar.component(.hour, from: date)) + "-" + String(calendar.component(.second, from: date))
                
                print("Fecha \(fecha)")
                
                try! self.BD!.executeUpdate("insert into Gastos values(?,?,?,?)", values: [self.categoria,fecha,self.DescripcionTextField.text!,self.monto])
                
                try! self.BD!.executeUpdate("update Usuario set Gasto = Gasto - ?", values: [self.monto])
                
                self.getPresupuesto()
                
                let confirm = UIAlertController(title: "Listo", message: "Venta Registrada", preferredStyle: .alert)
                let listoButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
                confirm.addAction(listoButton)
                self.present(confirm, animated: true, completion: nil)
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
    
    
    //Metodos raros del uipickerview
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
