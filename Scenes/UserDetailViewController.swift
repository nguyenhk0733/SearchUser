import UIKit
import SafariServices

final class UserDetailViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!

    var username: String = ""
    private var detail: GitHubUserDetail?
    private let favorites = CoreDataFavoriteStore()
    private var favoriteButton: UIBarButtonItem?
    private var isFavorite = false {
        didSet { updateFavoriteButtonAppearance() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = username
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.clipsToBounds = true
        if let stackView = avatarImageView.superview as? UIStackView {
            stackView.alignment = .center
        }
        configureFavoriteButton()
        loadDetail()
    }

    private func loadDetail() {
        GitHubAPI.shared.getUserDetail(username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let d):
                self.detail = d
                self.isFavorite = self.favorites.isFavorite(id: Int64(d.id))
                self.render(d)
            case .failure(let err):
                self.showError(err.localizedDescription)
            }
        }
    }

    private func render(_ u: GitHubUserDetail) {
        if let url = URL(string: u.avatar_url) {
            ImageLoader.shared.load(url, into: avatarImageView)
        }
        loginLabel.text = u.login
        nameLabel.text = u.name ?? ""
        bioLabel.text = u.bio ?? ""
        statsLabel.text = "👥 \(u.followers) followers • \(u.following) following • 📂 \(u.public_repos) repos"
        locationLabel.text = u.location ?? ""
        openButton.addTarget(self, action: #selector(openOnGitHub), for: .touchUpInside)
        favoriteButton?.isEnabled = true
    }

    @objc private func openOnGitHub() {
        guard let urlStr = detail?.html_url, let url = URL(string: urlStr) else { return }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }

    private func configureFavoriteButton() {
        let button = UIBarButtonItem(image: UIImage(systemName: "star"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(toggleFavorite))
        button.isEnabled = false
        navigationItem.rightBarButtonItem = button
        favoriteButton = button
        updateFavoriteButtonAppearance()
    }

    private func updateFavoriteButtonAppearance() {
        guard let button = favoriteButton else { return }
        button.image = UIImage(systemName: isFavorite ? "star.fill" : "star")
        button.tintColor = isFavorite ? .systemYellow : view.tintColor
    }

    @objc private func toggleFavorite() {
        guard let detail = detail else { return }
        let dto = FavoriteUserDTO(id: Int64(detail.id),
                                  login: detail.login,
                                  avatarURL: detail.avatar_url)

        do {
            if isFavorite {
                try favorites.remove(id: dto.id)
            } else {
                try favorites.add(dto)
            }
            isFavorite.toggle()
        } catch {
            showError("Cannot update favorites. \(error.localizedDescription)")
        }
    }

    private func showError(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
