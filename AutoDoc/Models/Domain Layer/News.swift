import Foundation

struct News: Identifiable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: Date?
    let imageURL: String?

    init(newsDTO: NewsDTO) {

        self.id = newsDTO.id
        self.title = newsDTO.title
        self.description = newsDTO.description
        self.publishedDate = News.date(from: newsDTO.publishedDate)
        self.imageURL = newsDTO.titleImageURL
    }

    private static func date(from string: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withFullDate,
            .withTime,
            .withColonSeparatorInTime,
            .withDashSeparatorInDate
        ]

        if let date = isoFormatter.date(from: string) {
            return date
        }

        return isoFormatter.date(from: string + "Z") // Попытка с UTC
    }
}
