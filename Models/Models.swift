import Foundation

struct SearchUsersResponse: Codable {
    let total_count: Int
    let incomplete_results: Bool
    let items: [GitHubUser]
}

struct GitHubUser: Codable {
    let id: Int
    let login: String
    let avatar_url: String
    let html_url: String
}

struct GitHubUserDetail: Codable {
    let id: Int
    let login: String
    let name: String?
    let avatar_url: String
    let html_url: String
    let followers: Int
    let following: Int
    let public_repos: Int
    let bio: String?
    let location: String?
    let blog: String?
}
