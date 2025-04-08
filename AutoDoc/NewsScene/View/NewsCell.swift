import UIKit
import Combine

final class NewsCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "NewsCell"
    private(set) var cancellables = Set<AnyCancellable>()
    private(set) var cancelImageLoad: ((String) -> Void)?
    private(set) var imageURL: String?

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.clipsToBounds = false
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.backgroundColor = .systemBackground
        let defaultImage = UIImage(systemName: "photo")?
            .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        imageView.image = defaultImage
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let imageActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()

        if let url = imageURL {
            cancelImageLoad?(url)
        }
        imageURL = nil

        imageView.image = UIImage(systemName: "photo")?
            .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        imageActivityIndicator.startAnimating()
        titleLabel.text = nil
    }

    // MARK: - Public API

    func configure(
        with title: String,
        imageURL: String?,
        imagePublisher: AnyPublisher<UIImage?, Never>?,
        cancelLoad: @escaping (String) -> Void
    ) {
        titleLabel.text = title
        self.imageURL = imageURL
        self.cancelImageLoad = cancelLoad

        guard let imageURL = imageURL else {
            imageActivityIndicator.stopAnimating()
            return
        }

        imageActivityIndicator.startAnimating()

        imagePublisher?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self, self.imageURL == imageURL else { return }

                if let image = image {
                    self.imageView.image = image
                } else {
                    self.imageView.image = UIImage(systemName: "photo")?
                        .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
                }
                self.imageActivityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
    }

    func getImage() -> UIImage? {
        return imageView.image
    }
}

// MARK: - Private Methods
private extension NewsCell {
    func commonInit() {
        setupSubviews()
        setupConstraints()
    }

    func setupSubviews() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        imageView.addSubview(imageActivityIndicator)
        setupConstraints()
    }

    func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageActivityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.667),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            imageActivityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageActivityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
}
