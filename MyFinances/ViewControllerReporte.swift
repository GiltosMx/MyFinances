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

    @IBOutlet weak var pieChart: PieChartView!

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
    var arrayCategoriasGastos: Array<String> = []

    override func viewWillAppear(_ animated: Bool) {

        createOrOpenDB()

        clearDataToDisplay()

        getExpenseDetails()

        setupChartData()

        setInformationLabels()

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

    func setupChartData(){

        var chartEntry: [PieChartDataEntry] = []

        //Si el arreglo de gastos totales no tiene datos,
        //insertar 0 en el valor de gastos para la grafica
        
        if(arrayGastosTotales.count < 1){
            
            chartEntry.append(PieChartDataEntry(value: 0, label: "NO HAY DATOS"))
            
        } else{
            
//            for index in 0...arrayCategorias.count-1{
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
        let queryResult = try! BD.executeQuery("SELECT Monto FROM Gastos", values: [])

        let queryResult1 = try! BD.executeQuery("SELECT Gasto FROM Usuario",values: [])


        while queryResult.next() {
            totalExpenses = totalExpenses + Float(queryResult.int(forColumn: "Monto"))
        }

        while(queryResult1.next()){
            remainingBudget = Float(queryResult1.int(forColumn: "Gasto"))
        }
    }

    func getTotalsByCategory(){

        let query = try! BD.executeQuery("SELECT SUM(Monto) as TotalGastos, Categoria FROM Gastos GROUP BY(Categoria)", values: [])

        while query.next(){
            arrayGastosTotales.append(Float(query.int(forColumn: "TotalGastos")))
            arrayCategoriasGastos.append(query.string(forColumn: "Categoria"))
            
            
        }
        print("Arreglo categorias de tabla gastos:")
        print(arrayCategoriasGastos)
        
        let query2 = try! BD.executeQuery("SELECT Categoria FROM Catalogo_categoria", values: [])
        
        while query2.next() {
            arrayCategorias.append(query2.string(forColumn: "Categoria"))
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

    func clearDataToDisplay(){
        totalExpenses = 0
        arrayCategorias.removeAll()
        arrayCategoriasGastos.removeAll()
        arrayGastosTotales.removeAll()
    }

}
