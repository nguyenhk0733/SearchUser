import Foundation

enum APIError: Error, LocalizedError {
    case badURL, badStatus(Int), decoding, unknown
    var errorDescription: String? {
        switch self {
        case .badURL: return "URL không hợp lệ."
        case .badStatus(let c): return "HTTP status: \(c)"
        case .decoding: return "Parse JSON thất bại."
        case .unknown: return "Lỗi không xác định."
        }
    }
}

final class GitHubAPI {
    static let shared = GitHubAPI()
    private init() {}

  

    private func request(_ url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        req.setValue("iOS-UIKit-Study", forHTTPHeaderField: "User-Agent")

        return req
    }

    func searchUsers(query: String, page: Int = 1, perPage: Int = 30, completion: @escaping (Result<SearchUsersResponse, Error>) -> Void) {
        guard var comps = URLComponents(string: "https://api.github.com/search/users") else {
            completion(.failure(APIError.badURL)); return
        }
        comps.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        guard let url = comps.url else { completion(.failure(APIError.badURL)); return }

        URLSession.shared.dataTask(with: request(url)) { data, resp, err in
            if let err = err { return DispatchQueue.main.async { completion(.failure(err)) } }
            guard let http = resp as? HTTPURLResponse else {
                return DispatchQueue.main.async { completion(.failure(APIError.unknown)) }
            }
            guard (200..<300).contains(http.statusCode), let data = data else {
                return DispatchQueue.main.async { completion(.failure(APIError.badStatus(http.statusCode))) }
            }
            do {
                let decoded = try JSONDecoder().decode(SearchUsersResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(APIError.decoding)) }
            }
        }.resume()
    }

    func getUserDetail(username: String, completion: @escaping (Result<GitHubUserDetail, Error>) -> Void) {
        guard let url = URL(string: "https://api.github.com/users/\(username)") else {
            completion(.failure(APIError.badURL)); return
        }
        URLSession.shared.dataTask(with: request(url)) { data, resp, err in
            if let err = err { return DispatchQueue.main.async { completion(.failure(err)) } }
            guard let http = resp as? HTTPURLResponse else {
                return DispatchQueue.main.async { completion(.failure(APIError.unknown)) }
            }
            guard (200..<300).contains(http.statusCode), let data = data else {
                return DispatchQueue.main.async { completion(.failure(APIError.badStatus(http.statusCode))) }
            }
            do {
                let decoded = try JSONDecoder().decode(GitHubUserDetail.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(APIError.decoding)) }
            }
        }.resume()
    }
}
