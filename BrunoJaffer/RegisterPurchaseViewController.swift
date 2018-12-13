//
//  RegisterPurchaseViewController.swift
//  BrunoJaffer
//
//  Created by Usuário Convidado on 25/08/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

class RegisterPurchaseViewController: UIViewController, UITextFieldDelegate {

    let pickerView = UIPickerView(frame: .zero)
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    
    var states: [State] = []
    var selectedState: State!
    var selectedPicture: UIImage?
    
    var product: Product!
    
    @IBOutlet weak var tfNameProduct: UITextField!
    @IBOutlet weak var tfStatePurchase: UITextField!
    @IBOutlet weak var tfPriceProduct: UITextField!
    @IBOutlet weak var swCreditCard: UISwitch!
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var btnAddEdit: UIButton!
    
    @IBOutlet weak var btnPickImage: UIButton!
    
    
    @IBAction func saveProduct(_ sender: UIButton) {
        
        let defaultImage: UIImage! = UIImage(named: "Add_Image")
        
        guard let productName = tfNameProduct.text, !productName.isEmpty else {
            self.showMessage(message: "Informe o nome do produto")
            return
        }
        guard let picture = ivProduct.image, picture.size != CGSize(width: 0, height: 0) else {
            self.showMessage(message: "Selecione uma imagem para o produto")
            return
        }
        if self.isEqualImage(image1: defaultImage, image2: picture) {
            self.showMessage(message: "Selecione uma imagem para o produto")
            return
        }
        if selectedState == nil {
            self.showMessage(message: "Selecione um estado")
            return
        }
        guard let price = tfPriceProduct.text, !price.isEmpty else {
            self.showMessage(message: "Informe o preço do produto")
            return
        }
        guard let _ = Double(price) else {
            self.showMessage(message: "Preço informado não é válido. Use o formato 99.9")
            return
        }
        if Double(price) ?? 0 <= 0  {
            self.showMessage(message: "Preço informado não é válido. Informe um valor positivo.")
            return
        }
        if(product == nil) {
            product = Product(context: context)
        }
        product.productName = productName
        product.price = Double(price) ?? 0
        product.creditCardPayment = swCreditCard.isOn
        product.image = picture
        product.state = self.selectedState!
        
        showConfirmDialog(executeOnConfirm: {
            do {
                try self.context.save()
                self.navigationController?.popViewController(animated: true)
            } catch {
                print(error.localizedDescription)
            }
        })
        
    }
    
    private func showConfirmDialog(executeOnConfirm: @escaping () -> Swift.Void) -> Void {
        let message = "Confirma a gravação?"
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { (action) in
            executeOnConfirm()
        }
        alert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addStateTax(_ sender: UIButton) {
        done()
    }
    
    private func isEqualImage(image1: UIImage, image2: UIImage) -> Bool {
        let data1: Data? = UIImagePNGRepresentation(image1)
        let data2: Data? = UIImagePNGRepresentation(image2)
        return data1 == data2
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        
        // verificar se deve usar actionSheet ou alert
        let alert = UIAlertController(title: "Selecionar imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)
        //let alert = UIAlertController(title: "Selecionar imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .alert)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default) { (action) in
                self.selectPicture(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        //let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action) in
        //    self.selectPicture(sourceType: .savedPhotosAlbum)
        //}
        //alert.addAction(photosAction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    private func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadStates()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfPriceProduct || textField == tfNameProduct {
            self.view.endEditing(true)
            return true
        }
        return false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        tfPriceProduct.delegate = self
        //tfNameProduct.delegate = self
        tfPriceProduct.keyboardType = .numbersAndPunctuation
        
        self.configureToolbar()
        
        if product != nil {
            
            tfPriceProduct.text = Double(product.price).description
            tfStatePurchase.text = product.state?.name
            tfNameProduct.text = product.productName
            swCreditCard.setOn(product.creditCardPayment, animated: true)
            ivProduct.image = product.image as? UIImage
            selectedPicture = ivProduct.image
            btnAddEdit.setTitle("Atualizar", for: .normal)
            selectedState = product.state
            
        }
        
    }
    
    private func configureToolbar() {
        let btOk = UIBarButtonItem(title: "Selecionar", style: UIBarButtonItemStyle.done, target: self, action: #selector(done))
        //(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(done))
        let btSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let btCancel = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancel))
        toolbar.backgroundColor = .white
        toolbar.setItems([btCancel, btSpace, btOk], animated: false)
        self.loadStates()
        tfStatePurchase.inputView = pickerView
        tfStatePurchase.inputAccessoryView = toolbar
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        states = try! context.fetch(fetchRequest)
    }
    
    @objc func done() {
        if states.count > 0 {
            let state = states[pickerView.selectedRow(inComponent: 0)]
            tfStatePurchase.text = state.name
            selectedState = state
        }
        cancel()
    }
    
    @objc func cancel() {
        view.endEditing(true)
    }

}


extension RegisterPurchaseViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
}

extension RegisterPurchaseViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row].name
    }
}

extension RegisterPurchaseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
          
            selectedPicture = image
            
            let aspectRatio = image.size.width / image.size.height
            let maxSize: CGFloat = 500
            var smallSize: CGSize
            if aspectRatio > 1 {
                smallSize = CGSize(width: maxSize, height: maxSize/aspectRatio)
            } else {
                smallSize = CGSize(width: maxSize*aspectRatio, height: maxSize)
            }
            
            UIGraphicsBeginImageContext(smallSize)
            image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
            ivProduct.image = UIGraphicsGetImageFromCurrentImageContext()
            ivProduct.alpha = 1
            ivProduct.contentMode = .scaleToFill
            UIGraphicsEndImageContext()
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
