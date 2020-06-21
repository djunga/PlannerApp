//
//  DateViewController.swift
//  My Contact List
//
//  Created by Michael Eierman on 8/6/19.
//  Copyright © 2019 Learning Mobile Apps. All rights reserved.
//

import UIKit

protocol DateControllerDelegate: class {
    func dateChanged(date: Date)
}

class DateViewController: UIViewController {
    
    weak var delegate: DateControllerDelegate?
    
    @IBOutlet weak var dtpDate: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let saveButton: UIBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save,
                            target: self,
                            action: #selector(saveDate))
        self.navigationItem.rightBarButtonItem = saveButton
        self.title = "Pick Birthdate"
    }
    
    @objc func saveDate(){
        self.delegate?.dateChanged(date: dtpDate.date)
        self.navigationController?.popViewController(animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
