//
//  TasksViewController.swift
//  My Task List
//
//  Created by Tora Mullings on 8/5/19.
//  Copyright © 2020 Learning Mobile Apps. All rights reserved.
//

import UIKit
import CoreData

class TasksViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate {
    
    var currentTask: Task?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtCourse: UITextField!
    @IBOutlet weak var lblDuedate: UILabel!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    
    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [txtDescription, txtCourse]
        
        if sgmtEditMode.selectedSegmentIndex == 0 {
            for textField in textFields {
                textField.isEnabled = false
                textField.borderStyle = UITextField.BorderStyle.none
            }
            btnChange.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
        else if sgmtEditMode.selectedSegmentIndex == 1{
            for textField in textFields {
                textField.isEnabled = true
                textField.borderStyle = UITextField.BorderStyle.roundedRect
            }
            btnChange.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(self.saveTask))
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if currentTask == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentTask = Task(context: context)
        }
        currentTask?.taskDescription = txtDescription.text
        currentTask?.course = txtCourse.text
        return true
    }

    @objc func saveTask() {
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentTask != nil {
            txtDescription.text = currentTask!.taskDescription
            txtCourse.text = currentTask!.course

            let formatter = DateFormatter()
            formatter.dateStyle = .short
            if currentTask!.dueDate != nil {
                lblDuedate.text = formatter.string(from: currentTask!.dueDate!)
            }
        }

        self.changeEditMode(self)
        let textFields: [UITextField] = [txtDescription, txtCourse]
        for textfield in textFields {
            textfield.addTarget(self,
                                action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)),
                                for: UIControl.Event.editingDidEnd)
        }

    }
 
    func dateChanged(date: Date) {
        if currentTask == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentTask = Task(context: context)
        }
        currentTask?.dueDate = date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        lblDuedate.text = formatter.string(from: date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(TasksViewController.keyboardDidShow(notification:)), name:
            UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(TasksViewController.keyboardWillHide(notification:)), name:
            UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        // Get the existing contentInset for the scrollView and set the bottom property to
        //be the height of the keyboard
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.height
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueTaskDate"){
            let dateController = segue.destination as! DateViewController
            dateController.delegate = self
        }
    }
}
