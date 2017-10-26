import UIKit
import SQLite


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Step 1 Begin
    var database : Connection!
    // Step 1 End
    @IBOutlet weak var nameFieldOutlet: UITextField!
    @IBOutlet weak var emailFieldOutlet: UITextField!
    @IBOutlet weak var contactTableOutlet: UITableView!
    
    
    
    // Step 3 Begin
    let contactTable = Table("contacts")
    let id = Expression<Int64>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    // Step 3 End
    
    // Step 4 Begin
    func createTable() {
        let createTable = self.contactTable.create{
            (table) in
            table.column(self.id, primaryKey: true)
            table.column(name)
            table.column(email)
            
        }
        do {
            try self.database.run(createTable)
            print("Contact Table Created")
        }catch {
            print(error)
        }
        
    }
    // Step 4 End
    
    // Step 7 Begin
    func listContacts () {
        do {
            let contacs = try self.database.prepare(self.contactTable)
            contactListArray = [Contact]() // Diziyi Clear Etmek İçin Ama KULLANMA !!
            
            
            
            for cnt in contacs{
                
                //print("id: \(cnt[id]), name: \(cnt[name]), email: \(cnt[email])")
                contactListArray.append(
                    Contact(
                        id: cnt[self.id],
                        name: cnt[self.name],
                        email: cnt[self.email]
                    )
                )
            }
            print(contactListArray)
            contactTableOutlet.reloadData()
            print("Contacts Listed")
        } catch {
            print(error)
        }
    }
    // Step 7 End
    
    // Array Created
    var contactListArray = [Contact]()
    var contactID : Int64 = 0
    
    // Table View Functions Begin
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellItem = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cellItem.textLabel!.text = contactListArray[indexPath.row].name
        return cellItem
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contactID = contactListArray[indexPath.row].id
        nameFieldOutlet.text! = contactListArray[indexPath.row].name
        emailFieldOutlet.text! = contactListArray[indexPath.row].email
    }
    // Table View Functions End
    
    // Insert Action Begin
    @IBAction func insertButtonAction(_ sender: UIButton) {
        
        // Step 6 Begin
        let nameField = nameFieldOutlet.text
        let emailField = emailFieldOutlet.text
        
        let insertContact = self.contactTable.insert(
            name <- nameField!,
            email <- emailField!
        )
        do {
            
            try self.database.run(insertContact)
            print("Contact Added")
        }catch{
            print(error)
        }
        
        // Step 6 End
        listContacts()
        print("Insert işlemi yapıldı")
    }
    // Insert Action End
    
    
    
    
    
    
    // Update Action Begin
    @IBAction func updateButtonAction(_ sender: UIButton) {
        if contactID > 0 {
            let contact = self.contactTable.filter(self.id == contactID)
            let nameField = nameFieldOutlet.text
            let emailField = emailFieldOutlet.text
            let updateContact = contact.update(
                name <- nameField!,
                email <- emailField!
            )
            do {
                try self.database.run(updateContact)
                listContacts()
                print("Contact Updated")
            }catch {
                print(error)
            }
        }
        
        print("Update işlemi yapıldı")
    }
    // Update Action End
    
    
    
    
    
    // Delete Action Begin
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        
        if contactID > 0 {
            let contact = self.contactTable.filter(self.id == contactID)
   
        
            do {
                try self.database.run(contact.delete())
                listContacts()
                print("Contact Deleted")
            }catch {
                print(error)
            }
        }
        
        print("Delete işlemi yapıldı")
    }
    // Delete Action End
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Step 2 -> Create DB Begin
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent("contact").appendingPathExtension("sqlite3")
            let db = try Connection(fileURL.path)
            self.database = db
        } catch{
            print(error)
        }
        // Step 2 -> Create DB End
        
        // Step 5 -> Create Table Begin
        createTable()
        listContacts()
        // Step 5 -> Create Table End
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

