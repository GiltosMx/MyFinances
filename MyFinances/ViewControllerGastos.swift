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
    
    //MARK: - Atributos
    var BD: FMDatabase!
    var arrayCategorias: Array<String> = []
    var cantidadGastosPorCategoria: Array<Int32> = []
    var listadoGastosPorCategoria: Array<FMResultSet> = []
    
    
    //MARK: - Metodos del ViewController
    override func viewWillAppear(_ animated: Bool) {
        BD.open()
        getCantidadGastosPorCategoria()
        listadoGastosPorCategoria = getListadoGastosPorCategoria()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        BD.close()
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
    
    func getListadoGastosPorCategoria() -> Array<FMResultSet> {
        
        var listadoGastos: Array<FMResultSet> = []
        
        for index in 0...arrayCategorias.count-1 {
            
            listadoGastos.append(try! BD.executeQuery("SELECT * FROM Gastos WHERE Categoria = ?", values: [arrayCategorias[index]]))
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableViewCell
        
        
        let listadoActual = listadoGastosPorCategoria[indexPath.section]
        
        if (listadoActual.next()){
            
            cell.lblDescripcion.text = listadoActual.string(forColumn: "Descripcion")
        }
        
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
