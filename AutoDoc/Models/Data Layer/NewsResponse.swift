import Foundation

struct NewsResponse: Decodable {
    let news: [NewsDTO]
    let totalCount: Int
}
