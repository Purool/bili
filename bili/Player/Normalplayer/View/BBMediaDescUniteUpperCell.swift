//
//  BBMediaDescUniteUpperCell.swift
//  bili
//
//  Created by DJ on 2024/9/12.
//

import UIKit

class BBMediaDescUniteUpperCell: UITableViewCell {
    
    lazy var avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "common_profile_default")
        return imageView
    }()
    
    lazy var upNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .hexColor(str: "484c53")
        return label
    }()
    
    lazy var stackView: UIStackView = {
        var fansLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .hexColor(str: "9499a0")
            return label
        }()
        
        var playCountLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .hexColor(str: "9499a0")
            return label
        }()
        
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = 6
        stackView.distribution = .fill
        stackView.addArrangedSubview(fansLabel)
        stackView.addArrangedSubview(playCountLabel)
        return stackView
    }()
    
    lazy var attentionBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .hexColor(str: "ff6699")
        button.setTitle("+ 关注", for: .normal)
        return button
    }()
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(avatarView)
        contentView.addSubview(upNameLabel)
        contentView.addSubview(stackView)
        contentView.addSubview(attentionBtn)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupUI() {
        avatarView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(12)
            make.width.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        upNameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView)
            make.left.equalTo(avatarView.snp.right).offset(12)
        }
        
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(avatarView)
            make.left.equalTo(avatarView.snp.right).offset(12)
        }
        
        attentionBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(72)
        }
    }
}
