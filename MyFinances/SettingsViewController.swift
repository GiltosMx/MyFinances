//
//  SettingsViewController.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 30/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB

class SettingsViewController: UIViewController,UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var nombreTxt: UITextField!
    @IBOutlet weak var apellidoLabel: UILabel!
    @IBOutlet weak var apellidoTxt: UITextField!
    @IBOutlet weak var correoTxt: UITextField!
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var presupuestoTxt: UITextField!
    @IBOutlet weak var presupuestoLabel: UILabel!
    @IBOutlet weak var rangoLabel: UILabel!
    @IBOutlet weak var rangoPicker: UIPickerView!
    
    var BD: FMDatabase!
    var rangoArray: Array<String> = []
    var rangoString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nombreTxt.delegate = self
        apellidoTxt.delegate = self
        correoTxt.delegate = self
        presupuestoTxt.delegate = self
        rangoPicker.dataSource = self
        rangoPicker.delegate = self
        cargarBaseDatos()
        cargarValores()
        rangoArray.append("Mensual")
        rangoArray.append("Semanal")
    }
    
    func cargarBaseDatos(){
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
    
    func cargarValores(){
        nombreLabel.text = "Nombre: "
        apellidoLabel.text = "Apellido: "
        correoLabel.text = "Correo: "
        presupuestoLabel.text = "Presupuesto: $"
        rangoLabel.text = "Rango del presupuesto: "
        
        do{
            let query = try BD.executeQuery("SELECT Nombre FROM Usuario", values: [])
            while query.next()
            {
                nombreLabel.text = nombreLabel.text! + query.string(forColumn: "Nombre")
                
            }
        }catch{
            print("No se encontro usuario")
        }
        
        do{
            let query = try BD.executeQuery("SELECT Apellido FROM Usuario", values: [])
            while query.next()
            {
                apellidoLabel.text = apellidoLabel.text! + query.string(forColumn: "Apellido")
                
            }
        }catch{
            print("No se encontro Apelldio")
        }
        do{
            let query = try BD.executeQuery("SELECT Correo FROM Usuario", values: [])
            while query.next()
            {
                correoLabel.text = correoLabel.text! + query.string(forColumn: "Correo")
                
            }
        }catch{
            print("No se encontro correo")
        }
        do{
            let query = try BD.executeQuery("SELECT Presupuesto FROM Usuario", values: [])
            while query.next()
            {
                presupuestoLabel.text = presupuestoLabel.text! + query.string(forColumn: "Presupuesto")
                
            }
        }catch{
            print("No se encontro presupuesto")
        }
        do{
            let query = try BD.executeQuery("SELECT Rango FROM Usuario", values: [])
            while query.next()
            {
                rangoLabel.text = rangoLabel.text! + query.string(forColumn: "Rango")
                
            }
        }catch{
            print("No se encontro presupuesto")
        }
        
    }

    @IBAction func cambiarNombre(_ sender: Any) {
        let alert = UIAlertController(title: "Cambiar Usuario", message: "¿Estas seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            
            do{
            try self.BD!.executeUpdate("Update Usuario set Nombre = ?", values: [self.nombreTxt.text])
            } catch{
             print("no se inserto el nombre")
            }
            
            self.cargarValores()
        }
        
        let cancelButton = UIAlertAction(title: "Cancelar",
                                         style: .destructive)
        { (UIAlertAction) in
            
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cambiarApellio(_ sender: Any) {
        let alert = UIAlertController(title: "Cambiar Apellido", message: "¿Estas seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            
            do{
                try self.BD!.executeUpdate("Update Usuario set Apellido = ?", values: [self.apellidoTxt.text])
            } catch{
                print("no se inserto el apellido")
            }
            
            self.cargarValores()
        }
        
        let cancelButton = UIAlertAction(title: "Cancelar",
                                         style: .destructive)
        { (UIAlertAction) in
            
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cambiarCorreo(_ sender: Any) {
        let alert = UIAlertController(title: "Cambiar Correo", message: "¿Estas seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            
            do{
                try self.BD!.executeUpdate("Update Usuario set Correo = ?", values: [self.correoTxt.text])
            } catch{
                print("no se inserto el nombre")
            }
            
            self.cargarValores()
        }
        
        let cancelButton = UIAlertAction(title: "Cancelar",
                                         style: .destructive)
        { (UIAlertAction) in
            
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cambiarPresupuesto(_ sender: Any) {
        let alert = UIAlertController(title: "Cambiar Presupuesto", message: "¿Estas seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            
            do{
                try self.BD!.executeUpdate("Update Usuario set Presupuesto = ?", values: [Float(self.presupuestoTxt.text!)])
            } catch{
                print("no se inserto el nombre")
            }
            
            self.cargarValores()
        }
        
        let cancelButton = UIAlertAction(title: "Cancelar",
                                         style: .destructive)
        { (UIAlertAction) in
            
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func cambiarRango(_ sender: Any) {
        let alert = UIAlertController(title: "Cambiar Rango", message: "¿Estas seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            
            do{
                try self.BD!.executeUpdate("Update Usuario set Rango = ?", values: [self.rangoString])
            } catch{
                print("no se inserto el Rango")
            }
            
            self.cargarValores()
        }
        
        let cancelButton = UIAlertAction(title: "Cancelar",
                                         style: .destructive)
        { (UIAlertAction) in
            
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        
        
        if(textField.isEqual(presupuestoTxt)){
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 100),
                                             animated: true)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        textField.resignFirstResponder()
        
        return true
    }
    
    //Metodos raros del uipickerview
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rangoArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rangoArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rangoString = rangoArray[row]
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    

}
