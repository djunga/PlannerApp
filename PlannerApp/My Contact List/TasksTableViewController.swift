/*
 NAME: Tora Mullings
 SB ID: 111407756
 
 Some of this code was taken from the textbook.
 */

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
  
    var tasks:[NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        loadDataFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        tableView.reloadData()
    }

    func loadDataFromDatabase() {
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.kSortField)
        let sortAscending = settings.bool(forKey: Constants.kSortDirectionAscending)
        //Set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext
        //Set up Request
        let request = NSFetchRequest<NSManagedObject>(entityName: "Task")
        //Specify sorting
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptorArray = [sortDescriptor]
        //to sort by multiple fields, add more sort descriptors to the array
        request.sortDescriptors = sortDescriptorArray
        do {
            tasks = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        
        // Configure the cell...
        let task = tasks[indexPath.row] as? Task
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let todayDate:String = formatter.string(from: Date())
        let myString = formatter.string(from: (task?.dueDate)!)
        let now = Calendar.current.dateComponents(in: .current, from: Date())
        let tomorrow = DateComponents(year: now.year, month: now.month, day: now.day! + 1)
        let tomorrowDate:String = formatter.string(from: Calendar.current.date(from: tomorrow)!)

        
        let inputtedDate = formatter.date(from: myString)
        let todayDateStr = formatter.date(from: todayDate)
        let tomorrowDateStr = formatter.date(from: tomorrowDate)
        
        formatter.dateFormat = "dd-MMM-yyyy"
        // again convert your date to string
        let myStringafd = formatter.string(from: inputtedDate!)
        let todayDatefd = formatter.string(from: todayDateStr!)
        let tomorrowDatefd = formatter.string(from: tomorrowDateStr!)
        
        cell.textLabel?.text = (task?.taskDescription)!
        cell.detailTextLabel?.text = (task?.course)! + "                         \(myStringafd)"
        cell.accessoryType = .none
        //let todayDate:String = formatter
        if(todayDatefd == myStringafd) {
            cell.backgroundColor = UIColor(red:0.7, green:0.0, blue:0.0, alpha: 0.7)
        }
        if(tomorrowDatefd == myStringafd) {
            cell.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.7, alpha: 0.3)
        }
        
        return cell
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = tasks[indexPath.row] as? Task
        let description = selectedTask!.taskDescription!
        let actionHandler = { (action:UIAlertAction!) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "TaskController")
                as? TasksViewController
            controller?.currentTask = selectedTask
            self.navigationController?.pushViewController(controller!, animated: true)
        }
        
        let alertController = UIAlertController(title: "Task selected",
                                                message:  "Selected row: \(indexPath.row) (\(description))",
            preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        let actionDetails = UIAlertAction(title: "Show Details",
                                          style: .default,
                                          handler: actionHandler)
        alertController.addAction(actionCancel)
        alertController.addAction(actionDetails)
        present(alertController, animated: true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let task = tasks[indexPath.row] as? Task
            let context = appDelegate.persistentContainer.viewContext
            context.delete(task!)
            do {
                try context.save()
            }
            catch  {
                fatalError("Error saving context: \(error)")
            }
            loadDataFromDatabase()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array,
            //and add a new row to the table view
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditTask" {
            let taskController = segue.destination as? TasksViewController
            let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let selectedTask = tasks[selectedRow!] as? Task
            taskController?.currentTask = selectedTask!
        }
    }
}
