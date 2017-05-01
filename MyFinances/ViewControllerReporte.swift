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
import Darwin

class ViewControllerReporte: UIViewController, ChartViewDelegate {

    @IBOutlet weak var PieChart: PieChartView!
    
    @IBOutlet weak var lblCantidadGastos: UILabel!
    @IBOutlet weak var lblDescripcionGasto: UILabel!
    @IBOutlet weak var lblFechaGasto: UILabel!
    @IBOutlet weak var lblMontoGasto: UILabel!
    @IBOutlet weak var lblCategoriaGasto: UILabel!
    
    
    var BD: FMDatabase!
    var totalExpenses : Float = 0
    var remainingBudget : Float = 0
    var arrayGastosTotales: Array<Float> = []
    var arrayCategorias: Array<String> = []
    var isChartLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        createOrOpenDB()
        
        if(!isChartLoaded){
    
            getExpenseDetails()
            
            setupChartData()
            
            isChartLoaded = true
            
            setInformationLabels()
        }
        
    }
    
    func setInformationLabels(){
        
        lblCantidadGastos.text = String(totalExpenses)
        
        let gastoMayorQuery = try! BD.executeQuery("SELECT Fecha, Categoria, Descripcion, Monto FROM Gastos WHERE Monto = (SELECT MAX(Monto) AS MontoMax FROM Gastos)"
            , values: [])
        
        while gastoMayorQuery.next() {
            lblDescripcionGasto.text = gastoMayorQuery.string(forColumn: "Descripcion")
            
            lblFechaGasto.text = gastoMayorQuery.string(forColumn: "Fecha")
            
            lblCategoriaGasto.text = gastoMayorQuery.string(forColumn: "Categoria")
            
            lblMontoGasto.text = String(gastoMayorQuery.int(forColumn: "Monto"))
        }
        
    }
    
    func setupChartData(){
        
        var chartEntry: [PieChartDataEntry] = []
        
        
        for index in 0...arrayCategorias.count-1{
            
            chartEntry.append(PieChartDataEntry(value: Double(arrayGastosTotales[index]), label: arrayCategorias[index]))
        }
        
        let chartDataSet = PieChartDataSet(values: chartEntry, label: nil)
        
        let arrayColores = fillChartColorArray()
        
        chartDataSet.setColors(arrayColores, alpha: 1)
       
        let chartData = PieChartData(dataSet: chartDataSet)
        
        PieChart.drawEntryLabelsEnabled = false
        PieChart.sizeToFit()
        PieChart.noDataTextColor = UIColor.black
        PieChart.data = chartData
    }
    
    func fillChartColorArray() -> [NSUIColor]{
        
        var arrayColores: [NSUIColor] = []
        
        var redValue:CGFloat = 0.0
        var greenValue:CGFloat = 0.125
        var blueValue:CGFloat = 0.50
        
        for _ in 0...arrayCategorias.count{
            
            arrayColores.append(UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0))
            
            redValue = redValue + 0.2
            greenValue = greenValue + 0.2
            blueValue = blueValue + 0.2
        }
        
        return arrayColores
    }
    
    func getExpenseDetails(){
        
        getExpensesGeneralData()
        
        getTotalsByCategory()
    }
    
    func getExpensesGeneralData(){
        let queryResult = try! BD.executeQuery("SELECT Monto FROM Gastos", values: [])
        
        let queryResult1 = try! BD.executeQuery("SELECT Gasto FROM Usuario",values: [])
        
        
        while queryResult.next() {
            totalExpenses = totalExpenses + Float(queryResult.int(forColumn: "Monto"))
        }
        
        while(queryResult1.next()){
            remainingBudget = Float(queryResult1.int(forColumn: "Gasto"))
        }
        
        print("Gasto total: \(totalExpenses)")
        print("Presupuesto restante: \(remainingBudget)\n\n")
    }
    
    func getTotalsByCategory(){
        
        let query = try! BD.executeQuery("SELECT SUM(Monto) as TotalGastos, Categoria FROM Gastos GROUP BY(Categoria)", values: [])
        
        while query.next()
        {
            arrayGastosTotales.append(Float(query.int(forColumn: "TotalGastos")))
            arrayCategorias.append(query.string(forColumn: "Categoria"))
        }
        
        print(arrayCategorias)
        print(arrayGastosTotales)
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
            print("si se abrio BD en reporte")
            return
        }

   

}

}
