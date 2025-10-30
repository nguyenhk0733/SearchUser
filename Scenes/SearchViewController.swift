import UIKit

final class SearchViewController: UITableViewController {

    private var users: [GitHubUser] = []
    private var totalCount: Int = 0

    private let searchController = UISearchController(searchResultsController: nil)
    private var debounceTimer: Timer?
    private var currentQuery: String = ""
    private var currentPage: Int = 1
    private let perPage: Int = 30
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GitHub User Search"

        // Table config
        tableView.rowHeight = 64

        // Search controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search users (e.g. abc)"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func search(query: String, reset: Bool) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if reset {
                users.removeAll()
                totalCount = 0
                tableView.reloadData()
            }
            return
        }
        if isLoading { return }

        isLoading = true
        if reset {
            currentPage = 1
            users.removeAll()
            tableView.reloadData()
        }

        currentQuery = trimmed

        GitHubAPI.shared.searchUsers(query: trimmed, page: currentPage, perPage: perPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let resp):
                self.totalCount = resp.total_count
                if reset {
                    self.users = resp.items
                } else {
                    self.users.append(contentsOf: resp.items)
                }
                self.currentPage += 1
                self.tableView.reloadData()
            case .failure(let err):
                self.showError(err.localizedDescription)
            }
        }
    }

    private func showError(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Table Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let u = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        cell.textLabel?.text = u.login
        cell.detailTextLabel?.text = u.html_url
        cell.imageView?.image = UIImage(systemName: "person.circle")
        if let url = URL(string: u.avatar_url), let imageView = cell.imageView {
            ImageLoader.shared.load(url, into: imageView)
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let username = users[indexPath.row].login
        let vc = storyboard!.instantiateViewController(withIdentifier: "UserDetailViewController") as! UserDetailViewController
        vc.username = username
        navigationController?.pushViewController(vc, animated: true)
    }

    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastRow = indexPath.row == users.count - 1
        if isLastRow, users.count < totalCount, !isLoading, !currentQuery.isEmpty {
            search(query: currentQuery, reset: false)
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        currentQuery = text
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.search(query: text, reset: true)
        })
    }
}
