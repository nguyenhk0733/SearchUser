import Foundation
import UIKit

final class SearchViewController: UITableViewController {

    struct UserVM {
        let id: Int
        let login: String
        let avatarURL: String
    }

    private var users: [UserVM] = []
    private let favorites = CoreDataFavoriteStore()

    // MARK: - Table Data Source

    override func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    override func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let u = users[indexPath.row]

        cell.textLabel?.text = u.login
        cell.detailTextLabel?.text = "ID: \(u.id)"
        cell.imageView?.image = UIImage(systemName: "person.crop.circle") // placeholder

        // Nút ★ ở accessoryView
        let isFav = favorites.isFavorite(id: Int64(u.id))
        cell.accessoryView = makeStarButton(isOn: isFav)

        return cell
    }

    // MARK: - Star button

    private func makeStarButton(isOn: Bool) -> UIButton {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "star"), for: .normal)
        b.setImage(UIImage(systemName: "star.fill"), for: .selected)
        b.isSelected = isOn
        b.tintColor = .systemYellow
        b.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        b.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
        return b
    }

    @objc private func starTapped(_ sender: UIButton) {
        // Tìm indexPath từ vị trí của nút trong bảng
        let pt = sender.convert(.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: pt) else { return }
        let u = users[indexPath.row]
        let dto = FavoriteUserDTO(id: Int64(u.id), login: u.login, avatarURL: u.avatarURL)

        if favorites.isFavorite(id: dto.id) {
            try? favorites.remove(id: dto.id)
        } else {
            try? favorites.add(dto)
        }

        // Cập nhật icon ngay
        if let cell = tableView.cellForRow(at: indexPath),
           let star = cell.accessoryView as? UIButton {
            star.isSelected = favorites.isFavorite(id: dto.id)
        }
    }
}
