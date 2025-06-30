import UIKit

class FeedbackDetailViewController: UIViewController {
    
    private let feedback: Feedback
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let categoryLabel = UILabel()
    private let voteCountLabel = UILabel()
    private let dateLabel = UILabel()
    
    init(feedback: Feedback) {
        self.feedback = feedback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configure()
    }
    
    private func setupUI() {
        view.backgroundColor = NorthlightTheme.Colors.background
        navigationItem.largeTitleDisplayMode = .never
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NorthlightTheme.Typography.title
        titleLabel.textColor = NorthlightTheme.Colors.label
        titleLabel.numberOfLines = 0
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = NorthlightTheme.Typography.body
        descriptionLabel.textColor = NorthlightTheme.Colors.secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = NorthlightTheme.Typography.caption
        categoryLabel.textColor = NorthlightTheme.Colors.accent
        
        voteCountLabel.translatesAutoresizingMaskIntoConstraints = false
        voteCountLabel.font = NorthlightTheme.Typography.headline
        voteCountLabel.textColor = NorthlightTheme.Colors.primary
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = NorthlightTheme.Typography.caption
        dateLabel.textColor = NorthlightTheme.Colors.tertiaryLabel
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(voteCountLabel)
        contentView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: NorthlightTheme.Spacing.large),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            
            voteCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: NorthlightTheme.Spacing.medium),
            voteCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            
            categoryLabel.centerYAnchor.constraint(equalTo: voteCountLabel.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: voteCountLabel.trailingAnchor, constant: NorthlightTheme.Spacing.medium),
            
            dateLabel.centerYAnchor.constraint(equalTo: voteCountLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            
            descriptionLabel.topAnchor.constraint(equalTo: voteCountLabel.bottomAnchor, constant: NorthlightTheme.Spacing.xLarge),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: NorthlightTheme.Spacing.large),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -NorthlightTheme.Spacing.large),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -NorthlightTheme.Spacing.xxLarge)
        ])
    }
    
    private func configure() {
        titleLabel.text = feedback.title
        descriptionLabel.text = feedback.description
        
        if let category = feedback.category, !category.isEmpty {
            categoryLabel.text = category
            categoryLabel.isHidden = false
        } else {
            categoryLabel.isHidden = true
        }
        
        let voteText = feedback.voteCount == 1 ? "1 vote" : "\(feedback.voteCount) votes"
        voteCountLabel.text = "👍 " + voteText
        
        // Format date
        if let date = ISO8601DateFormatter().date(from: feedback.createdAt) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            dateLabel.text = formatter.string(from: date)
        }
    }
}