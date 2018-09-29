//
//  TotalViewController.swift
//  BrunoJaffer
//
//  Created by Usuário Convidado on 25/08/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController {
    
    @IBOutlet weak var lbTotalDolar: UILabel!
    
    @IBOutlet weak var lbTotalReal: UILabel!
    
    var products: [Product] = []
    let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        calculateTotals()
    }
    
    private func calculateTotals() {
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "price", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        products = try! context.fetch(fetchRequest)
        
        var totalReal: Double = 0.0
        var totalDolar: Double = 0.0
        
        let iof = ud.double(forKey: "iof")
        let exchange = ud.double(forKey: "exchange")
        
        for product in products {
            
            let state = product.state
            
            // recupera o valor em dólar e adiciona a taxa do estado onde foi realizada a compra...
            var productDolar = product.price + (product.price * (state?.tax ?? 0) / 100)
            if product.creditCardPayment {
                productDolar = productDolar + (productDolar * iof / 100)
            }
            
            totalDolar = totalDolar + productDolar
            
        }
        
        totalReal = totalDolar * exchange
        
        //print("Total Dólar: ", totalDolar)
        //print("Total Real: ", totalReal)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        lbTotalDolar.text = formatter.string(from: NSNumber(value: totalDolar))?.replacingOccurrences(of: "R$", with: "US$ ")
        lbTotalReal.text = formatter.string(from: NSNumber(value: totalReal))?.replacingOccurrences(of: "R$", with: "R$ ")
        
        
    }

}
