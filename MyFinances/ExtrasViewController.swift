//
//  ExtrasViewController.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 30/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit

class ExtrasViewController: UIViewController,UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var usdOutputxt: UITextField!
    @IBOutlet weak var mxmOutputxt: UITextField!
    @IBOutlet weak var mxmTextField: UITextField!
    @IBOutlet weak var usdTextFiel: UITextField!
    @IBOutlet weak var dolaresPesosLabel: UILabel!
    @IBOutlet weak var bitCoinsLabes: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var convertidorView: UIView!
    
    //MARK: - Atributos
    var Dolar: Float = 0.0
    var Pesosbtc: Float = 0.0
    var Dolarbtc: Float = 0.0
    
    //MARK: - Metodos del ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usdOutputxt.delegate = self
        mxmOutputxt.delegate = self
        mxmTextField.delegate = self    
        usdTextFiel.delegate = self
        
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
        
        convertidorView.layer.cornerRadius = 5
        
        let url = URL(string: "http://bitapeso.com/json/")!
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (datos: Data?, response: URLResponse?, error: Error?) in
            
            if let terribleError = error
            {
                print("Error: \(terribleError.localizedDescription)")
                return
            }
            
            //            let img = UIImage(data: datos!)
            //            self.imgView.image = img
            
            let json = try? JSONSerialization.jsonObject(with: datos!, options: []) as! Dictionary<String, Float>
            
            let results = json?["dolar"]
            self.Dolar = Float(results!)
            let results2 = json?["mxn"]
            self.Pesosbtc = Float(results2!)
            let result3 = json?["usd"]
            self.Dolarbtc = Float(result3!)
            
            /*for result in results {
                print ("\(result ["dolar"]!)")
            }*/
            
            self.dolaresPesosLabel.text = self.dolaresPesosLabel.text! + String(self.Dolar)
            self.bitCoinsLabes.text = self.bitCoinsLabes.text! + String(self.Pesosbtc)
            self.activityIndicator.stopAnimating()
//            print("\(results)")
        }
        
        task.resume()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - Metodos de la Clase
    @IBAction func usdToMxmAction(_ sender: Any) {
        
        let d = Float(usdTextFiel.text!)
        
        if(d != nil){
            mxmOutputxt.text = String(d! * Dolar)
        } else{
            print("Datos aun no listos")
        }
    }

    @IBAction func mxmToUsdAction(_ sender: Any) {
        
        let d = Float(mxmTextField.text!)
        if(d != nil){
            usdOutputxt.text = String(d! / Dolar)
        }else{
            print("Datos aun no listos")
        }
    }
}
