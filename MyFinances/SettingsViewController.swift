//
//  SettingsViewController.swift
//  MyFinances
//
//  Created by Adrián Toscano Prieto on 30/04/17.
//  Copyright © 2017 Adrián Toscano Prieto. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var nombreTxt: UITextField!
    @IBOutlet weak var apellidoLabel: UILabel!
    @IBOutlet weak var apellidoTxt: UITextField!
    @IBOutlet weak var correoTxt: UITextField!
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var presupuestoTxt: UITextField!
    @IBOutlet weak var presupuestoLabel: UILabel!
    @IBOutlet weak var ctaegoriaPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nombreTxt.delegate = self
        apellidoTxt.delegate = self
        correoTxt.delegate = self
        presupuestoTxt.delegate = self
    }

    @IBAction func cambiarNombre(_ sender: Any) {
    }
    @IBAction func cambiarApellio(_ sender: Any) {
    }
    @IBAction func cambiarCorreo(_ sender: Any) {
    }
    
    @IBAction func cambiarPresupuesto(_ sender: Any) {
    }
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 100),
                                         animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        textField.resignFirstResponder()
        
        return true
    }
    

}
