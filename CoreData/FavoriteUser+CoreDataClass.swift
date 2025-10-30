import Foundation
import CoreData

@objc(FavoriteUser)
public class FavoriteUser: NSManagedObject {
}

extension FavoriteUser {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteUser> {
        return NSFetchRequest<FavoriteUser>(entityName: "FavoriteUser")
    }

    @NSManaged public var id: Int64
    @NSManaged public var login: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var addedAt: Date?
}
