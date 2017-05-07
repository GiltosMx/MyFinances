//
//  ViewControllerFormulario.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 29/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB
import Charts

class ViewControllerFormulario: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, ChartViewDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var DescripcionTextField: UITextField!
    @IBOutlet weak var montoTextField: UITextField!
    @IBOutlet weak var categoriasPicker: UIPickerView!
    @IBOutlet weak var presupuestoLabel: UILabel!
    @IBOutlet weak var saldoRestanteLabel: UILabel!
    @IBOutlet weak var graficaPastel: PieChartView!
    
    var BD: FMDatabase!
    var categoriasArray: Array<String> = []
    var dataChart: Array<Float> = []
    var monto: Float!
    var montoString: String!
    var categoria: String!
    var charEntry: [PieChartDataEntry] = []
    var pieChartdataSet: PieChartDataSet!
    var pieChartData: PieChartData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoriasPicker.dataSource = self
        self.categoriasPicker.delegate = self
        DescripcionTextField.delegate = self
        montoTextField.delegate = self
        graficaPastel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createOrOpenDB()
        getCategorias()
        getPresupuesto()
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
//            createTables()
//            getCategorias()
        }
        categoriasPicker.reloadAllComponents()
    }
    
    func getPresupuesto(){
        charEntry.removeAll()
        dataChart.removeAll()
        
        let queryPresupuesto = try! BD.executeQuery("SELECT Presupuesto, Gasto FROM Usuario", values: [])
        while queryPresupuesto.next(){
            let presupuesto = Float(queryPresupuesto.string(forColumn: "Presupuesto"))
            let gasto = Float(queryPresupuesto.string(forColumn: "Gasto"))
            
            presupuestoLabel.text = "$ " + String(presupuesto!)
            dataChart.append(presupuesto! - gasto!)
            saldoRestanteLabel.text = "$ " + String(presupuesto! - gasto!)
            dataChart.append(gasto!)
            
//            presupuestoLabel.text = "$ " + queryPresupuesto.string(forColumn: "Presupuesto")
//            dataChart.append(Float(queryPresupuesto.string(forColumn: "Presupuesto"))!)
//            saldoRestanteLabel.text = "$ " + queryPresupuesto.string(forColumn: "Gasto")
//            dataChart.append(Float(queryPresupuesto.string(forColumn: "Presupuesto"))! - Float(queryPresupuesto.string(forColumn: "Gasto"))!)
        }

        charEntry.append(PieChartDataEntry(value: Double(dataChart[0]), label: "Disponible"))
        charEntry.append(PieChartDataEntry(value: Double(dataChart[1]), label: "Gastado"))
        
        
        pieChartdataSet = PieChartDataSet(values: charEntry, label: nil)
        var color: [NSUIColor] = []
        color.append(UIColor(colorLiteralRed: 0.80, green: 0.898, blue: 0.898, alpha: 1.0))
        color.append(UIColor(colorLiteralRed: 0.498, green: 0.749, blue: 0.749, alpha: 1.0))
        pieChartdataSet.setColors(color, alpha: 1)
        
        
        
        pieChartData = PieChartData(dataSet: pieChartdataSet)
        
        graficaPastel.sizeToFit()
        graficaPastel.data = pieChartData
        graficaPastel.holeColor = UIColor.clear
    }
    
    @IBAction func insertarGastoEnBD(_ sender: Any) {
       
        let alert = UIAlertController(title: "Insertar Gasto", message: "¿Estás seguro?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            self.montoString = self.montoTextField.text
            self.monto = Float(self.montoString)
            
            
            
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
                let fecha = String(calendar.component(.year, from: date)) + "-" + String(calendar.component(.month, from: date)) + "-" + String(calendar.component(.day, from: date)) + " " + String(calendar.component(.hour, from: date)) + ":" + String(calendar.component(.minute, from: date)) + ":" + String(calendar.component(.second, from: date))
                
//                print("Fecha \(fecha)")
                
                if(self.categoria != nil){
                    
                    try! self.BD!.executeUpdate("insert into Gastos values(?,?,?,?)", values: [self.categoria,fecha,self.DescripcionTextField.text!,self.monto])
//                    print("descripcion \(String(describing: self.DescripcionTextField.text))")
//                    print("Monto \(String(describing: self.montoTextField.text))")
//                    print("Categoria \(self.categoria)")
                } else {
                    //En caso de que el usuario no mueva el picker se
                    //toma la primera categoria del arreglo
                    
                    try! self.BD!.executeUpdate("insert into Gastos values(?,?,?,?)", values: [self.categoriasArray[0],fecha,self.DescripcionTextField.text!,self.monto])
//                    print("descripcion \(String(describing: self.DescripcionTextField.text))")
//                    print("Monto \(String(describing: self.montoTextField.text))")
//                    print("Categoria \(self.categoria)")
                }
                
                try! self.BD!.executeUpdate("update Usuario set Gasto = Gasto + ?", values: [self.monto])
                
                self.getPresupuesto()
                
                let confirm = UIAlertController(title: "Listo", message: "Gasto Registrada", preferredStyle: .alert)
                let listoButton = UIAlertAction(title: "Ok", style: .default){
                    (action: UIAlertAction) in
                    
                    
                }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        
        return true
    }
    
    func createTables(){
        let result = BD!.executeStatements("CREATE TABLE Catalogo_categoria(Categoria text primary key, Icono text, Color text)")
        if !result
        {
            print("No se creo la tabla1")
        }
        
        let result2 = BD!.executeStatements("CREATE TABLE Usuario(Nombre text, Apellido text, Correo text, Presupuesto integer, Gasto integer, Rango text, Warning integer, shouldUpdateBudget integer)")
        
//        try! BD.executeUpdate("UPDATE Usuario SET shouldUpdateBudget = ?", values: [1])
        
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
        
        try! BD!.executeUpdate("insert into Usuario values(?,?,?,?,?,?,?)", values: ["Fulanito","De tal","correoFalso@hotmail.com", 14400.00, 14400.00,"Mensual", 75, 1])
        
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
        }
    }
    
    func queryTest(){
        
        let  query = try! BD.executeQuery("SELECT * FROM Gastos", values: [])
        
        while query.next() {
            print(query.string(forColumn: "Categoria"))
            print(query.string(forColumn: "Fecha"))
            print(query.string(forColumn: "Descripcion"))
            print(query.string(forColumn: "Monto"))
        }
    }

}
