import UIKit

protocol AlertFactoryProtocol {
    func makeAlert(title: String, message: String) -> UIViewController
}

final class AlertFactory: AlertFactoryProtocol {
    func makeAlert(title: String, message: String) -> UIViewController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}
