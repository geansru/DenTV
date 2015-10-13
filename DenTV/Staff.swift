//
//  Staff.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 13.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit

class Staff {
    static func registerCell(cellName: String, tableView: UITableView) {
        let nib = UINib(nibName: cellName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellName)
    }
}