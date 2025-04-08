import Foundation

enum AutoDocAPI {
    case getNews(currentPage: Int, pageSize: Int)
}

extension AutoDocAPI: EndPointType {
    var baseURL: String {
        "https://webapi.autodoc.ru/api"
    }

    var path: String {
        switch self {
        case .getNews(let currentPage, let pageSize):
            "/news/\(currentPage)/\(pageSize)"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getNews:
                .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .getNews:
                .request
        }
    }
}
