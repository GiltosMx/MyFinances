//
//  ViewControllerGastos.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 06/05/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB

class ViewControllerGastos: UIViewController, UITableViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTotalGastos: UILabel!
    
    //MARK: - Atributos
    var BD: FMDatabase!
    var arrayCategorias: Array<String> = []
    var cantidadGastosPorCategoria: Array<Int32> = []
    var listadoGastosPorCategoria: Array<Array<String>> = []
    
    
    //MARK: - Metodos del ViewController
    override func viewWillAppear(_ animated: Bool) {
        BD.open()
        getCantidadGastosPorCategoria()
        setTotalGastado()
        listadoGastosPorCategoria = getListadoGastosPorCategoria()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        BD.close()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        createOrOpenDB()
        
        let categoriasQuery = try! self.BD.executeQuery("SELECT Categoria FROM Catalogo_categoria", values: [])
        
        while categoriasQuery.next() {
            arrayCategorias.append(categoriasQuery.string(forColumn: "Categoria"))
        }
        
        getCantidadGastosPorCategoria()
        
        listadoGastosPorCategoria = getListadoGastosPorCategoria()
    }
    
    //MARK: - Metodos de la Clase
    
    func setTotalGastado(){
        let query = try! BD.executeQuery("SELECT Gasto FROM Usuario", values: [])
        
        if(query.next()){
            lblTotalGastos.text = "$" + String(query.int(forColumn: "Gasto"))
        }
    }
    
    func getListadoGastosPorCategoria() -> Array<Array<String>> {
        
        var listadoGastos: Array<Array<String>> = Array(repeating: Array.init(repeating: "", count: 3), count: arrayCategorias.count)
        
        
        for index in 0...arrayCategorias.count-1 {
            
            let query = try! BD.executeQuery("SELECT * FROM Gastos WHERE Categoria = ?", values: [arrayCategorias[index]])
            
            var string = ""
            
            var i = 0
            
            while(query.next()){
                string = ""
                
                string = string + query.string(forColumn: "Fecha") + ","
                string = string + query.string(forColumn: "Descripcion") + ","
                string = string + query.string(forColumn: "Monto") + ","
                
                listadoGastos[index][i] = string
                
                i = i+1
            }
            
        }
        
        return listadoGastos
    }
    
    func getCantidadGastosPorCategoria(){
        
        cantidadGastosPorCategoria.removeAll()
        
        for index in 0...arrayCategorias.count-1 {
            
            let gastosPorCategoriaQuery = try! self.BD.executeQuery("SELECT COUNT(Categoria) AS CountGastos FROM Gastos WHERE Categoria = ?", values: [arrayCategorias[index]])
            
            while gastosPorCategoriaQuery.next() {
                
                cantidadGastosPorCategoria.append(gastosPorCategoriaQuery.int(forColumn: "CountGastos"))
            }
        }
    }
    
    func createOrOpenDB(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let dbPath = paths[0] + "/myDB.db"
        
        BD = FMDatabase(path: dbPath)
        
        if !BD.open(){
            print("Error al abrir la BD")
        }
        else{
        }
    }

    //MARK: - Metodos del TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "financeCell", for: indexPath) as! TableViewCell
        
        var montoGasto: Float = 0
        
        let cellDataString = listadoGastosPorCategoria[indexPath.section][indexPath.row]
        
        let cellDataArray = cellDataString.characters.split(separator: ",")
        
        montoGasto = Float(String(cellDataArray[2]))!
        
        cell.lblFecha.text = String(cellDataArray[0])
        cell.lblDescripcion.text = String(cellDataArray[1])
        cell.lblMonto.text = String(cellDataArray[2])
        
        
//        let listadoActual = listadoGastosPorCategoria[indexPath.section]
//        
//        if (listadoActual.next()){
//            
//            cell.lblDescripcion.text = listadoActual.string(forColumn: "Descripcion")
//            cell.lblMonto.text = "$" + listadoActual.string(forColumn: "Monto")
//            montoGasto = Float(listadoActual.int(forColumn: "Monto"))
//            cell.lblFecha.text = listadoActual.string(forColumn: "Fecha")
//        }
        
        let gastoQuery = try! BD.executeQuery("SELECT Presupuesto FROM Usuario", values: [])
        
        if(gastoQuery.next()){
            
            let presupuesto = Float(gastoQuery.int(forColumn: "Presupuesto"))
            
            montoGasto = (montoGasto * 100) / presupuesto
            cell.setProgress(progress: montoGasto / 100.0)
        }
        
        cell.lblPorcentaje.text = String("\(montoGasto) %")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRows = Int(cantidadGastosPorCategoria[section])
        
        return numberOfRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return arrayCategorias.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return arrayCategorias[section]
    }
}
