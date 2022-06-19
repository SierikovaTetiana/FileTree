//
//  MainCollectionViewCell.swift
//  FileTree
//
//  Created by Tetiana Sierikova on 13.06.2022.
//

import UIKit

class Cell: UICollectionViewCell {
    
    static let identifier: String = "Cell"
    
    lazy var title: UILabel = {
        let namelbl = UILabel()
        namelbl.font = UIFont.systemFont(ofSize: 18)
        namelbl.numberOfLines = 0
        namelbl.translatesAutoresizingMaskIntoConstraints = false
        namelbl.setContentCompressionResistancePriority(UILayoutPriority(700), for: .horizontal)
        namelbl.setContentCompressionResistancePriority(UILayoutPriority(700), for: .vertical)
        return namelbl
    }()
    
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var backView: UIStackView = {
        let backView = UIStackView(arrangedSubviews: [image, title])
        backView.clipsToBounds = true
        backView.spacing = 0
        backView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        backView.layer.borderWidth = 0.3
        backView.layer.cornerRadius = 10
        return backView
    }()
    
    override func layoutSubviews() {
        backView.spacing = 16
        super.layoutSubviews()
        backView.frame = CGRect(x: 10, y: 0, width: contentView.frame.size.width - 20, height: contentView.frame.size.height)
        updateContentStyle()
        let constraint = image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 1.0 / 1.0)
        constraint.priority = UILayoutPriority(750)
        constraint.isActive = true
    }
    
    private func updateContentStyle() {
        let isHorizontalStyle = bounds.width > 2 * bounds.height
        let oldAxis = backView.axis
        let newAxis: NSLayoutConstraint.Axis = isHorizontalStyle ? .horizontal : .vertical
        guard oldAxis != newAxis else { return }

        backView.axis = newAxis
        backView.spacing = isHorizontalStyle ? 16 : 4
        title.textAlignment = isHorizontalStyle ? .left : .center
        let fontTransform: CGAffineTransform = isHorizontalStyle ? .identity : CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.3) {
            self.title.transform = fontTransform
            self.layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backView)
        backView.addSubview(image)
        backView.addSubview(title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
