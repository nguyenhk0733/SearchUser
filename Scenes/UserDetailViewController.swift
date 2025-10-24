
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = username
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.clipsToBounds = true
        loadDetail()
    }

    private func loadDetail() {
        GitHubAPI.shared.getUserDetail(username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let d):
                self.detail = d
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
    }

    @objc private func openOnGitHub() {
        guard let urlStr = detail?.html_url, let url = URL(string: urlStr) else { return }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }

    private func showError(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
