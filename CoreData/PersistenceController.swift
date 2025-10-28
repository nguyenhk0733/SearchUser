import CoreData

final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

