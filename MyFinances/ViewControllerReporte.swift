//
//  ViewControllerReporte.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 30/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit
import FMDB
import Charts

class ViewControllerReporte: UIViewController, ChartViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var lblCantidadGastos: UILabel!
    @IBOutlet weak var lblDescripcionGasto: UILabel!
    @IBOutlet weak var lblFechaGasto: UILabel!
    @IBOutlet weak var lblMontoGasto: UILabel!
    @IBOutlet weak var lblCategoriaGasto: UILabel!
    
    //MARK: - Atributos
    var BD: FMDatabase!
    var totalExpenses : Float = 0
    var remainingBudget : Float = 0
    var budgetPeriod: String = ""
    var arrayGastosTotales: Array<Float> = []
    var arrayCategorias: Array<String> = []
    var arrayCategoriasGastos: Array<String> = []
    
    //MARK: - Metodos del ViewController
    override func viewWillAppear(_ animated: Bool) {

        createOrOpenDB()

        clearDataToDisplay()

        getExpenseDetails()

        setupChartData()

        setInformationLabels()
        
        checkBudgetPeriod()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        BD.close()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Metodos de la Clase
    func checkBudgetPeriod(){
        
        let query = try! BD.executeQuery("SELECT Rango FROM Usuario", values: [])
        
        while query.next(){
            self.budgetPeriod = query.string(forColumn: "Rango")
        }
        
        updateBudget(budgetPeriod: budgetPeriod)
    }
    
    func updateBudget(budgetPeriod: String){
        
        var shouldUpdateBudget: Int32 = 0
        
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        
        //        print("day: \(day)")
        //        print("weekday: \(weekday)")
        
        let query = try! BD.executeQuery("SELECT shouldUpdateBudget FROM Usuario", values: [])
        
        while query.next() {
            shouldUpdateBudget = query.int(forColumn: "shouldUpdateBudget")
        }
        
        if(shouldUpdateBudget == 1){
            
            //            let presupuestoQuery = try! BD.executeQuery("SELECT Presupuesto FROM Usuario", values: [])
            
            if(budgetPeriod == "Mensual"){
                if(day == 1){
                    
                    try! BD.executeUpdate("UPDATE Usuario SET Gasto = ?", values: [0])
                    
                    //                    while presupuestoQuery.next() {
                    //
                    //                        try! BD.executeUpdate("UPDATE Usuario SET Gasto = ?", values: [Float(presupuestoQuery.int(forColumn: "Presupuesto"))])
                    //                    }
                    
                    try! BD.executeUpdate("UPDATE Usuario SET shouldUpdateBudget = ?", values: [0])
                    
                } else {
                    try! BD.executeUpdate("UPDATE Usuario SET shouldUpdateBudget = ?", values: [1])
                }
                
            } else if(budgetPeriod == "Semanal"){
                
                if(weekday == 1){
                    
                    try! BD.executeUpdate("UPDATE Usuario SET Gasto = ?", values: [0])
                    
                    //                    while presupuestoQuery.next() {
                    //
                    //                        try! BD.executeUpdate("UPDATE Usuario SET Gasto = ?", values: [Float(presupuestoQuery.int(forColumn: "Presupuesto"))])
                    //                    }
                    
                    try! BD.executeUpdate("UPDATE Usuario SET shouldUpdateBudget = ?", values: [0])
                    
                } else {
                    
                    try! BD.executeUpdate("UPDATE Usuario SET shouldUpdateBudget = ?", values: [1])
                }
            }
        }
    }
    
    func createOrOpenDB(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let dbPath = paths[0] + "/myDB.db"
        
        //        print("Path de la BD:\n" + dbPath)
        
        BD = FMDatabase(path: dbPath)
        
        if !BD.open(){
            print("Error al abrir la BD")
        }
        else{
        }
    }
    
    func clearDataToDisplay(){
        totalExpenses = 0
        arrayCategorias.removeAll()
        arrayCategoriasGastos.removeAll()
        arrayGastosTotales.removeAll()
    }
    
    func createTables(){
        let result = BD!.executeStatements("CREATE TABLE Catalogo_categoria(Categoria text primary key, Icono text, Color text)")
        if !result
        {
            print("No se creo la tabla1")
        }
        
        let result2 = BD!.executeStatements("CREATE TABLE Usuario(Nombre text, Apellido text, Correo text, Presupuesto integer, Gasto integer, Rango text, Warning integer, shouldUpdateBudget integer)")
        
        try! BD.executeUpdate("UPDATE Usuario SET shouldUpdateBudget = ?", values: [1])
        
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
        
        try! BD!.executeUpdate("insert into Usuario values(?,?,?,?,?,?,?,?)", values: ["Fulanito","De tal","correoFalso@hotmail.com", 14400.00, 0,"Mensual", 75, 1])
        
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Transporte"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Entretenimiento"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Educacion"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Hogar"])
        try! BD!.executeUpdate("insert into Catalogo_categoria(Categoria) values(?)", values: ["Otros"])
        
        
    }
    func setInformationLabels(){
        
        lblCantidadGastos.text = "$" + String(totalExpenses)
        
        let gastoMayorQuery = try! BD.executeQuery("SELECT Fecha, Categoria, Descripcion, Monto FROM Gastos WHERE Monto = (SELECT MAX(Monto) AS MontoMax FROM Gastos)"
            , values: [])
        
        while gastoMayorQuery.next() {
            lblDescripcionGasto.text = gastoMayorQuery.string(forColumn: "Descripcion")
            
            lblFechaGasto.text = gastoMayorQuery.string(forColumn: "Fecha")
            
            lblCategoriaGasto.text = gastoMayorQuery.string(forColumn: "Categoria")
            
            lblMontoGasto.text = "$" + String(gastoMayorQuery.int(forColumn: "Monto"))
        }
        
    }
    
    //MARK: - Metodos para el ChartView
    

    func setupChartData(){

        var chartEntry: [PieChartDataEntry] = []

        //Si el arreglo de gastos totales no tiene datos,
        //insertar 0 en el valor de gastos para la grafica
        
        if(arrayGastosTotales.count < 1){
            
            chartEntry.append(PieChartDataEntry(value: 0, label: "NO HAY DATOS"))
            
        } else{
            
            for index in 0...arrayCategoriasGastos.count-1{
            
            
                chartEntry.append(PieChartDataEntry(value: Double(arrayGastosTotales[index]), label: arrayCategoriasGastos[index]))
            }
        }

        let chartDataSet = PieChartDataSet(values: chartEntry, label: nil)

        let arrayColores = fillChartColorArray()

        chartDataSet.setColors(arrayColores, alpha: 1)

        let chartData = PieChartData(dataSet: chartDataSet)

        pieChart.sizeToFit()
        pieChart.data = chartData
        pieChart.holeColor = UIColor.clear
        pieChart.chartDescription?.text = ""
    }

    func fillChartColorArray() -> [NSUIColor]{

        var arrayColores: [NSUIColor] = []

        var redValue:CGFloat = 0.25
        var greenValue:CGFloat = 0.52
        var blueValue:CGFloat = 0.28
        
        for _ in 0...arrayCategorias.count{

            arrayColores.append(UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0))

            redValue = redValue + 0.2
            greenValue = greenValue + 0.2
            blueValue = blueValue + 0.2


            if(redValue > 1 || greenValue > 1 || blueValue > 1){
                redValue = 0
                greenValue = 0
                blueValue = 0
            }
        }

        return arrayColores
    }

    func getExpenseDetails(){

        getExpensesGeneralData()

        getTotalsByCategory()
    }

    func getExpensesGeneralData(){
        
        //Si alguna de las consultas arroja una excepcion
        //es porque las tablas no han sido creadas.
        
        do {
            let queryResult = try BD.executeQuery("SELECT Monto FROM Gastos", values: [])
            
            let queryResult1 = try BD.executeQuery("SELECT Gasto FROM Usuario",values: [])
            
            
            while queryResult.next() {
                totalExpenses = totalExpenses + Float(queryResult.int(forColumn: "Monto"))
            }
            
            while(queryResult1.next()){
                remainingBudget = Float(queryResult1.int(forColumn: "Gasto"))
            }
        } catch {
            createTables()
            getExpensesGeneralData()
        }
    }

    func getTotalsByCategory(){

        let query = try! BD.executeQuery("SELECT SUM(Monto) as TotalGastos, Categoria FROM Gastos GROUP BY(Categoria)", values: [])

        while query.next(){
            arrayGastosTotales.append(Float(query.int(forColumn: "TotalGastos")))
            arrayCategoriasGastos.append(query.string(forColumn: "Categoria"))
        }
        
        let query2 = try! BD.executeQuery("SELECT Categoria FROM Catalogo_categoria", values: [])
        
        while query2.next() {
            arrayCategorias.append(query2.string(forColumn: "Categoria"))
        }
    }
    
    
    
}
