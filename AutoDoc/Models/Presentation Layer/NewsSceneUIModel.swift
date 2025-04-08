import UIKit

struct NewsSceneUIModel: Identifiable {
    let id: Int
    let title: String
    let imageURL: String?

    init(news: News) {
        self.id = news.id
        self.title = news.title
        self.imageURL = news.imageURL
    }
}

extension NewsSceneUIModel: Hashable {
    static func == (lhs: NewsSceneUIModel, rhs: NewsSceneUIModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
