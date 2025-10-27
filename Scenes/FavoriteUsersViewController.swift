import UIKit
import CoreData

final class FavoriteUsersViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private var frc: NSFetchedResultsController<FavoriteUser>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorite Users"

        let req: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]

        frc = NSFetchedResultsController(fetchRequest: req,
                                         managedObjectContext: PersistenceController.shared.container.viewContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
    }

    // Table
    override func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        frc.sections?.first?.numberOfObjects ?? 0
    }

    override func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let u = frc.object(at: indexPath)
        cell.textLabel?.text = u.login
        cell.detailTextLabel?.text = "ID: \(u.id)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // (Tuỳ chọn) auto update khi Core Data đổi
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { tableView.beginUpdates() }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { tableView.endUpdates() }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete: tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update: tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:   tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default: break
        }
    }
}
