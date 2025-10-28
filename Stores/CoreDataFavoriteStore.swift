import CoreData

struct FavoriteUserDTO { let id: Int64; let login: String; let avatarURL: String }

protocol FavoriteStore {
    func isFavorite(id: Int64) -> Bool
    func add(_ u: FavoriteUserDTO) throws
    func remove(id: Int64) throws
    func all() throws -> [FavoriteUserDTO]
}

final class CoreDataFavoriteStore: FavoriteStore {
    private let ctx: NSManagedObjectContext = PersistenceController.shared.container.viewContext

    func isFavorite(id: Int64) -> Bool {
        let req: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        req.fetchLimit = 1
        return (try? ctx.count(for: req)) ?? 0 > 0
    }


