//
//  UIViewController+CoreData.swift
//  BrunoJaffer
//
//  Created by Bruno Istvan Campos Monteiro on 26/08/18.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
