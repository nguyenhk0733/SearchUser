import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    private init() {}

    func load(_ url: URL, into imageView: UIImageView) {
        if let cached = cache.object(forKey: url as NSURL) {
            imageView.image = cached; return
        }
        imageView.image = nil
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let img = UIImage(data: data) else { return }
            self.cache.setObject(img, forKey: url as NSURL)
            DispatchQueue.main.async { imageView.image = img }
        }.resume()
    }
}
