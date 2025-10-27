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

    func add(_ u: FavoriteUserDTO) throws {
        guard !isFavorite(id: u.id) else { return }
        let obj = FavoriteUser(context: ctx)
        obj.id = u.id
        obj.login = u.login
        obj.avatarUrl = u.avatarURL
        obj.addedAt = Date()
        try ctx.save()
    }

    func remove(id: Int64) throws {
        let req: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        if let obj = try ctx.fetch(req).first {
            ctx.delete(obj); try ctx.save()
        }
    }

    func all() throws -> [FavoriteUserDTO] {
        let req: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
        return try ctx.fetch(req).map {
            .init(id: $0.id, login: $0.login ?? "", avatarURL: $0.avatarUrl ?? "")
        }
    }
}
