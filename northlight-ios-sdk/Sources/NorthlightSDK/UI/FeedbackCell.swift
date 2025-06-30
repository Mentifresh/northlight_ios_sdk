import UIKit

class FeedbackCell: UITableViewCell {
    
    static let identifier = "FeedbackCell"
    
    var onVoteTapped: (() -> Void)?
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let categoryLabel = UILabel()
    private let statusLabel = UILabel()
    private let voteButton = UIButton(type: .system)
    private let voteCountLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = NorthlightTheme.Colors.secondaryBackground
        containerView.layer.cornerRadius = NorthlightTheme.CornerRadius.large
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = NorthlightTheme.Colors.border.cgColor
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NorthlightTheme.Typography.headline
        titleLabel.textColor = NorthlightTheme.Colors.label
        titleLabel.numberOfLines = 2
        
        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = NorthlightTheme.Typography.body
        descriptionLabel.textColor = NorthlightTheme.Colors.secondaryLabel
        descriptionLabel.numberOfLines = 3
        
        // Category
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = NorthlightTheme.Typography.caption
        categoryLabel.textColor = NorthlightTheme.Colors.accent
        
        // Status
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = NorthlightTheme.Typography.small
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 4
        statusLabel.layer.masksToBounds = true
        statusLabel.textColor = .white
        
        // Vote button
        voteButton.translatesAutoresizingMaskIntoConstraints = false
        voteButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        voteButton.tintColor = NorthlightTheme.Colors.primary
        voteButton.backgroundColor = NorthlightTheme.Colors.background
        voteButton.layer.cornerRadius = NorthlightTheme.CornerRadius.small
        voteButton.layer.borderWidth = 1
        voteButton.layer.borderColor = NorthlightTheme.Colors.border.cgColor
        voteButton.addTarget(self, action: #selector(voteTapped), for: .touchUpInside)
        
        // Vote count
        voteCountLabel.translatesAutoresizingMaskIntoConstraints = false
        voteCountLabel.font = NorthlightTheme.Typography.caption
        voteCountLabel.textColor = NorthlightTheme.Colors.secondaryLabel
        voteCountLabel.textAlignment = .center
        
        // Date
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = NorthlightTheme.Typography.small
        dateLabel.textColor = NorthlightTheme.Colors.tertiaryLabel
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(voteButton)
        containerView.addSubview(voteCountLabel)
        containerView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: NorthlightTheme.Spacing.xSmall),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.medium),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.medium),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -NorthlightTheme.Spacing.xSmall),
            
            // Vote button and count on the right
            voteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: NorthlightTheme.Spacing.medium),
            voteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -NorthlightTheme.Spacing.medium),
            voteButton.widthAnchor.constraint(equalToConstant: 44),
            voteButton.heightAnchor.constraint(equalToConstant: 44),
            
            voteCountLabel.topAnchor.constraint(equalTo: voteButton.bottomAnchor, constant: NorthlightTheme.Spacing.xxSmall),
            voteCountLabel.centerXAnchor.constraint(equalTo: voteButton.centerXAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: NorthlightTheme.Spacing.medium),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: NorthlightTheme.Spacing.medium),
            titleLabel.trailingAnchor.constraint(equalTo: voteButton.leadingAnchor, constant: -NorthlightTheme.Spacing.medium),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: NorthlightTheme.Spacing.xSmall),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: NorthlightTheme.Spacing.medium),
            descriptionLabel.trailingAnchor.constraint(equalTo: voteButton.leadingAnchor, constant: -NorthlightTheme.Spacing.medium),
            
            // Category, status and date
            statusLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: NorthlightTheme.Spacing.small),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: NorthlightTheme.Spacing.medium),
            statusLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -NorthlightTheme.Spacing.medium),
            
            categoryLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: NorthlightTheme.Spacing.small),
            
            dateLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: voteButton.leadingAnchor, constant: -NorthlightTheme.Spacing.medium)
        ])
    }
    
    func configure(with feedback: Feedback, hasVoted: Bool) {
        titleLabel.text = feedback.title
        descriptionLabel.text = feedback.description
        
        if let category = feedback.category, !category.isEmpty {
            categoryLabel.text = category
            categoryLabel.isHidden = false
        } else {
            categoryLabel.isHidden = true
        }
        
        voteCountLabel.text = "\(feedback.voteCount)"
        
        // Configure status
        let statusText = feedback.status.split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
        statusLabel.text = "  \(statusText)  "  // Add padding with spaces
        
        // Set status color
        switch feedback.status.lowercased() {
        case "in progress":
            statusLabel.backgroundColor = UIColor.systemBlue
        case "approved":
            statusLabel.backgroundColor = UIColor.systemGreen
        case "suggested":
            statusLabel.backgroundColor = UIColor.systemOrange
        case "pending":
            statusLabel.backgroundColor = UIColor.systemGray
        case "completed":
            statusLabel.backgroundColor = UIColor.systemPurple
        default:
            statusLabel.backgroundColor = UIColor.systemGray
        }
        
        // Format date
        if let date = ISO8601DateFormatter().date(from: feedback.createdAt) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            dateLabel.text = formatter.localizedString(for: date, relativeTo: Date())
        } else {
            dateLabel.text = ""
        }
        
        // Update vote button state
        if hasVoted {
            voteButton.backgroundColor = NorthlightTheme.Colors.primary
            voteButton.tintColor = .white
            voteButton.isEnabled = false
        } else {
            voteButton.backgroundColor = NorthlightTheme.Colors.background
            voteButton.tintColor = NorthlightTheme.Colors.primary
            voteButton.isEnabled = true
        }
    }
    
    @objc private func voteTapped() {
        onVoteTapped?()
    }
}