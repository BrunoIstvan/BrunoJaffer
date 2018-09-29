//
//  ListPurchasesTableViewController.swift
//  BrunoJaffer
//
//  Created by Usuário Convidado on 25/08/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData


class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var tfNameProduct: UILabel!
    @IBOutlet weak var tfPriceProduct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

class ListPurchasesTableViewController: UITableViewController {
    
    let labelEmpty: UILabel = {
        let labelEmpty = UILabel()
        labelEmpty.text = "Sua lista está vazia!"
        labelEmpty.textAlignment = .center
        labelEmpty.textColor = .black
        return labelEmpty
    }()
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPurchases()
    }
    
    private func loadPurchases() {

        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let row = tableView.indexPathForSelectedRow?.row {
            if row >= 0 {
                if let vc = segue.destination as? RegisterPurchaseViewController {
                    vc.product = fetchedResultController.object(at: tableView.indexPathForSelectedRow!)
                }
            }
        }
    }
    
    private func showConfirmDialog(executeOnConfirm: @escaping () -> Swift.Void) -> Void {
        let message = "Confirma a exclusão?"
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { (action) in
            executeOnConfirm()
        }
        alert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultController.fetchedObjects?.count ?? 0
        tableView.backgroundView = (count == 0) ? labelEmpty : nil
        return count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableViewCell
        let product = fetchedResultController.object(at: indexPath)
        cell.ivProduct.image = product.image as? UIImage
        cell.ivProduct.contentMode = .scaleToFill
        cell.tfNameProduct.text = product.productName
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        cell.tfPriceProduct.text = formatter.string(from: NSNumber(value: product.price))?.replacingOccurrences(of: "R$", with: "US$ ")
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action, indexPath) in
            
            self.showConfirmDialog(executeOnConfirm: {
                let product = self.fetchedResultController.object(at: indexPath)
                do {
                    self.context.delete(product)
                    try self.context.save()
                } catch {
                    print(error.localizedDescription)
                }
            })
            
        }
        
        return [deleteAction]
    }
    
}

extension ListPurchasesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
    

