//
//  EntryCell.swift
//  NewsRSSReader
//
//  Created by Диана Нуансенгси on 22.10.22.
//

import Foundation
import UIKit
import SnapKit

enum CellState {
    case expanded
    case collapsed
}
class EntryCell: UITableViewCell {
    static let identifier = "cell"
    var item: RSSItemModel! {
        didSet {
            titleLabel.text = item.title
            descriptionLabel.text = item.description
            dateLabel.text = item.pubDate
        }
    }
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        label.sizeToFit()
                   return label
    }()
    let dateLabel: UILabel = {
          let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
          return label
      }()
    let descriptionLabel: UILabel = {
          let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 3
          return label
      }()
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // Vertical Stack View
    lazy var vStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 7
        stack.distribution = .equalSpacing
        //stack.distribution = .fillProportionally
        stack.clipsToBounds = true
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(dateLabel)
        stack.addArrangedSubview(descriptionLabel)
        
        return stack
    }()
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupViews()
        }
    // Horizontal Stack View
//    lazy var hStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .horizontal
//        stack.alignment = .leading
//        stack.spacing = 0
//        stack.distribution = .fillProportionally
//        stack.clipsToBounds = true
//        stack.addArrangedSubview(iconImageView)
//        stack.addArrangedSubview(vStackView)
//        return stack
//    }()
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        iconImageView.image = nil
//        titleLabel.text = nil
//        descriptionLabel.text = nil
//        dateLabel.text = nil
//    }
     func setupViews() {
        
        contentView.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
    }
}
