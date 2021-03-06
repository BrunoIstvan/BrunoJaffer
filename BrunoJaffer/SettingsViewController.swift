//
//  SettingsViewController.swift
//  BrunoJaffer
//
//  Created by Bruno Istvan Campos Monteiro on 25/08/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UITableViewDataSource,
                        UITableViewDelegate, UITextFieldDelegate  {

    let ud = UserDefaults.standard
    
    var states: [State] = []
    
    let labelEmpty: UILabel = {
        let labelEmpty = UILabel()
        labelEmpty.text = "Sua lista está vazia!"
        labelEmpty.textAlignment = .center
        labelEmpty.textColor = .black
        return labelEmpty
    }()
    
    @IBOutlet weak var tfDolarExchange: UITextField!
    
    @IBOutlet weak var tfIOFTax: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfIOFTax.keyboardType = UIKeyboardType.numbersAndPunctuation
        tfDolarExchange.keyboardType = UIKeyboardType.numbersAndPunctuation
        tfIOFTax.delegate = self
        tfDolarExchange.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appReturnedFromBackground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    @objc func appReturnedFromBackground() {
        print("App returned from background!")
        recoverSettings()
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        saveSetting()
    }
    
    func recoverSettings() {
        tfIOFTax.text = ud.string(forKey: "iof") ?? "0.0"
        tfDolarExchange.text = ud.string(forKey: "exchange") ?? "0.0"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recoverSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSetting()
    }
    
    func saveSetting() {
        ud.set(tfIOFTax.text?.replacingOccurrences(of: ",", with: ".") ?? "0.0", forKey: "iof")
        ud.set(tfDolarExchange.text?.replacingOccurrences(of: ",", with: ".") ?? "0.0", forKey: "exchange")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadStates()
    }

    @IBAction func addStateTax(_ sender: UIButton) {
        showDialog(state: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfDolarExchange || textField == tfIOFTax {
            self.view.endEditing(true)
            return true
        }
        return false
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Fechar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func saveData(state: State?, alert: UIAlertController) {
        // verifica se o nome foi informado
        guard let stateName = alert.textFields?[0].text, !stateName.isEmpty else {
            self.showMessage(message: "Informe o nome do estado")
            return
        }
        // verifica se o imposto foi informado
        guard let tax = alert.textFields?[1].text, !tax.isEmpty else {
            self.showMessage(message: "Informe o imposto")
            return
        }
        // e se está no formato double ...
        guard let _ = Double(tax) else {
            self.showMessage(message: "Imposto informado não é válido. Use o formato 99.9")
            return
        }
        if Double(tax) ?? 0 <= 0 {
            self.showMessage(message: "Imposto informado não é válido. Informe um valor positivo.")
            return
        }
        // se estiver tudo OK... gravar o estado/imposto
        let state = state ?? State(context: self.context)
        state.name = stateName
        state.tax = Double(tax) ?? 0
        try! self.context.save()
        self.loadStates()
    }
    
    private func showDialog(state: State?) {
        let title = state == nil ? "Adicionar" : "Atualizar"
        let alert = UIAlertController(title: title, message: "Preencha o estado e o imposto", preferredStyle: .alert)
        let okAction = UIAlertAction(title: title, style: .default) { (action) in
            self.saveData(state: state, alert: alert)
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Nome do Estado"
            textField.text = state?.name
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Imposto"
            textField.text = state?.tax.description
            textField.keyboardType = .numbersAndPunctuation
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showConfirmDialog(executeOnConfirm: @escaping () -> Swift.Void) -> Void {
        let message = "Confirma a exclusão? É importante lembrar que a exclusão de um Estado pode causar a exclusão de produtos vinculados a ele."
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { (action) in
            executeOnConfirm()
        }
        alert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        states = try! context.fetch(fetchRequest)
        tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = states.count == 0 ? labelEmpty : nil
        return states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let state = states[indexPath.row]
        cell.textLabel?.text = state.name ?? ""
        cell.detailTextLabel?.text = state.tax.description
        cell.detailTextLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = self.states[indexPath.row]
        self.showDialog(state: state)
        tableView.setEditing(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action, indexPath) in
            self.showConfirmDialog(executeOnConfirm: {
                let state = self.states[indexPath.row]
                self.context.delete(state)
                try! self.context.save()
                self.states.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
        return [deleteAction]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // User pressed the delete-key to remove a character, this is always valid, return true to allow change
        if string.isEmpty { return true }
        
        // Build the full current string: TextField right now only contains the
        // previous valid value. Use provided info to build up the new version.
        // Can't just concat the two strings because the user might've moved the
        // cursor and delete something in the middle.
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Use our string extensions to check if the string is a valid double and
        // only has the specified amount of decimal places.
        return replacementText.isValidDouble(maxDecimalPlaces: 2)
    }
    
    
}
