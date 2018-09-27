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
        //Agora não mais
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return movies.count
        
        let count = fetchedResultController.fetchedObjects?.count ?? 0
        
        tableView.backgroundView = (count == 0) ? labelEmpty : nil
        
        return count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableViewCell
        
        let product = fetchedResultController.object(at: indexPath)
        
        cell.ivProduct.image = product.image as? UIImage
        cell.tfNameProduct.text = product.productName
        cell.tfPriceProduct.text = Double(product.price).description
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//            let product = fetchedResultController.object(at: indexPath)
//            do {
//                context.delete(product)
//                try context.save()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action, indexPath) in
            let product = self.fetchedResultController.object(at: indexPath)
            do {
                self.context.delete(product)
                try self.context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return [deleteAction]
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
         return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ListPurchasesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

//    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Product> = {
//        // Create Fetch Request
//        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
//
//        // Configure Fetch Request
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//
//        // Create Fetched Results Controller
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        // Configure Fetched Results Controller
//        fetchedResultsController.delegate = self
//
//        return fetchedResultsController
//    }()
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        loadPurchases()
//    }
//
//    func loadPurchases() {
//
//        //Agora não mais
//        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultController.delegate = self
//
//        do {
//            try fetchedResultController.performFetch()
//        } catch {
//            print(error.localizedDescription)
//        }
//
//    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        let count = fetchedResultController.fetchedObjects?.count ?? 0
//
//        tableView.backgroundView = (count == 0) ? labelEmpty : nil
//
//        return count
//    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableViewCell
//
//        var product = fetchedResultController.object(at: indexPath)
//
//        cell.ivProduct.image = product.image as? UIImage
//        cell.tfNameProduct.text = product.productName
//        cell.tfPriceProduct.text = Double(product.price).description
//
//        // Configure the cell...
//
//        return cell
//    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

//}
//
//extension ListPurchasesTableViewController: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.reloadData()
//    }
//}


